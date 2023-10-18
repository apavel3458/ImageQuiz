/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;

import org.nustaq.serialization.annotations.Version;

/**
 *
 * @author apavel
 */
public class IQAnswer implements Serializable {
    private String answer = "";

    private BigDecimal score = new BigDecimal(1);
    @Version(2)
    private Integer status = 0;
    @Version(2)
	public final static Integer STATUS_NONE = 0;
    @Version(2)
	public final static Integer STATUS_CORRECT = 1;
    @Version(2)
	public final static Integer STATUS_INCORRECT = 2;
    @Version(2)
	public final static Integer STATUS_MISSED = 3;

    public IQAnswer() {
    }
    /**
     * @return the name
     */
    public String getAnswer() {
        return answer;
    }

    /**
     * @param name the name to set
     */
    public void setAnswer(String answer) {
        if (answer == null) answer = "";
        this.answer = answer;
    }
        public BigDecimal getScore() {
                return score;
        }
        public void setScore(BigDecimal score) {
                this.score = score;
        }
        
        public void setScore(IQAnswerSearchTermWrapper w) {
        	this.score = w.getScoreModifier();
        }
        

        @Override
        public String toString() {
                return answer;
        }

        public boolean equals(IQAnswer a) {
                return (this.answer.equalsIgnoreCase(a.getAnswer()));
        }
        public boolean equals(Object a) {
                        return (this.answer.equalsIgnoreCase(((IQAnswer) a).getAnswer()));

        }
        public boolean equals(String a) {
            return (this.answer.equalsIgnoreCase(a));

}
		public Integer getStatus() {
			return status;
		}
		public void setStatus(Integer status) {
			this.status = status;
		}
		
		public boolean isStatusCorrect() {
			if (this.status.equals(STATUS_CORRECT)) {
				return true;
			} else {
				return false;
			}
		}
		public boolean isStatusMissed() {
			if (this.status.equals(STATUS_MISSED)) {
				return true;
			} else {
				return false;
			}
		}
		public boolean isStatusIncorrect() {
			if (this.status.equals(STATUS_INCORRECT)) {
				return true;
			} else {
				return false;
			}
		}

}