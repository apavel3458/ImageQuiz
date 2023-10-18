package imagequiz;

import org.apache.log4j.Logger;


public class TestLog {

	    private static Logger _log = Logger.getLogger(TestLog.class);


	public static void main(String[] args) {
				_log.trace("Trace");

				_log.debug("Debug");

				_log.info("Info");

				_log.warn("Warn");

				_log.error("Error");

				_log.fatal("Fatal");


	
	}
}
