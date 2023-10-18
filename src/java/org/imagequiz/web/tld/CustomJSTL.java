package org.imagequiz.web.tld;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;

import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQExam;
import org.springframework.context.ApplicationContext;
import org.springframework.web.servlet.support.RequestContextUtils;

public class CustomJSTL {
	public static Long getSize(IQExam examId, HttpServletRequest request) {
		ApplicationContext context = RequestContextUtils.getWebApplicationContext(request);
		IQDataSource info = (IQDataSource) context.getBean("dataSource");
		return new Long(1);
	}
}
