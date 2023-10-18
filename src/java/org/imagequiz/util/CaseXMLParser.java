/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.util;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

import org.hibernate.criterion.Restrictions;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQQuestionText;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;

/**
 *
 * @author apavel
 */
public class CaseXMLParser {
    public IQCase parseCase(String questionXml, IQCase caseToFill, IQDataSource dataSource) throws CaseParseException, JDOMException, IOException {
        if (caseToFill.isParsed()) throw new CaseParseException("This case '" + caseToFill.getCaseId() + "' has already been parsed");
    	
        SAXBuilder parser = new SAXBuilder();
        XMLOutputter xmlOutputter = new XMLOutputter();
            //remove namespace:
            questionXml = questionXml.replaceAll("xmlns=\"http://www.w3.org/2001/XMLSchema\"", "");
        	//pre-processing ---> fix &nbsp; escape (otherwise XML parser freaks out), just after parsing, have to put it back to &
        	//questionXml = questionXml.replaceAll("&", "&amp;"); 
            Document document = parser.build(new StringReader(questionXml));
            document.getRootElement().setNamespace(Namespace.NO_NAMESPACE);
            Element caseE = document.getRootElement();
            
            caseToFill = processCase(caseE, caseToFill, dataSource);
            Element rootEle = new Element("case-list");
            caseToFill.setCaseXml(xmlOutputter.outputString(caseE.clone()));
            //put &amp back to & (was changed above to keep XML parser happy)
            //caseToFill.setCaseXml(caseToFill.getCaseXml().replaceAll("&amp;", "&"));
            caseToFill.setParsed(true);
            System.out.println("This case has this many questions: " + caseToFill.getQuestionList().size());
            return caseToFill;
            
    }
	/*
    public IQExercise parse(String questionXml) throws CaseParseException, JDOMException, IOException {
        IQExercise caseList = new IQExercise();
        SAXBuilder parser = new SAXBuilder();
        XMLOutputter xmlOutputter = new XMLOutputter();
            //remove namespace:
            questionXml = questionXml.replaceAll("xmlns=\"http://www.w3.org/2001/XMLSchema\"", "");
            Document document = parser.build(new StringReader(questionXml));
            document.getRootElement().setNamespace(Namespace.NO_NAMESPACE);
            List<Element> cases = document.getRootElement().getChildren("case");
            System.out.println("Found cases: " + cases.size());
            if (cases.size() == 0) {
                Element rootElement = document.getRootElement();
                cases = new ArrayList();
                cases.add(rootElement);
            }
            for (Element caseE: cases) {
                IQCase newCase = processCase(caseE);
                Element rootEle = new Element("case-list");
                newCase.setCaseXml(xmlOutputter.outputString(caseE.clone()));
                caseList.getCases().add(newCase);
            }
            
            //load default investigations
            Element defaultValuesE = document.getRootElement().getChild("defaultValues");
            if (defaultValuesE != null && defaultValuesE.getChild("investigations") != null) {
                Element defaultInvestigationsE = document.getRootElement().getChild("defaultValues").getChild("investigations");
                List<IQInvestigation> newInv = processInvestigations(defaultInvestigationsE);
                caseList.getDefaultInvestigations().addAll(newInv);
            }
            
            //load default treatments
            
            //load other question tags.
            Element tagE = document.getRootElement().getChild("tags");
            if (tagE != null) {
                List<Element> tagGroupsE = document.getRootElement().getChild("tags").getChildren("tag-group");
                for (Element tagGroupE: tagGroupsE) {
                    IQTagGroup newTagGroup = processTagGroup(tagGroupE);
                    caseList.getTagGroupList().add(newTagGroup);
                }
            }

        return caseList;
    }
    */
    private IQCase processCase(Element caseE, IQCase newCase, IQDataSource dataSource) throws CaseParseException {
        //load questions first
        //set questions
		//clear all questions from case;
    	for (Iterator<IQQuestion> i = newCase.getQuestionList().listIterator(); i.hasNext();) {
    		IQQuestion q = i.next();
    		dataSource.getSession().delete(q);
    		i.remove();
    	}
    	
        if (caseE.getChild("settings") == null) throw new CaseParseException("Every <case> must have a <settings>");
        Element settingsE = caseE.getChild("settings");
        String display = settingsE.getAttributeValue("display", ""); //determines if special code needed to displaly case (like mcq) - showing question + answer on same page
        newCase.setDisplayType(resolveDisplayType(display));
        newCase.setEditorType(settingsE.getAttributeValue("editor", ""));
        List<Element> questionsE = settingsE.getChildren("question");
        for (Element questionE: questionsE) {
            String qid = questionE.getAttributeValue("id");
            String qtype = questionE.getAttributeValue("type");
            if (qtype.equalsIgnoreCase("search_term")) qtype = "sg";
            String questionText = questionE.getChildText("question-text");
            if (questionText == null) questionText = "";
            else questionText = questionText.trim();
            if (!IQQuestion.typeExists(qtype)) throw new CaseParseException("Question type '" + qtype + "' does not exist");
            IQQuestion newQuestion;
            if (qtype.equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
        		IQQuestionChoice newQuestionSingleChoice = new IQQuestionChoice();
        		String selectionsStr = questionE.getAttributeValue("selections");
        		try {
        			Integer selections = Integer.parseInt(selectionsStr);
        			newQuestionSingleChoice.setMaxUserSelections(selections);
        		} catch (NumberFormatException nfe) { 
        			throw new CaseParseException("Question '" + questionE.getAttributeValue("id", "--") + "' has invalid 'selections' attribute.  It must be a number");
        		}
            	for (Element choiceE: questionE.getChildren("choice")) {
            		IQAnswerChoice newChoice = convertElementToChoice(choiceE);
            		newChoice.setParentQuestion(newQuestionSingleChoice);
            		newQuestionSingleChoice.getAssociatedChoices().add(newChoice);
            	}
            	newQuestion = newQuestionSingleChoice;
            } else if (qtype.equals(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
            	IQQuestionSearchTerm newQuestionSearchTerm = new IQQuestionSearchTerm();
            	String searchGroups = questionE.getAttributeValue("searchgroups");
            	
            	if (searchGroups != null && !searchGroups.equals("")) {
            		List<String> searchGroupsStrList = Arrays.asList(searchGroups.split("\\s*,\\s*"));
            		newQuestionSearchTerm = setSearchGroups(searchGroupsStrList, newQuestionSearchTerm, dataSource);
            	}
            	for (Element answer: questionE.getChildren("answer")) {
            		IQAnswerSearchTermLine line = new IQAnswerSearchTermLine();
            		
            		
            		
            		// see if answer has "subanswers" (where one or the other could be right, granting differen points for each)
            		if (answer.getChildren().size() > 0) {
            			//System.out.println("number found: " + answer.getChildren().size());
	            		for (Element subAnswer: answer.getChildren("answer")) {
	            			//find searchterm if it exists in the defined groups
	                		IQAnswerSearchTerm searchTerm = findSearchTerm(IQAnswerSearchTerm.removeAnswerAnnotations(subAnswer.getTextTrim()), qid, dataSource);
	            			IQAnswerSearchTermWrapper newWrapper = createWrapper(subAnswer, searchTerm, qid);
	            			line.getAssociatedAnswerWrappers().add(newWrapper);
	            			newWrapper.setParentQuestionLine(line);
	            			
	            		}
            		} else {  //<answer><answer score="+1">search term</answer><answer score="+2">More correct answer</answer></answer>
            			//find searchterm if it exists in the defined groups
                		IQAnswerSearchTerm searchTerm = findSearchTerm(IQAnswerSearchTerm.removeAnswerAnnotations(answer.getTextTrim()), qid, dataSource);
            			IQAnswerSearchTermWrapper newWrapper = createWrapper(answer, searchTerm, qid);
            			line.getAssociatedAnswerWrappers().add(newWrapper);
            			newWrapper.setParentQuestionLine(line);
            		}
	             		
             		
             		newQuestionSearchTerm.getAssociatedAnswerLines().add(line);
             		line.setParentQuestion(newQuestionSearchTerm);
            	}
            	newQuestion = newQuestionSearchTerm;
            } else if (qtype.equals(IQQuestion.QUESTION_TYPE_TEXT)) {
            	String height = questionE.getAttributeValue("lines", "1");
            	IQQuestionText newTextQuestion = new IQQuestionText();
            	if (height != null) {
            		newTextQuestion.setHeight(Integer.parseInt(height));
            	}
            	newQuestion = newTextQuestion;
            } else {
            	throw new CaseParseException("Unknown question type: '" + qtype + "'");
            }
            BigDecimal wrongChoiceScore = new BigDecimal(questionE.getAttributeValue("wrong-choice-score", "0"));
            BigDecimal passScore = new BigDecimal(questionE.getAttributeValue("pass-score", "1"));
            newQuestion.setWrongChoiceScore(wrongChoiceScore);
            newQuestion.setPassScore(passScore);
            newQuestion.setQuestionTextId(questionE.getAttributeValue("id"));
            String qt = questionE.getAttributeValue("type");
            if (qt.equalsIgnoreCase("search_term")) qt = IQQuestion.QUESTION_TYPE_SEARCHTERM;
        	newQuestion.setQuestionType(qt);
        	newQuestion.setQuestionText(questionText);
            newCase.getQuestionList().add(newQuestion);
            newQuestion.setParentCase(newCase);
            
            
            List<Element> defaultTagsE = questionE.getChildren("tag");
            if (!defaultTagsE.isEmpty()) {
                //add default values for tags (i.e special lab values)
                //IQTagGroup customTagGroup = processTagGroup(questionE);
                //newCase.getCustomTags().add(customTagGroup);
            }
        }
        try {
        	//put &amp; back to & (was changed above to keep XML parser happy)
        	String caseText = utilGetContentHtml(caseE.getChild("case-text")).trim();
        	caseText = caseText.replaceAll("&amp;", "&");
        	CaseUtil caseUtil = new CaseUtil();
        	caseText = caseUtil.unescapeHTMLforXML(caseText);
        	newCase.setCaseText(caseText);
        	if (caseE.getChild("answer-text") != null) {
        		//same, change &amp; back to &
        		String caseAnswerText = utilGetContentHtml(caseE.getChild("answer-text")).trim();
            	caseAnswerText = caseAnswerText.replaceAll("&amp;", "&");
            	caseAnswerText = caseUtil.unescapeHTMLforXML(caseAnswerText);
        		newCase.setCaseAnswerText(caseAnswerText);
        	}
        } catch (IOException ioe) { throw new CaseParseException("Unable to get <case-text> and/or <answer-text> contents. ");}
        
        
        //confirm all questions are defined 
    	checkIfQuestionExists(newCase.getCaseText(), newCase, "{question:");
    	checkIfQuestionExists(newCase.getCaseAnswerText(), newCase, "{answer:");

        return newCase;
    }
    
    private Integer resolveDisplayType(String displayS) throws CaseParseException {
    	try {
    		if (displayS.equals("")) return 0;
    		Integer result = Integer.parseInt(displayS);
    		return result;
    	} catch (NumberFormatException nfe) {
    		throw new CaseParseException("&lt;settings display=\"" + displayS + "\" attribute must be an integer, default is 0");
    	}
    }
    
    private void checkIfQuestionExists(String caseText, IQCase newCase, String pattern) throws CaseParseException {
    	int ii = 0;
    	while (ii != -1) {
    		ii = caseText.indexOf(pattern, ii+1);
    		if (ii != -1) {
	    		String qid = caseText.substring(ii+pattern.length(), caseText.indexOf("}", ii)).trim();
	    		if (newCase.getQuestionById(qid) == null) {
	    			throw new CaseParseException("Unable to get find question '" + qid + "' in &lt;settings&gt;, please check the '" + pattern + "' to ensure it has the right question id");
	    		}
    		}
    	}
    }
    
    private IQAnswerSearchTerm findSearchTerm(String str, String questionIdForError, IQDataSource dataSource) throws CaseParseException {
    	List<IQAnswerSearchTerm> searchResult =  (List<IQAnswerSearchTerm>) dataSource.getSession().createCriteria(IQAnswerSearchTerm.class)
    			.add(Restrictions.eq("searchTermString", str)).list();
    	if (searchResult.size() == 0) throw new CaseParseException("Answer '" + str + "' for question '" + questionIdForError + "' cannot be found in predefined answers, please check");
    	else if (searchResult.size() > 1) throw new CaseParseException("Multiple pre-defined searchterm answers '" + str + "', something is wrong");
    	else return searchResult.get(0);
    }
    
    private IQAnswerSearchTermWrapper createWrapper(Element el, IQAnswerSearchTerm searchTerm, String questionIdForErrors) throws CaseParseException {
		IQAnswerSearchTermWrapper wrapper = new IQAnswerSearchTermWrapper();
		String correctStr = el.getAttributeValue("correct");
		try {
			if (correctStr == null || correctStr.equals("") || correctStr.equals("1")) {
				wrapper.setCorrectAnswer(true);
			} else if (correctStr.equals("0")) {
				wrapper.setCorrectAnswer(false);
			}
		} catch (Exception e) { throw new CaseParseException("Question '" + questionIdForErrors + "' cannot parse correct=\"\", must be a number", e); }
 		
		try {

			if (el.getAttributeValue("score") != null) {
				String scoreStr = el.getAttributeValue("score");
				BigDecimal score;
				if (scoreStr.startsWith("-")) { 
					//negative score
					score = new BigDecimal(scoreStr);
					wrapper.setScoreModifier(score);
					if (correctStr == null) {
						wrapper.setCorrectAnswer(false); //default to wrong choice if negative score and 'correct=' attribute undefined
					}
				} else {
					score = new BigDecimal(scoreStr);
					wrapper.setScoreModifier(score);
					if (correctStr == null) {
						wrapper.setCorrectAnswer(true); //see above
					}
				}
			}
		} catch (Exception e) { throw new CaseParseException("Question '" + questionIdForErrors + "' cannot parse score, must be a number", e); }
 		
 		try {
			if (el.getAttributeValue("missed") != null) {
				String missedStr = el.getAttributeValue("missed");
				BigDecimal missed = new BigDecimal(missedStr);
				wrapper.setScoreMissed(missed);
			}
		} catch (Exception e) { 
			throw new CaseParseException("Question '" + questionIdForErrors + "' cannot parse score, must be a number", e); 
		}
 		
 		String primaryStr = el.getAttributeValue("primary");
 		if (primaryStr != null) {
	 		if (primaryStr.equalsIgnoreCase("true") || primaryStr.equals("1") || primaryStr.equalsIgnoreCase(""))
	 			wrapper.setPrimaryAnswer(true);
	 		else if (primaryStr.equalsIgnoreCase("false") || primaryStr.equals("0"))
	 			wrapper.setPrimaryAnswer(false);
	 		else throw new CaseParseException("Cannot understand value of primary='" + primaryStr + "'");
 		}
		
 		wrapper.setSearchTerm(searchTerm);
 		return wrapper;
    }
    
    private IQQuestionSearchTerm setSearchGroups(List<String> searchTerms, IQQuestionSearchTerm targetQuestion, IQDataSource dataSource) throws CaseParseException {

    	for (String searchTerm: searchTerms) {
    		IQSearchTermGroup iqst = dataSource.getSearchTermGroupByName(searchTerm);
    		if (iqst == null) {
    			if (searchTerms.get(0).equalsIgnoreCase("rhythm")) //REMOVE
    				targetQuestion.getAvailableGroups().add(dataSource.getSearchTermGroupByName("level1")); //REMOVE
    			else//REMOVE
    				throw new CaseParseException("SearchTerm Group '" + searchTerm + "' cannot be found.");
    		} else {
    			targetQuestion.getAvailableGroups().add(iqst);
    		}
    	}
    	return targetQuestion;
    }
    
    private IQAnswerChoice convertElementToChoice(Element choiceE) throws CaseParseException {
    	String choiceText = choiceE.getTextTrim();
		String scoreModifier = choiceE.getAttributeValue("score", "0");
		String missScoreModifier = choiceE.getAttributeValue("missed", "0");
		String correctAnswerStr = choiceE.getAttributeValue("correct", "0");
		IQAnswerChoice newChoice = new IQAnswerChoice();
		if (correctAnswerStr == null || correctAnswerStr.equalsIgnoreCase("false") || correctAnswerStr.equals("0")) {
			newChoice.setCorrect(false);
		} else if (correctAnswerStr.equalsIgnoreCase("true") || correctAnswerStr.equals("") || correctAnswerStr.equals("1")) {
			newChoice.setCorrect(true);
		} else {
			throw new CaseParseException("The <choice correct=\"...\" must be either 'true' or 'false'");
		}
		newChoice.setAnswerString(choiceText);
		try {
			newChoice.setSelectScore(new BigDecimal(scoreModifier));
			newChoice.setMissScore(new BigDecimal(missScoreModifier));
		} catch (Exception e) {
			throw new CaseParseException("Cannot read score='' missed='', please ensure they are numbers");
		}
		return newChoice;
    }
    
    private String utilGetContentHtml(Element element) throws IOException {
    	XMLOutputter outp = new XMLOutputter();
    	outp.setFormat(Format.getRawFormat());
    	StringWriter sw = new StringWriter();
    	outp.output(element.getContent(), sw);
    	StringBuffer sb = sw.getBuffer();
    	return sb.toString();
    }
    
    /*
    private IQTagGroup processTagGroup(Element tagGroupE) throws CaseParseException {
            IQTagGroup newTagGroup = new IQTagGroup();
            String tagGroupName = tagGroupE.getAttributeValue("name");
            String tagGroupType = tagGroupE.getAttributeValue("type");
            if (tagGroupName == null) tagGroupName = tagGroupType;
            newTagGroup.setListName(tagGroupName);
            
            //for investigations
            if (tagGroupType != null && tagGroupType.equalsIgnoreCase("investigations")) {
                List<Element> tagEs = tagGroupE.getChildren();
                //sometimes tags have sub-tags (i.e. CBC has WBC, Hemoglobin etc..);
                for (Element tagE: tagEs) {
                    List<Element> tag2Es = tagE.getChildren();
                    boolean isInvestigationGroup = !tag2Es.isEmpty();
                    IQInvestigation newInv = processTagInvestigation(tagE, null, isInvestigationGroup);
                    if (!tag2Es.isEmpty()) {
                        for (Element tag2E: tag2Es) {
                            //allow only one level of investigation groups for now (i.e. cannot do group within a group).
                            newInv = processTagInvestigation(tag2E, newInv, false);
                        }
                    }
                    newTagGroup.getTags().add(newInv);
                }
            } else if (tagGroupType != null && tagGroupType.equalsIgnoreCase("treatments")) {
                //TODO
            } else if (tagGroupE.getChildren().isEmpty()) {
                //just a simple list of tags
                String tagGroupListStr = tagGroupE.getTextTrim(); //remove whitespace
                String[] tagGroupListArray = tagGroupListStr.split("\n");
                for (String tagGroupItem: tagGroupListArray) {
                    tagGroupItem = tagGroupItem.trim();
                    newTagGroup.getTags().add(new IQTagSimple(tagGroupItem));
                }
            } else {
                throw new CaseParseException("Tag group named '" + tagGroupName + "' is unknown because it has complex elements and has no 'type=' set");
            }
            return newTagGroup;
    }
    
    private List<IQInvestigation> processInvestigations(Element investigationParentE) throws CaseParseException {
        List<IQInvestigation> investigationList = new ArrayList();
        List<Element> invEs = investigationParentE.getChildren();
        //sometimes tags have sub-tags (i.e. CBC has WBC, Hemoglobin etc..);
        for (Element invE: invEs) {
            List<Element> inv2Es = invE.getChildren();
            boolean isInvestigationGroup = !inv2Es.isEmpty();
            IQInvestigation newInv = processTagInvestigation(invE, null, isInvestigationGroup);
            if (!inv2Es.isEmpty()) {
                for (Element inv2E: inv2Es) {
                    //allow only one level of investigation groups for now (i.e. cannot do group within a group).
                    newInv = processTagInvestigation(inv2E, newInv, false);
                }
            }
            investigationList.add(newInv);
        }
        return investigationList;
    }
    
    //parent investigation exists if there are groups of results i.e. (CBC  contains WBC, Hemoglobin, etc..)
    private IQInvestigation processTagInvestigation(Element invE, IQInvestigation parentInvestigation, boolean isInvestigationGroup) throws CaseParseException {
        IQInvestigation newInv = new IQInvestigation();
        String tagName = invE.getAttributeValue("name");
        if (tagName == null) throw new CaseParseException("There is no 'name' attribute in one of the investigation <inv tags");
        String normalValue = invE.getAttributeValue("normal");
        String unit = invE.getAttributeValue("unit", "");
        
        String value = invE.getAttributeValue("value");
        String scoreSelected = invE.getAttributeValue("score-selected");
        String scoreNotSelected = invE.getAttributeValue("score-notselected");
        String scoreComment = invE.getAttributeValue("comment");
        
        //if (!isInvestigationGroup && normalValue == null && value == null) throw new CaseParseException("The investigation named '" + newInv.getTagName() + "' does not have a 'normal=' or 'value=' value set, and does not appear to be an investigation group");

        
        //check to see if normal value is text, a number or a range of numbers.
            //process normal value.
            
        if (normalValue != null && !normalValue.matches("[a-zA-Z]+") && normalValue.indexOf("-") != -1) {
            //if range of numbers
            int rangeDashIndex = normalValue.indexOf("-");
            String minValue = normalValue.substring(0, rangeDashIndex).trim();
            String maxValue = normalValue.substring(rangeDashIndex + 1).trim();
            newInv = new IQInvestigation(tagName, minValue, maxValue, unit);
        } else {
            //set as text
            newInv = new IQInvestigation(tagName, normalValue, unit);
        }
        
        //scoring
        if (scoreSelected != null && !scoreSelected.equals("")) {
            newInv.setScoreIfSelected(Integer.parseInt(scoreSelected));
        }
        if (scoreNotSelected != null && !scoreNotSelected.equals("")) {
            newInv.setScoreIfNotSelected(Integer.parseInt(scoreNotSelected));
        }
        if (scoreComment != null) {
            newInv.setScoreComment(scoreComment);
        }
        if (value != null) {
            newInv.setCustomValue(value);
        }
        
        if (parentInvestigation != null) {
            parentInvestigation.addSubInvestigations(newInv);
            return parentInvestigation;
        }
        return newInv;
    }
    /*
    public static String getDefaultXml() {
    	String xml = "";
    	return xml;
    }*/
    
    
    
}
