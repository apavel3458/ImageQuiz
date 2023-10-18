package org.imagequiz.web;

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.BorderFormatting;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.RichTextString;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.extensions.XSSFCellBorder.BorderSide;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.question.IQAnswer;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.result.IQCaseSummary;
import org.imagequiz.model.result.IQCaseSummary.Item;
import org.imagequiz.model.result.IQSummaryExam;
import org.imagequiz.model.result.IQSummaryMCQ;
import org.imagequiz.model.result.IQSummaryQ;
import org.imagequiz.model.result.IQSummarySearchTerm;
import org.imagequiz.model.result.IQSummaryText;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuestionAnswered;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.util.ActionSecurity;
import org.imagequiz.util.CaseXMLParser;
import org.imagequiz.util.ResultsUtil;

public class ResultsAction extends DispatchAction {
    protected static Log _log = LogFactory.getLog(ResultsAction.class);
        
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    public ResultsAction() {
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return null;
    }
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	ActionSecurity actionSecurity = new ActionSecurity();
    	return actionSecurity.filter(mapping, form, request, response, this);
    }
    
    public ActionForward answersByUser(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examid = request.getParameter("examid");
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examid));
    	String transposed = request.getParameter("transposed");
    	
    	//sets columns
    	
    	
    	try {
	    	OutputStream os = response.getOutputStream();
	    	response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
	        response.setHeader("Content-Disposition", "attachment; filename=\"Answers By User.xlsx\"");
	    	
	        Workbook workbook = new XSSFWorkbook();
	    	CreationHelper createHelper = workbook.getCreationHelper();
			CellStyle answerCellStyle = workbook.createCellStyle();
			answerCellStyle.setWrapText(true);
	    	Sheet sheet = workbook.createSheet("IQ Results");
	        Integer r = 0;
	        Integer c = 0;
	        
	        //headers
	        Row headers = sheet.createRow(r); r = r+1;
	        headers.createCell(c).setCellValue("Username"); c = c+1;
	        sheet.autoSizeColumn(0);
	        headers.createCell(c).setCellValue("Last+First Name"); c = c+1;
	        sheet.autoSizeColumn(1);
	        
	        Hashtable<String, Integer> resultColumns = new Hashtable();
	        IQExercise iexercise = iexam.getExercise();
	        for (IQCase icase: iexercise.getCases()) {
	        	
	        	//if (!icase.isParsed()) {
	        	//	CaseXMLParser parser = new CaseXMLParser();
	        	//	parser.parseCase(icase.getCaseXml(), icase, dataSource);
	        	//}
	        	List<IQQuestion> questions = icase.getQuestionList();
	        	for (IQQuestion question: questions) {
	        		headers.createCell(c).setCellValue(icase.getCaseName() + "-" + question.getQuestionTextId()); 
	        		resultColumns.put(icase.getCaseName() + "-" + question.getQuestionTextId(), c);
	        		c=c+1;
	        	}
	        }
	        
	        //autos-size width of columns
            Iterator<Cell> cellIterator = headers.cellIterator();
            while (cellIterator.hasNext()) {
                Cell cell = cellIterator.next();
                int columnIndex = cell.getColumnIndex();
                sheet.autoSizeColumn(columnIndex);
            }
	        
	        
	        for (IQUserQuiz userQuiz: iexam.getUserQuizes()) {
	        	c = 0;
	        	int rowHeight = 1;
	        	Row row = sheet.createRow(r); r = r+1;
	        	Cell cell = row.createCell(c); c = c+1;
	        	
	        	cell.setCellValue(userQuiz.getUser().getUsername());
	        	row.createCell(c).setCellValue(userQuiz.getUser().getLastName() + " " + userQuiz.getUser().getFirstName()); c = c+1;
	        	List<IQCaseCompleted> completedCases = userQuiz.getCompletedCases();
	        	for (IQCaseCompleted caseCompleted: completedCases) {
	        		for (IQUserQuestionAnswered answeredQuestion: caseCompleted.getAnsweredQuestions()) {
	        			String questionId = answeredQuestion.getQuestionId();
	        			String caseName = caseCompleted.getAssociatedCase().getCaseName();
	        			int columnIndex = resultColumns.get(caseName + "-" + questionId);
	        			Cell answerCell = row.createCell(columnIndex);
	        			answerCell.setCellValue(
	        					createHelper.createRichTextString(StringUtils.join(answeredQuestion.getUserSelections(), "\n"))
	        					);

	        		    answerCell.setCellStyle(answerCellStyle);
	        			if (answeredQuestion.getUserSelections().size() > rowHeight) {
	        				rowHeight = answeredQuestion.getUserSelections().size();
	        				row.setHeightInPoints((rowHeight * sheet.getDefaultRowHeightInPoints()));
	        			}
	        			
        			}
	        	}
	        }
	        
	        if (transposed != null && transposed.equalsIgnoreCase("1")) {
	        	ResultsUtil.transpose(workbook, 0, true);
	        }

	    	
	        workbook.write(os);
	        workbook.close();
	        os.close();
	        
    	} catch (Exception e) {
    		request.setAttribute("message", "Something went wrong");
    		throw e;
    	}
    	return null;
    }
    
    public ActionForward allAnswersColored2(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examid = request.getParameter("examid");
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examid));
    	
    	//sets columns
    	

    	
    	try {
	    	OutputStream os = response.getOutputStream();
	    	response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
	        response.setHeader("Content-Disposition", "attachment; filename=\"Case Review Results.xlsx\"");
	    	
	        Workbook workbook = new XSSFWorkbook();
	        
	        //styles-------------
	        
	        
	        XSSFColor cellBorderGrey = new XSSFColor(new java.awt.Color(209, 209, 209));
	        XSSFColor cellBorderRed = new XSSFColor(new java.awt.Color(240, 147, 170));
	        
	        XSSFCellStyle header = (XSSFCellStyle) workbook.createCellStyle();
	    	XSSFCellStyle rowColor1 = (XSSFCellStyle) workbook.createCellStyle();
	    	rowColor1.setFillForegroundColor(new XSSFColor(new java.awt.Color(210, 238, 255)));
	    	rowColor1.setFillPattern(CellStyle.SOLID_FOREGROUND);
	    	rowColor1.setWrapText(true);
	    	rowColor1.setBorderBottom(CellStyle.BORDER_THIN);rowColor1.setBottomBorderColor(cellBorderGrey);
	    	rowColor1.setBorderTop(CellStyle.BORDER_THIN);rowColor1.setTopBorderColor(cellBorderGrey);
	    	rowColor1.setBorderLeft(CellStyle.BORDER_THIN);rowColor1.setLeftBorderColor(cellBorderGrey);
	    	rowColor1.setBorderRight(CellStyle.BORDER_THIN);rowColor1.setRightBorderColor(cellBorderGrey);
	        XSSFCellStyle rowColor2 = (XSSFCellStyle) workbook.createCellStyle();
	        rowColor2.setFillForegroundColor(new XSSFColor(new java.awt.Color(216, 255, 210)));
	        rowColor2.setFillPattern(CellStyle.SOLID_FOREGROUND);
	        rowColor2.setWrapText(true);
	    	rowColor2.setBorderBottom(CellStyle.BORDER_THIN);rowColor2.setBottomBorderColor(cellBorderGrey);
	    	rowColor2.setBorderTop(CellStyle.BORDER_THIN);rowColor2.setTopBorderColor(cellBorderGrey);
	    	rowColor2.setBorderLeft(CellStyle.BORDER_THIN);rowColor2.setLeftBorderColor(cellBorderGrey);
	    	rowColor2.setBorderRight(CellStyle.BORDER_THIN);rowColor2.setRightBorderColor(cellBorderGrey);
	        
	    	XSSFCellStyle scoreStyle = (XSSFCellStyle) workbook.createCellStyle();
	    	scoreStyle.setFillForegroundColor(new XSSFColor(new java.awt.Color(255, 210, 247)));
	    	scoreStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	    	scoreStyle.setWrapText(true);
	    	scoreStyle.setBorderBottom(CellStyle.BORDER_THIN);scoreStyle.setBottomBorderColor(cellBorderRed);
	    	scoreStyle.setBorderTop(CellStyle.BORDER_THIN);scoreStyle.setTopBorderColor(cellBorderRed);
	    	scoreStyle.setBorderLeft(CellStyle.BORDER_THIN);scoreStyle.setLeftBorderColor(cellBorderRed);
	    	scoreStyle.setBorderRight(CellStyle.BORDER_THIN);scoreStyle.setRightBorderColor(cellBorderRed);
	    	scoreStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
	        scoreStyle.setAlignment(CellStyle.ALIGN_CENTER);
	    	
	    	XSSFFont solution = (XSSFFont) workbook.createFont();
	    	solution.setBold(true);
	    	solution.setColor(new XSSFColor(new java.awt.Color(37, 63, 255)));
	        
	        
	        XSSFFont truePositive = (XSSFFont) workbook.createFont();
	        truePositive.setBold(true);
	        truePositive.setColor(new XSSFColor(new java.awt.Color(43, 230, 0)));
	        
	        XSSFFont falsePositive = (XSSFFont) workbook.createFont();
	        falsePositive.setBold(true);
	        falsePositive.setColor(new XSSFColor(new java.awt.Color(255, 56, 23)));
	        
	        XSSFFont falseNegative = (XSSFFont) workbook.createFont();
	        falseNegative.setBold(true);
	        falseNegative.setColor(new XSSFColor(new java.awt.Color(191, 192, 180)));
	        
	        XSSFFont bold = (XSSFFont) workbook.createFont();
	        bold.setBold(true);
	        
	        XSSFCellStyle wrap =  (XSSFCellStyle) workbook.createCellStyle();
	        wrap.setWrapText(true);
	        wrap.setFillForegroundColor(null);
	    	CreationHelper createHelper = workbook.getCreationHelper();
			CellStyle answerCellStyle = workbook.createCellStyle();
			answerCellStyle.setWrapText(true);
			
			///-----end styles
	    	Sheet sheet = workbook.createSheet("IQ Results");
	    	sheet.createFreezePane(2, 3);
	        Integer r = 0;
	        Integer c = 0;
	        
	        //headers

	        Row userIdRow = sheet.createRow(r); 
	        userIdRow.createCell(c).setCellValue("ID");
	        r = r+1;
	        c = c+1;
	        userIdRow.createCell(c).setCellValue("User ID");
	        Row usernameRow = sheet.createRow(r); r = r+1;
	        usernameRow.createCell(c).setCellValue("Usernames");
	        Row nameRow = sheet.createRow(r); r= r+1;
	        nameRow.createCell(c).setCellValue("Name");
	        
	        ArrayList<Row> rows = new ArrayList();
	        rows.add(userIdRow);
	        rows.add(usernameRow);
	        rows.add(nameRow);
	        
	        userIdRow.createCell(c+1).setCellValue("Defined Answers");
	        
	        List<IQCase> caseList = iexam.getExercise().getActiveCases();
	        Hashtable questionTable = new Hashtable();
	        Hashtable commentsTable = new Hashtable();
	        int questionRowOffset = r;
	        XSSFCellStyle rowColor = rowColor1;
	        for (IQCase icase: caseList) {
	        	CaseXMLParser parser = new CaseXMLParser();
	        	//icase = parser.parseCase(icase.getCaseXml(), icase);
	        	if (rowColor.equals(rowColor2)) rowColor = rowColor1;
	        	else rowColor = rowColor2;
	        	
	        	for (IQQuestion question: icase.getQuestionList()) {
	        		String id = icase.getCaseId() + "|" + question.getQuestionTextId();
	        		Row row = sheet.createRow(r);
	        		row.setRowStyle(rowColor);
	        		row.createCell(c-1).setCellValue(icase.getCaseId());
	        		row.createCell(c).setCellValue(icase.getCaseName() + " - " + question.getQuestionTextId());
	        		Cell answerCell = row.createCell(c+1);
	        		RichTextString rts = createHelper.createRichTextString(StringUtils.join(question.getAnswerObjList(), "\n"));
	        		rts.applyFont(solution);
	        		answerCell.setCellValue(rts);
	        		row.getCell(c-1).setCellStyle(rowColor);
	        		row.getCell(c).setCellStyle(rowColor);
	        		answerCell.setCellStyle(rowColor);
	        		questionTable.put(id, row);
	        		r = r+1;
	        	}
	        	Row rowComments = sheet.createRow(r);
	        	
	        	rowComments.createCell(c-1).setCellValue(icase.getCaseId());
	        	
	        	String commentId = icase.getCaseId() + "|" + "Comments";
	        	rowComments.createCell(c).setCellValue(icase.getCaseName() + " - Comments");
	        	rowComments.setRowStyle(rowColor);
	        	rowComments.getCell(c-1).setCellStyle(rowColor);
	        	rowComments.getCell(c).setCellStyle(rowColor);
	        	commentsTable.put(commentId, rowComments);
	        	r = r+1;
	        	
	        	Row timeTakenRow = sheet.createRow(r);
	        	timeTakenRow.createCell(c-1).setCellValue(icase.getCaseId());
	        	String timeTakenId = icase.getCaseId() + "|" + "Time";
	        	timeTakenRow.createCell(c).setCellValue(icase.getCaseName() + " - Time Taken (s)");
	        	timeTakenRow.setRowStyle(rowColor);
	        	timeTakenRow.getCell(c-1).setCellStyle(rowColor);
	        	timeTakenRow.getCell(c).setCellStyle(rowColor);
	        	commentsTable.put(timeTakenId, timeTakenRow);
	        	r = r+1;
	        }
	        Row scoreRow = sheet.createRow(r);
	        scoreRow.createCell(c).setCellValue("Total Score");
	        r = r+1;
	        Row truePositivesRow = sheet.createRow(r);
	        	RichTextString rtcHeader = createHelper.createRichTextString("True Positive Count");
	        	rtcHeader.applyFont(truePositive);
	        	truePositivesRow.createCell(c).setCellValue(rtcHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        Row falsePositivesRow = sheet.createRow(r);
	        	RichTextString fpHeader = createHelper.createRichTextString("False Positive Count");
	        	fpHeader.applyFont(falsePositive);
	        	falsePositivesRow.createCell(c).setCellValue(fpHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        Row falseNegativeRow = sheet.createRow(r);
	        	RichTextString fnHeader = createHelper.createRichTextString("False Negative Count");
	        	fnHeader.applyFont(falseNegative);
	        	falseNegativeRow.createCell(c).setCellValue(fnHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        	
	        Row finalGradeRow = sheet.createRow(r);
	        	RichTextString gradeHeader = createHelper.createRichTextString("Final Grade (%)");
	        	finalGradeRow.createCell(c).setCellValue(gradeHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        	
		    Row finalStatusRow = sheet.createRow(r);
	        	RichTextString completedHeader = createHelper.createRichTextString("PASS/FAIL/INCOMPLETE");
	        	finalStatusRow.createCell(c).setCellValue(completedHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        	
	        Row completedQuestionsRow = sheet.createRow(r);
	        	RichTextString completedQuestionsHeader = createHelper.createRichTextString("Finished all questions? (valid > 2020)");
	        	completedQuestionsRow.createCell(c).setCellValue(completedQuestionsHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        	
		    Row totalTimeTakenRow = sheet.createRow(r);
	        	RichTextString timeTakenRowHeader = createHelper.createRichTextString("Time Taken:");
	        	totalTimeTakenRow.createCell(c).setCellValue(timeTakenRowHeader);
	        	r = r+1; //reserve 3 rows for scoring
	        
	        sheet.autoSizeColumn(0);
	        sheet.autoSizeColumn(1);
	        sheet.autoSizeColumn(2);
	        c = c + 2;
	        
//question offset
	        for (IQUserQuiz iquiz: iexam.getUserQuizes()) {
	        	BigDecimal totalScore = new BigDecimal(0);
	        	int truePositives = 0;
	        	int falsePositives = 0;
	        	int falseNegatives = 0;
	        	
	        	userIdRow.createCell(c).setCellValue(iquiz.getUser().getUserId()); 
	        	usernameRow.createCell(c).setCellValue(iquiz.getUser().getUsername()); 
	        	nameRow.createCell(c).setCellValue(iquiz.getUser().getFirstName() + " " + iquiz.getUser().getLastName()); 
	        	
	        	//find the right userquiz
    			for (IQCaseCompleted caseCompleted: iquiz.getCompletedCases()) {
    				IQCase icase = caseCompleted.getAssociatedCase();
    				for (IQUserQuestionAnswered question: caseCompleted.getAnsweredQuestions()) {
    					
    					String id = icase.getCaseId() + "|" + question.getQuestionId();
    					Row questionRow = (Row) questionTable.get(id);
    					if (questionRow == null) {
    						Row newQuestionRow = sheet.createRow(r);
    						newQuestionRow.createCell(0).setCellValue("**UNKNOWN**" + icase.getCaseId() + "| " + icase.getCaseName() + " - " + question.getQuestionId());
    						questionTable.put(id, newQuestionRow);
    						questionRow = newQuestionRow;
    						r = r+1;
    					}
    					Cell answerCell = questionRow.createCell(c);
    					answerCell.setCellStyle(questionRow.getRowStyle());
    					//----USER ANSWERS
    					String resultString = "";
    					//create falseNegatives
    					IQQuestion caseQuestion = icase.getQuestionById(question.getQuestionId());
    					/*if (caseQuestion == null) {
    						caseQuestion = new IQQuestionSearchTerm();
    					}*/
    					//System.out.println("LOOKING FOR QUESTION: " + question.getQuestionId() + " case: " + icase.getCaseName());
    					
    					//color code answers
						/*if (!icase.isParsed()) {
    						CaseXMLParser parser = new CaseXMLParser();
	    					icase = parser.parseCase(icase.getCaseXml(), icase);
    					}*/
    					List<Object[]> styleMap = new ArrayList();
    					if (caseQuestion == null) {
    						resultString = "ERROR: missing case";
    					} else {
							
							if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
		    					for (IQAnswer ca: caseQuestion.getAnswerObjList()) {
	    							if (!resultString.equals(""))//if first one, don't put enterspace
	    								resultString = resultString + "\n";
	    							Object[] styleParam;
		    						if (question.getUserSelections().contains(ca)) {
		    							if (ca.isStatusCorrect()) {
		    								Object[] styleP = {resultString.length(),  resultString.length() + ca.toString().length(), (Object)truePositive}; 
		    								styleParam = styleP;
		    								truePositives = truePositives + 1;
		    							} else {
		    								Object[] styleP = {resultString.length(),  resultString.length() + ca.toString().length(), (Object)falsePositive}; 
		    								styleParam = styleP;
		    								falsePositives = falsePositives + 1;
		    							}
		    							
		    							//
		    						} else {
		    							Object[] styleP = {resultString.length(),  resultString.length() + ca.toString().length(), (Object)falseNegative};
		    							styleParam = styleP;
		    							//falseNegatives = falseNegatives + 1;
		    						}
	    							styleMap.add(styleParam);
	    							resultString = resultString + ca.toString();
		    					}
							} else {
		    					for (IQAnswer a: question.getUserSelections()) {
		    						if (a.toString() != null) {
		    							if (!resultString.equals(""))//if first one, don't put enterspace
		    								resultString = resultString + "\n";
			    						if (caseQuestion.getAnswerObjList().contains(a)) {
			    							//true positives
			    							Object[] styleParam = {resultString.length(),  resultString.length() + a.toString().length(), (Object)truePositive};
			    							styleMap.add(styleParam);
			    							truePositives = truePositives + 1;
										} else if (!a.getAnswer().equals("")) {
											Object[] styleParam = {resultString.length(),  resultString.length() + a.toString().length(), (Object)falsePositive};
			    							styleMap.add(styleParam);
			    							falsePositives = falsePositives + 1;
										}
		    							resultString = resultString + a.toString();
		    						}	
		    						
		    					}
		    					for (IQAnswer ca: caseQuestion.getAnswerObjList()) {
		    						if (!question.getUserSelections().contains(ca)) {
		    							resultString = resultString + "\n";
		    							Object[] styleParam = {resultString.length(),  resultString.length() + ca.toString().length(), (Object)falseNegative};
		    							styleMap.add(styleParam);
		    							resultString = resultString + ca.toString();
		    							falseNegatives = falseNegatives + 1;
		    						}
		    					}
							} 
    					}
    					RichTextString rtc = createHelper.createRichTextString(resultString);
    					
    					//set styles
    					for (Object[] styleParam: styleMap) {
    						rtc.applyFont((Integer) styleParam[0], (Integer) styleParam[1], (XSSFFont) styleParam[2]);
    					}
    					answerCell.setCellValue(rtc);
    					
    				}
    				List<IQCaseComment> caseUserComments = IQCaseComment.getCommentByUserId(caseCompleted.getAssociatedCase().getComments(), iquiz.getUser().getUserId());
    				String commentsId =  icase.getCaseId() + "|" + "Comments";
    				Row comments = (Row) commentsTable.get(commentsId);
    				if (comments == null) {
    					Row newCommentRow = sheet.createRow(r);
						newCommentRow.createCell(1).setCellValue("**UNKNOWN**" + icase.getCaseId() + "| " + icase.getCaseName() + " - Comments");
						
						questionTable.put(commentsId, newCommentRow);
						comments = newCommentRow;
						r = r+1;
    				}
    				Cell cellComments = comments.createCell(c);
    				
    				cellComments.setCellValue(
        					createHelper.createRichTextString(StringUtils.join(caseUserComments, "\n"))
        					);

    				cellComments.setCellStyle(comments.getRowStyle());
    				totalScore.add(caseCompleted.getScore());
    				
    				//add time taken
    				
    				
    	        	String timeTakenId = icase.getCaseId() + "|" + "Time";
    	        	Row timeTakenRow = (Row) commentsTable.get(timeTakenId);
    	        	if (timeTakenRow == null) {
    	        		Row newTimeTakenRow = sheet.createRow(r);
    	        		newTimeTakenRow.createCell(1).setCellValue("**UNKNOWN**" + icase.getCaseId() + "| " + icase.getCaseName() + " - Time Taken");
						
						questionTable.put(timeTakenId, newTimeTakenRow);
						timeTakenRow = newTimeTakenRow;
						r = r+1;
    	        	}
    	        	timeTakenRow.createCell(c).setCellValue(caseCompleted.getSecondsTaken());
    	        	
    	        	Cell timeTakenCell = timeTakenRow.createCell(c);
    	        	DecimalFormat oneDecimal = new DecimalFormat("#.#");
    	        	oneDecimal.setRoundingMode(RoundingMode.HALF_UP);
    	        	timeTakenCell.setCellValue(Double.valueOf(oneDecimal.format((double) caseCompleted.getSecondsTaken())));

    	        	timeTakenCell.setCellStyle(comments.getRowStyle());
    				
    			}
    			DecimalFormat pointsFormat = new DecimalFormat("+#.##;-#.##");
    			DecimalFormat gradeFormat = new DecimalFormat("#.#%");
    			RichTextString scoreCount = createHelper.createRichTextString(pointsFormat.format(totalScore));
    				Cell c1 = scoreRow.createCell(c);
    				c1.setCellStyle(scoreStyle);
    				c1.setCellValue(scoreCount);
	        	RichTextString tpCount = createHelper.createRichTextString(Integer.toString(truePositives));
	        		tpCount.applyFont(truePositive);
	        		Cell c2 = truePositivesRow.createCell(c);
	        		c2.setCellStyle(scoreStyle);
	        		c2.setCellValue(tpCount);
    			RichTextString fpCount = createHelper.createRichTextString(Integer.toString(falsePositives));
	        		fpCount.applyFont(falsePositive);
	        		Cell c3 = falsePositivesRow.createCell(c);
	        		c3.setCellStyle(scoreStyle);
	        		c3.setCellValue(fpCount);
        		RichTextString fnCount = createHelper.createRichTextString(Integer.toString(falseNegatives));
	        		fnCount.applyFont(falseNegative);
	        		Cell c4 = falseNegativeRow.createCell(c);
	        		c4.setCellStyle(scoreStyle);
	        		c4.setCellValue(fnCount);
	        	RichTextString finalGrade = createHelper.createRichTextString(
	        			gradeFormat.format(iquiz.calcTotalGrade())
	        					);
	        		if (iquiz.getPass() != null && iquiz.getPass().booleanValue())
	        			finalGrade.applyFont(truePositive);
	        		else
	        			finalGrade.applyFont(falsePositive);
	        		Cell c5 = finalGradeRow.createCell(c);
	        		c5.setCellStyle(scoreStyle);
	        		c5.setCellValue(finalGrade);
	        	RichTextString passed = createHelper.createRichTextString(
	        			iquiz.isCompleted()?(iquiz.getPass() != null && iquiz.getPass().booleanValue()?"PASSED":"FAILED"):"INCOMPLETE"
	        					);
	        		if (iquiz.isCompleted() && iquiz.getPass() != null & iquiz.getPass().booleanValue())
	        			passed.applyFont(truePositive);
	        		else if (iquiz.isCompleted() && (iquiz.getPass() == null || !iquiz.getPass().booleanValue()))
	        			passed.applyFont(falsePositive);
	        		Cell c6 = finalStatusRow.createCell(c);
	        		c6.setCellStyle(scoreStyle);
	        		c6.setCellValue(passed);
		        RichTextString completedQuestions = createHelper.createRichTextString(
		        			iquiz.isCompleted()?(iquiz.isCompletedAllQuestions()?"FINISHED ALL QUESTIONS":"TIMED OUT"):"INCOMPLETE"
		        					);
		        	if (iquiz.isCompleted() && iquiz.isCompletedAllQuestions())
		        		completedQuestions.applyFont(truePositive);
		        	else
		        		completedQuestions.applyFont(falsePositive);
		        	Cell c7 = completedQuestionsRow.createCell(c);
		        	c7.setCellStyle(scoreStyle);
		        	c7.setCellValue(completedQuestions);
		        
		        DecimalFormat oneDecimal = new DecimalFormat("#.#");
    	        oneDecimal.setRoundingMode(RoundingMode.HALF_UP);
		        RichTextString timeTaken = createHelper.createRichTextString(
		        		oneDecimal.format((double) iquiz.calcTimeTakenMilis()/(1000*60)) + " min"
		        		);
	        		fnCount.applyFont(falseNegative);
	        		Cell c8 = totalTimeTakenRow.createCell(c);
	        		c8.setCellStyle(scoreStyle);
	        		c8.setCellValue(timeTaken);
    			
    			
	        	sheet.autoSizeColumn(c);
	        	c= c+1;
	        }
	        
	        r=r+1;
	        RichTextString rts0 = createHelper.createRichTextString("LEGEND");
	        rts0.applyFont(bold);
	        sheet.createRow(r).createCell(1).setCellValue(rts0);
	        r=r+1;
	        RichTextString rts1 = createHelper.createRichTextString("SG True Positives - GREEN");
	        rts1.applyFont(truePositive);
	        sheet.createRow(r).createCell(1).setCellValue(rts1);
	        r=r+1;
	        RichTextString rts2 = createHelper.createRichTextString("SG False Positives - RED");
	        rts2.applyFont(falsePositive);
	        sheet.createRow(r).createCell(1).setCellValue(rts2);
	        r=r+1;
	        RichTextString rts3 = createHelper.createRichTextString("SG False Negative - GREY");
	        rts3.applyFont(falseNegative);
	        sheet.createRow(r).createCell(1).setCellValue(rts3);
	        r=r+1;
	        
	    	
	        workbook.write(os);
	        workbook.close();
	        os.close();
	        
    	} catch (Exception e) {
    		request.setAttribute("message", "Something went wrong");
    		throw e;
    	}
    	return null;
    }
    
    public ActionForward caseStatistics(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseidstr = request.getParameter("caseid");
    	Long caseId = Long.parseLong(caseidstr);
    	IQCase icase = dataSource.getCase(caseId);

	   List<IQCaseCompleted> ccOld = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c "
		   		+ "WHERE cc.completedCaseId NOT IN (SELECT cc.completedCaseId FROM IQCaseCompleted cc JOIN cc.answers a JOIN cc.associatedCase c WHERE c.caseId = :caseId) "
		   		+ "AND cc.answersText IS NOT NULL AND TRIM(cc.answersText) != ''"
		   		+ "AND c.caseId = :caseId", IQCaseCompleted.class)
			   	.setParameter("caseId", caseId)
		   		.list();
    			
	   _log.debug("Found old cases: " + ccOld.size());
	   
	   List<IQCaseCompleted> ccNew = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c "
		   		+ "WHERE cc.completedCaseId IN (SELECT cc.completedCaseId FROM IQCaseCompleted cc JOIN cc.answers a JOIN cc.associatedCase c WHERE c.caseId = :caseId) "
		   		+ "AND c.caseId = :caseId", IQCaseCompleted.class)
			   	.setParameter("caseId", caseId)
		   		.list();
	   
	   _log.debug("Found new cases: " + ccNew.size());
	   
//	   List<IQCaseCompleted> ccAll = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c "
//		   		+ "WHERE c.caseId = :caseId", IQCaseCompleted.class)
//			   	.setParameter("caseId", caseId)
//		   		.list();
//	   _log.debug("Total cases:" + ccAll.size());
//	   
//	   for (IQCaseCompleted cc : ccOld) {
//		   for (IQCaseCompleted cc2 : ccNew) {
//			   if (cc.getCompletedCaseId().equals(cc2.getCompletedCaseId())) {
//				   _log.debug("OVERLAP!!!" + cc2.getCompletedCaseId());
//			   }
//		   }
//	   }

    	IQSummaryExam iqSummaryExam = new IQSummaryExam();
    	long totalCount = 0;
    	long completedCount = 0;
    	long passCount = 0;
    	BigDecimal totalFailPoints = BigDecimal.ZERO;
    	BigDecimal totalFailPossiblePoints = BigDecimal.ZERO;
    	BigDecimal totalPassPoints = BigDecimal.ZERO;
    	BigDecimal totalPassPossiblePoints = BigDecimal.ZERO;
    	long totalTimeTaken = 0;
    	
    	List<IQCaseCompleted> ccAll = new ArrayList<IQCaseCompleted>();
    	ccAll.addAll(ccOld);
    	ccAll.addAll(ccNew);
    	
    	for (IQCaseCompleted icc: ccAll) {
    		totalCount++;
    		if (icc.isPass() != null) {
    			completedCount++;
    			
    			Long timeTaken = icc.getSecondsTaken();
    			if (timeTaken != null) totalTimeTaken += timeTaken;
    			
    			if (icc.isPass()) {
    				passCount++;
    				totalPassPoints = totalPassPoints.add(icc.getScore());
    				totalPassPossiblePoints = totalPassPossiblePoints.add(icc.getPassScore());
    				// _log.debug("score " + icc.getScore());
    			} else {
    				totalFailPoints = totalFailPoints.add(icc.getScore());
    				totalFailPossiblePoints = totalFailPossiblePoints.add(icc.getPassScore());
    			}
    		}
    	}
    	
    	iqSummaryExam.setTotalCount(totalCount);
    	iqSummaryExam.setCompletedCount(completedCount);
    	iqSummaryExam.setPassCount(passCount);
    	if (completedCount != 0)
    		iqSummaryExam.setMeanTimeTaken(totalTimeTaken/completedCount);
    	if (totalFailPossiblePoints.compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanFailGrade(totalFailPoints.divide(totalFailPossiblePoints, RoundingMode.HALF_UP));
    	if (totalPassPossiblePoints.compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanPassGrade(totalPassPoints.divide(totalPassPossiblePoints, RoundingMode.HALF_UP));
    	if (totalPassPossiblePoints.add(totalFailPossiblePoints).compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanTotalGrade(totalPassPoints.add(totalFailPoints).divide(totalPassPossiblePoints.add(totalFailPossiblePoints), RoundingMode.HALF_UP));
    	
    	
    	List<IQSummaryQ> results = new ArrayList();
    		
//	   List<IQCaseCompleted> ccNew = dataSource.getSession().createQuery("SELECT a FROM IQCaseAnswer a JOIN a.associatedQuestion q "
//		   		+ "AND q.questionId = :caseId", IQCaseCompleted.class)
//			   	.setParameter("caseId", caseId)
//		   		.list();

    		for (IQQuestion question: icase.getQuestionList()) {
    			IQSummaryQ q = new IQSummaryQ();
    			q.setAssociatedCase(icase);
    			q.setComments(icase.getComments());
    			q.setTotalCount(ccAll.size());
    			q.setQuestion(question);
				int totalAnswersForQuestion = 0;
				int totalSecondsTaken = 0;
				
				for (IQCaseCompleted icc: ccAll) {
					if (icc.getSecondsTaken() != null) totalSecondsTaken += icc.getSecondsTaken();
				}

				if (totalAnswersForQuestion != 0) {
					q.setMeanSecondsTaken(totalSecondsTaken/totalAnswersForQuestion);
				}
				
    			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
    				IQQuestionChoice mcq = (IQQuestionChoice) question;
    				IQSummaryMCQ summaryMcq = new IQSummaryMCQ(q);
    				q.setType(q.TYPE_MCQ);
    				
    				List<IQAnswerChoice> choices = mcq.getAssociatedChoices();
    				
    				
    				for (IQAnswerChoice choice: choices) {
    					IQSummaryMCQ.IQSummaryAnswerChoice summaryChoice = summaryMcq.new IQSummaryAnswerChoice();
    					summaryChoice.choice = choice;
    					summaryChoice.count = getCountForChoice(ccOld, question.getQuestionTextId(), choice);
    					Long count = (Long) dataSource.getSession().createQuery("SELECT count(a) FROM IQCaseAnswer a JOIN a.associatedQuestion q "
    							+ "WHERE q.questionId = :questionId AND a.itemId = :itemId AND a.questionType = :questionType", Long.class)
    							.setParameter("questionId", question.getQuestionId())
    							.setParameter("itemId", choice.getChoiceId())
    							.setParameter("questionType", IQQuestion.QUESTION_TYPE_CHOICE)
    							.getSingleResult();
    					summaryChoice.count += count;
    					summaryMcq.getChoices().add(summaryChoice);
    				}
    				results.add(summaryMcq);
    			} else if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_TEXT)) {
    				results.add(new IQSummaryText());
				} else if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
					
					IQSummarySearchTerm summaryST = new IQSummarySearchTerm(q);
					_log.debug("working on ST : " + icase.getCaseName());
					IQQuestionSearchTerm qst = (IQQuestionSearchTerm) question;
					
					List<Object[]> userAnswers = (List<Object[]>) dataSource.getSession().createQuery("SELECT a.itemId, (SELECT st.searchTermString FROM IQAnswerSearchTerm st WHERE st.searchTermId = a.itemId), count(a) as answerCount FROM IQCaseAnswer a JOIN a.associatedQuestion q "
							+ "WHERE q.questionId = :questionId AND a.questionType= :questionType AND a.itemId != null GROUP BY a.itemId ORDER BY answerCount DESC")
							.setParameter("questionId", question.getQuestionId())
							.setParameter("questionType", question.getQuestionType())
							.list();
					_log.debug("questionType: " + question.getQuestionType());
					_log.debug("questionId: " + question.getQuestionId());

					List<Object[]> foundObjects = new ArrayList<Object[]>();
					for (IQAnswerSearchTermLine line : qst.getAssociatedAnswerLines()) {
						for (IQAnswerSearchTermWrapper wrapper : line.getAssociatedAnswerWrappers()) {

							long count = 0;
							
							for (Object[] result : userAnswers) {
								if (result[0].equals(wrapper.getSearchTerm().getSearchTermId())) {
									count = count + (long) result[2];
									foundObjects.add(result);
								} 
							}
							
							// _log.debug("remaining: " + userAnswers.size());
	    					IQSummarySearchTerm.Answer answer = summaryST.new Answer();
	    					answer.count = count;
	    					answer.correct = wrapper.isCorrectAnswer();
	    					answer.primary = wrapper.isPrimaryAnswer();
	    					answer.text = wrapper.getSearchTerm().getSearchTermString();
	    					answer.onAnswerKey = true;
	    					summaryST.getAnswers().add(answer);
						}
					}
					
					userAnswers.removeAll(foundObjects);
					for (Object[] remainingAnswer : userAnswers) {
    					IQSummarySearchTerm.Answer answer = summaryST.new Answer();
    					answer.count = (long) remainingAnswer[2];
    					answer.text = (String) remainingAnswer[1];
    					answer.itemId = (long) remainingAnswer[0];
    					answer.correct = false;
    					answer.primary = false;
    					answer.onAnswerKey = false;
    					summaryST.getAnswers().add(answer);
					}
					results.add(summaryST);
					
				}
    		}

    	request.setAttribute("resultsExam", iqSummaryExam);
    	request.setAttribute("results", results);
    	_log.debug("found results: " + results.size());
    	return new ActionForward("/results/questionStatistics.jsp");
    }
    
    public ActionForward questionStatistics(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examidstr = request.getParameter("examid");
    	Long examid = Long.parseLong(examidstr);
    	IQExam exam = dataSource.getExamById(examid);
    	IQExercise exercise = exam.getExercise();
    	List<IQCase> icases = exercise.getActiveCases(dataSource);
    	
    	IQSummaryExam iqSummaryExam = new IQSummaryExam();
    	long totalCount = 0;
    	long completedCount = 0;
    	long passCount = 0;
    	BigDecimal totalFailPoints = BigDecimal.ZERO;
    	BigDecimal totalFailPossiblePoints = BigDecimal.ZERO;
    	BigDecimal totalPassPoints = BigDecimal.ZERO;
    	BigDecimal totalPassPossiblePoints = BigDecimal.ZERO;
    	long totalTimeTaken = 0;
    
    	for (IQUserQuiz quiz: exam.getUserQuizes()) {
    		totalCount++;
    		if (quiz.isCompleted() && quiz.isCompletedAllQuestions()) {
    			completedCount++;
    			
    			Long timeTaken = quiz.calcTimeTakenMilis();
    			if (timeTaken != null) totalTimeTaken += timeTaken;
    			_log.debug("time taken: " + timeTaken/1000);
    			
    			if (quiz.getPass().booleanValue()) {
    				passCount++;
    				totalPassPoints = totalPassPoints.add(quiz.getScore());
    				totalPassPossiblePoints = totalPassPossiblePoints.add(quiz.getPassScore());
    				_log.debug(quiz.getScore());
    			} else {
    				totalFailPoints = totalFailPoints.add(quiz.getScore());
    				totalFailPossiblePoints = totalFailPossiblePoints.add(quiz.getPassScore());
    			}
    		}
    	}
    	
    	iqSummaryExam.setTotalCount(totalCount);
    	iqSummaryExam.setCompletedCount(completedCount);
    	iqSummaryExam.setPassCount(passCount);
    	if (completedCount != 0)
    		iqSummaryExam.setMeanTimeTaken(totalTimeTaken/completedCount);
    	if (totalFailPossiblePoints.compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanFailGrade(totalFailPoints.divide(totalFailPossiblePoints, RoundingMode.HALF_UP));
    	if (totalPassPossiblePoints.compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanPassGrade(totalPassPoints.divide(totalPassPossiblePoints, RoundingMode.HALF_UP));
    	if (totalPassPossiblePoints.add(totalFailPossiblePoints).compareTo(BigDecimal.ZERO) != 0)
    		iqSummaryExam.setMeanTotalGrade(totalPassPoints.add(totalFailPoints).divide(totalPassPossiblePoints.add(totalFailPossiblePoints), RoundingMode.HALF_UP));
    	
    	
    	List<IQSummaryQ> results = new ArrayList();
    	for (IQCase icase: icases) {
    		
//			List<IQCaseCompleted> list = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc "
//					+ "JOIN cc.associatedCase c "
//					+ "JOIN cc.userQuiz q "
//					+ "JOIN q.associatedExam ex "
//					+ "WHERE ex.examId=:examid AND c.caseId=:caseid", IQCaseCompleted.class)
//			.setParameter("examid", examid)
//			.setParameter("caseid", icase.getCaseId())
//			.list();
			
			   List<IQCaseCompleted> ccOld = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c "
				   		+ "WHERE cc.completedCaseId NOT IN (SELECT cc.completedCaseId FROM IQCaseCompleted cc JOIN cc.answers a JOIN cc.associatedCase c WHERE c.caseId = :caseId) "
				   		+ "AND cc.answersText IS NOT NULL AND TRIM(cc.answersText) != ''"
				   		+ "AND c.caseId = :caseId", IQCaseCompleted.class)
					   	.setParameter("caseId", icase.getCaseId())
				   		.list();
		    			
			   
			   List<IQCaseCompleted> ccNew = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c "
				   		+ "WHERE cc.completedCaseId IN (SELECT cc.completedCaseId FROM IQCaseCompleted cc JOIN cc.answers a JOIN cc.associatedCase c WHERE c.caseId = :caseId) "
				   		+ "AND c.caseId = :caseId", IQCaseCompleted.class)
					   	.setParameter("caseId", icase.getCaseId())
				   		.list();
			   
			   // _log.debug("CASE: " + icase.getCaseName() + " ccOld " + ccOld.size() + " ccNew " + ccNew.size());
			   
			   List<IQCaseCompleted> ccAll = new ArrayList<IQCaseCompleted>();
		    	ccAll.addAll(ccOld);
		    	ccAll.addAll(ccNew);
			
						
    		for (IQQuestion question: icase.getQuestionList()) {
    			
    			
    			
    			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
    				IQQuestionChoice mcq = (IQQuestionChoice) question;
    				IQSummaryMCQ summaryMcq = new IQSummaryMCQ();
    				summaryMcq.setAssociatedCase(icase);
    				summaryMcq.setQuestion(mcq);
    				summaryMcq.setComments(icase.getComments());

    				List<IQAnswerChoice> choices = mcq.getAssociatedChoices();
    				
    				int totalAnswersForQuestion = ccAll.size();
    				int totalSecondsTaken = 0;
    				for (IQCaseCompleted caseCompleted: ccAll) {
    					if (caseCompleted.getSecondsTaken() != null) totalSecondsTaken += caseCompleted.getSecondsTaken();
    				}
    				
    				if (totalAnswersForQuestion != 0) {
    					summaryMcq.setMeanSecondsTaken(totalSecondsTaken/totalAnswersForQuestion);
    				}
    				summaryMcq.setTotalCount(totalAnswersForQuestion);
    				
    				for (IQAnswerChoice choice: choices) {
    					IQSummaryMCQ.IQSummaryAnswerChoice summaryChoice = summaryMcq.new IQSummaryAnswerChoice();
    					summaryChoice.choice = choice;
    					summaryChoice.count = getCountForChoice(ccOld, question.getQuestionTextId(), choice);
    					Long count = (Long) dataSource.getSession().createQuery("SELECT count(a) FROM IQCaseAnswer a JOIN a.associatedQuestion q "
    							+ "WHERE q.questionId = :questionId AND a.itemId = :itemId AND a.questionType = :questionType", Long.class)
    							.setParameter("questionId", question.getQuestionId())
    							.setParameter("itemId", choice.getChoiceId())
    							.setParameter("questionType", IQQuestion.QUESTION_TYPE_CHOICE)
    							.getSingleResult();
    					summaryChoice.count += count;
    					summaryMcq.getChoices().add(summaryChoice);
    				}
    				results.add(summaryMcq);
    			} else if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_TEXT)) {
    				results.add(new IQSummaryText());
				} else if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
					results.add(new IQSummarySearchTerm());
				}
    		}
    	}
    	
    	request.setAttribute("resultsExam", iqSummaryExam);
    	request.setAttribute("results", results);
    	request.setAttribute("exam", exam);
    	request.setAttribute("examId", examid);
    	_log.debug("found results: " + results.size());
    	return new ActionForward("/results/questionStatistics.jsp");
    }
    
    private int getCountForChoice(List<IQCaseCompleted> casesCompleted, String questionId, IQAnswerChoice choice) {
    	int count = 0;
    	for (IQCaseCompleted caseCompleted: casesCompleted) {
	    	for (IQUserQuestionAnswered question: caseCompleted.getAnsweredQuestions()) {
	    		if (question.getQuestionId().equals(questionId)) {
	    			for (IQAnswer answer: question.getUserSelections()) {
	    				if (answer.getAnswer().equals(choice.getAnswerString())) {
	    					count++;
	    				}
	    			}
	    		}
	    	}
    	}
    	return count;
    }
    
    public ActionForward resultsByImageDiagnosis(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examid = request.getParameter("examid");
    	String viewer = request.getParameter("viewer");
    	if (viewer == null) viewer = "";
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examid));
    	List<IQCase> cases = iexam.getExercise().getActiveCases();
    	HashMap<Long, IQCaseSummary> results = new HashMap();
    	for (IQCase icase: cases) {
    		IQCaseSummary ir = new IQCaseSummary();
    		ir.icase = icase;
    		results.put(icase.getCaseId(), ir);
    	}
    	for (IQUserQuiz iquiz :iexam.getUserQuizes()) {
    		BigDecimal totalScore = new BigDecimal(0);
    		
    		for (IQCaseCompleted completedCase: iquiz.getCompletedCases()) {
    			Long caseId = completedCase.getCaseId();
    			IQCaseSummary result = results.get(caseId);
    			if (result != null) {
    				//logic to grade case
    				for (IQUserQuestionAnswered questionAnswered: completedCase.getAnsweredQuestions()) {
    					/*if (!result.icase.isParsed()) {
    		        		CaseXMLParser parser = new CaseXMLParser();
    		        		parser.parseCase(result.icase.getCaseXml(), result.icase);
    		        	}*/
    					IQQuestion solutionQuestion = result.icase.getQuestionById(questionAnswered.getQuestionId());
    					if (solutionQuestion != null) {
	    					for (IQAnswer a :questionAnswered.getUserSelections()) {
	    						if (solutionQuestion.getAnswerObjList().contains(a)) {
	    							//true positive
	    							result.truePositives.add(a);
	    							totalScore.add(a.getScore());
	    						} else {
	    							//false positive
	    							result.falsePositives.add(a);
	    							totalScore.add(solutionQuestion.getWrongChoiceScore());
	    						}
	    					}
	    					for (IQAnswer solution: solutionQuestion.getAnswerObjList()) {
	    						if (!questionAnswered.getUserSelections().contains(solution)) {
	    							//false negative
	    							result.falseNegatives.add(solution);
	    						}
	    					}
	    					result.score = result.score.add(totalScore);
    					}
    				}
        			result.setAnswerCount(result.getAnswerCount()+1);
        			result.setSecondsTaken(result.getSecondsTaken() + completedCase.getSecondsTaken());
        			results.put(completedCase.getCaseId(), result);
    			}

    		}
    	}
    	
    	List<IQCaseSummary> resultsFinal = new ArrayList(results.values());
    	//sort before sending back;
    	Collections.sort(resultsFinal, new Comparator<IQCaseSummary>() {
		    @Override
		    public int compare(IQCaseSummary z1, IQCaseSummary z2) {
		        if (z1.getIcase().getCaseId() < z2.getIcase().getCaseId())
		            return -1;
		        if (z1.getIcase().getCaseId() > z2.getIcase().getCaseId())
		            return 1;
		        return 0;
		    }
		});
    	
    	request.setAttribute("results", resultsFinal);
    	return new ActionForward("/results/resultByImageDx" + viewer + ".jsp");
    }
	
}

