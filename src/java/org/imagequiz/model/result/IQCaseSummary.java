package org.imagequiz.model.result;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.question.IQAnswer;

public class IQCaseSummary {
    	public IQCase icase;
    	DecimalFormat pointsFormat = new DecimalFormat("+#.##;-#.##");
    	public BigDecimal score = new BigDecimal(0);
    	public List<IQAnswer> truePositives = new ArrayList();
    	public List<IQAnswer> falsePositives = new ArrayList();
    	public List<IQAnswer> falseNegatives = new ArrayList();
    	private Double secondsTaken = new Double(0);
    	private int answerCount = 0;
    	public IQCase getIcase() { return icase; }
    	public String getScore() { return pointsFormat.format(score); }
    	public List<IQAnswer> getTruePositives() { return truePositives; }
    	public List<IQAnswer> getFalsePositives() { return falsePositives; }
    	public List<IQAnswer> getFalseNegatives() { return falseNegatives; }
    	public List<Item> getTruePositivesSorted() { return sortAndGetCount(truePositives); }
    	public List<Item> getFalsePositivesSorted() { return sortAndGetCount(falsePositives); }
    	public List<Item> getFalseNegativesSorted() { return sortAndGetCount(falseNegatives); }
    	
    	public int getAnswerCount() {
			return answerCount;
		}
		public void setAnswerCount(int answerCount) {
			this.answerCount = answerCount;
		}
		
		public Double getSecondsTaken() {
			return secondsTaken;
		}
		public void setSecondsTaken(Double secondsTaken) {
			this.secondsTaken = secondsTaken;
		}
		public Double getAverageSecondsTaken() {
			return (secondsTaken/answerCount);
		}

    	
    	private List<Item> sortAndGetCount(List<IQAnswer> resultsList) {
    		Set<IQAnswer> set = new HashSet<IQAnswer>(resultsList);
    		List<Item> results = new ArrayList<Item>();
    		if (resultsList == null) return new ArrayList();
    		for (int i= 0; i< resultsList.size(); i++){
    			IQAnswer r = resultsList.get(i);
    			if (r == null || r.getAnswer() == null) resultsList.remove(i);
    		}

    		for (IQAnswer a: set) {
    			if (a != null && a.getAnswer() != null) {
	    			int count = Collections.frequency(resultsList, a);
	    			Item newResult = this.new Item(count, a);
	    			boolean contains = false;
	    			for (Item r: results) {
	    				if (r.result.getAnswer().equalsIgnoreCase(newResult.result.getAnswer()))
	    					contains = true;
	    			}
	    			if (!contains)
	    				results.add(newResult);
    			}
    		}
    		
    		Collections.sort(results, new Comparator<Item>() {
    		    @Override
    		    public int compare(Item z1, Item z2) {
    		        if (z1.occurences > z2.occurences)
    		            return -1;
    		        if (z1.occurences < z2.occurences)
    		            return 1;
    		        return 0;
    		    }
    		});
    		
    		return results;
    	}
    	





		public class Item {
    		public Item(int occurences, IQAnswer result) {
    			this.occurences = occurences;
    			this.result = result;
    		}
    		@Override
    		public boolean equals(Object a) {
    			Item aa = (Item) a;
    			return this.result.equals(aa.result);
    		}
    		public int getOccurences() { return occurences; }
    		public IQAnswer getResult() { return result; }
    		public int occurences;
    		public IQAnswer result;
    	}
    	
    	
}
