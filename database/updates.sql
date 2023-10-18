
# -- update Apr 28th
alter table iqcase add column casetext text default NULL;
alter table iqcase add column caseanswertext text default NULL;
alter table iquserquiz add column `fixedquestions` boolean DEFAULT true;
alter table iquserquiz add column `quizname` int(11) NOT NULL;
# -- update June 15
alter table iqcase_answer_searchterm_wrapper change primaryquestion primaryanswer tinyint(1) NOT NULL DEFAULT 1;
alter table iqcase_answer_searchterm_wrapper change scorecorrect scoremodifier decimal(15,4) NOT NULL DEFAULT 0;
alter table iqcase_answer_searchterm_wrapper drop scoreincorrect;
alter table iqcase_answer_searchterm_wrapper add correctanswer tinyint(1) NOT NULL DEFAULT 1;
update iqexercisecaselink set caseorder=0;
   #-- TO reset case order
select @i := -1; update iqexercisecaselink set caseorder = (select @i := @i + 1) where exerciseid=17; 
alter table iqexam add `randomorder` tinyint(1) NOT NULL DEFAULT 1;
ALTER TABLE iqquizcaselink ADD `caseorder` int(11);
# --- June 20

CREATE TABLE iquservar (
    `userid` int(11) not null REFERENCES iquser(userid),
    `name` VARCHAR(256) not null,
    `value` VARCHAR(256) not null,
    PRIMARY KEY (`userid` , `name`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

# --- Apr 25, 2018


CREATE TABLE iqobjectives (
	`objectiveid` int(11) NOT NULL AUTO_INCREMENT,
	`objectivecode` varchar(60) NOT NULL,
	`objectivename` text,
	 PRIMARY KEY (`objectiveid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE iqcase_objectives_link (
    `objectivelinkid` int(11) NOT NULL AUTO_INCREMENT,
	`caseid` int(11) NOT NULL REFERENCES iqcase(caseid),
	`objectiveid` int(11) NOT NULL REFERENCES iqobjectives(objectiveid),
	 PRIMARY KEY (`objectivelinkid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;



# --- Aug 25, 2018
alter table iqcase add column prefix varchar(20) default '';

# --- March 20, 2019
CREATE TABLE iqsetting (
    `settingid` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(60) NOT NULL,
	`value` text NOT NULL,
	 PRIMARY KEY (`settingId`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

#-- Dec 5, 2019
alter table iqexam add column options text NOT NULL;
alter table iquserquiz add column pass tinyint(1) DEFAULT NULL;
alter table iquserquiz add column `score` decimal(15,4) DEFAULT NULL;

#-- Jan 1, 2020
alter table iqcasetag add column `prefix` varchar(20) default '';
alter table iqcasetag add column `resourcesText` text default NULL;
alter table iqcasetag add column `resourcesJson` text default NULL;


CREATE TABLE iquserquiz_performance (
    `performanceid` int(11) NOT NULL AUTO_INCREMENT,
	`quizid` int(11) NOT NULL,
	`tagid` int(11) REFERENCES iqcasetag(tagid),
	`totalScore` decimal(15,4),
	`totalPassScore` decimal(15,4),
	`created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	 PRIMARY KEY (`performanceid`),
	 FOREIGN KEY (quizid) REFERENCES iquserquiz (quizid) ON DELETE CASCADE
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

#-- Jan 4, 2020
drop table iqtaggroup;

ALTER TABLE iqexam add column achievementid int(11) default NULL;

INSERT INTO iquser_achievement (achievementName, achievementShort, level) VALUES ('Coronary Artery Disease', 'CAD', 1);
INSERT INTO iquser_achievement (achievementName, achievementShort, level) VALUES ('Coronary Artery Disease', 'CAD', 2);
INSERT INTO iquser_achievement (achievementName, achievementShort, level) VALUES ('Heart Failure', 'HF', 1);
INSERT INTO iquser_achievement (achievementName, achievementShort, level) VALUES ('Heart Failure', 'HF', 2);

CREATE TABLE iquser_achievement (
    `achievementid` int(11) NOT NULL AUTO_INCREMENT,
	`achievementName` varchar(25) NOT NULL,
	`achievementShort` varchar(25) NOT NULL,
	`level` int(5),
	 PRIMARY KEY (`achievementid`),
	 FOREIGN KEY (userid) REFERENCES iquser (userid)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE iquser_achievement_link (
    `userachievementid` int(11) NOT NULL AUTO_INCREMENT,
	`userid` int(11) NOT NULL,
	`achievementid` int(11) NOT NULL,
	`level` int(5),
	`created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	 PRIMARY KEY (`userachievementid`),
	 FOREIGN KEY (userid) REFERENCES iquser (userid) CASCADE DELETE,
	 FOREIGN KEY (achievementid) REFERENCES iquser_achievement (achievementid) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

#-- Jan 12, 2020
ALTER TABLE iquserquiz ADD COLUMN passScore decimal(15,4) DEFAULT NULL;

#-- Feb 7, 2020
ALTER TABLE iqusergroup ADD COLUMN public boolean NOT NULL DEFAULT true;
ALTER TABLE iquser ADD COLUMN `photoLink` varchar(255) DEFAULT NULL;
ALTER TABLE iquser ADD COLUMN `loginAttempts` int(11) NOT NULL DEFAULT 0;
ALTER TABLE iquser ADD COLUMN `loginCount` int(11) NOT NULL DEFAULT 0;
ALTER TABLE iquser ADD COLUMN `active` boolean DEFAULT true;
ALTER TABLE iquser CHANGE `lastlogin` `lastLogin` datetime DEFAULT NULL;
ALTER TABLE iquser CHANGE `email` `email` varchar(255);
ALTER TABLE iquser ADD COLUMN `email2` varchar(255) DEFAULT NULL;
ALTER TABLE imagequiz.iquser ENGINE=InnoDB;

#-- March 2, 2020
ALTER TABLE imagequiz.iqusergroup ENGINE=InnoDB;
ALTER TABLE imagequiz.iqusergrouplink ENGINE=InnoDB;
ALTER TABLE imagequiz.iquser_achievement_link ENGINE=InnoDB;
ALTER TABLE imagequiz.iquser_achievement ENGINE=InnoDB;
ALTER TABLE iqusergrouplink ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE;
ALTER TABLE iqusergrouplink ADD CONSTRAINT FOREIGN KEY (groupid) REFERENCES iqusergroup(groupid) ON DELETE CASCADE;
alter table iquser_achievement_link drop key userid;
alter table iquser_achievement_link drop key achievementid;
ALTER TABLE iquser_achievement_link ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE;
ALTER TABLE iquser_achievement_link ADD CONSTRAINT FOREIGN KEY (achievementid) REFERENCES iquser_achievement(achievementid) ON DELETE CASCADE;
alter table log_procedure drop foreign key log_procedure_ibfk_1;
ALTER TABLE log_procedure ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE;
#--- March 3, 2020

ALTER TABLE log_procedure ADD COLUMN supervisor varchar(255);
ALTER TABLE log_procedure ADD COLUMN proficiency tinyint(1);
ALTER TABLE log_procedure DROP COLUMN age;
ALTER TABLE log_procedure DROP COLUMN gender;

#--- March 10, 2020
ALTER TABLE iqexamuserquizlink ENGINE=InnoDB;
ALTER TABLE iqexam ENGINE=InnoDB;
ALTER TABLE iquserquiz ENGINE=InnoDB;
ALTER TABLE iquserquizhelper ENGINE=InnoDB;
ALTER TABLE iqexamuserquizlink ADD CONSTRAINT FOREIGN KEY (examid) REFERENCES iqexam(examid) ON DELETE CASCADE;
ALTER TABLE iqexamuserquizlink ADD CONSTRAINT FOREIGN KEY (userquizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE;
ALTER TABLE iquserquiz ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE;
ALTER TABLE iquserquizhelper ADD CONSTRAINT FOREIGN KEY (quizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE;

# --- March 11, 2020
ALTER TABLE iquser_achievement add column icon varchar(255);
ALTER TABLE iquser_achievement add column color varchar(255);
update iquser_achievement set icon="local_hospital", color="#66bb6a" where achievementid=1;
update iquser_achievement set icon="local_hospital", color="#548256" where achievementid=2;
update iquser_achievement set icon="mdi-heart-circle", color="#9b89e2" where achievementid=3;
update iquser_achievement set icon="mdi-heart-circle", color="#64b5f6" where achievementid=4;
update iquser_achievement set icon="timeline", color="#66bb6a" where achievementid=5;
update iquser_achievement set icon="timeline", color="#4f91e8" where achievementid=6;

ALTER TABLE iquser add column level varchar(255);

ALTER TABLE iquserquiz ADD COLUMN examid int(11);
update iquserquiz INNER JOIN iqexamuserquizlink l ON iquserquiz.quizid=l.userquizid SET iquserquiz.examid = l.examid;
drop table iqexamuserquizlink;
ALTER TABLE iquserquiz ADD CONSTRAINT FOREIGN KEY (examid) REFERENCES iqexam(examid) ON DELETE CASCADE;
select count(*) from iqcase_question_answer_wrapper;
drop table iqcase_question_answer_wrapper;
select count(*) from iqcase_question_answer;
drop table iqcase_question_answer;
select count(*) from iqcase_answer_group;
drop table iqcase_answer_group;
select count(*) from iqcase_answer_group_link;
drop table iqcase_answer_group_link;

# --- March 30, 2020 update
ALTER TABLE iquserquiz ADD COLUMN completedAllQuestions boolean DEFAULT false;

ALTER TABLE iqcompletedcase ENGINE=InnoDB;
ALTER TABLE iqcase ENGINE=InnoDB;
ALTER TABLE iqcompletedcase ADD CONSTRAINT FOREIGN KEY (quizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE;
ALTER TABLE iqcompletedcase ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
ALTER TABLE iqquizcaselink ENGINE=InnoDB;
ALTER TABLE iqquizcaselink ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
ALTER TABLE iqquizcaselink ADD CONSTRAINT FOREIGN KEY (quizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE;
ALTER TABLE iqexercise ENGINE=InnoDB;
ALTER TABLE iqexercisecaselink ENGINE=InnoDB;
ALTER TABLE iqexercisecaselink ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
ALTER TABLE iqexercisecaselink ADD CONSTRAINT FOREIGN KEY (exerciseid) REFERENCES iqexercise(exerciseid) ON DELETE CASCADE;
ALTER TABLE iqcasecomment ENGINE=InnoDB;
ALTER TABLE iqcasecomment ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
ALTER TABLE iqcasecomment ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE;
ALTER TABLE iqcase_question ENGINE=InnoDB;
ALTER TABLE iqcase_question ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_choice ENGINE=InnoDB;
ALTER TABLE iqcase_answer_choice ADD CONSTRAINT FOREIGN KEY (questionid) REFERENCES iqcase_question(questionid) ON DELETE CASCADE;

ALTER TABLE iquserquiz_performance ENGINE=InnoDB;
ALTER TABLE iquserquiz_performance ADD CONSTRAINT FOREIGN KEY (quizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE;
ALTER TABLE iqcasetag ENGINE=InnoDB;
ALTER TABLE iqcasetaglink ENGINE=InnoDB;
ALTER TABLE iqcasetaglink ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
ALTER TABLE iqcasetaglink ADD CONSTRAINT FOREIGN KEY (tagid) REFERENCES iqcasetag(tagid) ON DELETE CASCADE;



ALTER TABLE iquservar ENGINE=InnoDB;
ALTER TABLE iquservar ADD CONSTRAINT FOREIGN KEY (userid) REFERENCES iquser(userid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqexercisetaglink ENGINE=InnoDB;
ALTER TABLE iqexercisetaglink ADD CONSTRAINT FOREIGN KEY (exerciseid) REFERENCES iqexercise(exerciseid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqexercisetaglink ADD CONSTRAINT FOREIGN KEY (tagid) REFERENCES iqcasetag(tagid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqexam ADD CONSTRAINT FOREIGN KEY (exerciseid) REFERENCES iqexercise(exerciseid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_question_availablegroup_link ENGINE=InnoDB;
ALTER TABLE iqcase_question_availablegroup_link ADD CONSTRAINT FOREIGN KEY (questionid) REFERENCES iqcase_question(questionid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE iqcaserevisions CHANGE `parentCase` `caseid` int(11) NOT NULL;
ALTER TABLE iqcaserevisions CHANGE `author` `userid` int(11) NOT NULL;
ALTER TABLE iqcaserevisions ENGINE=InnoDB;
ALTER TABLE iqcaserevisions ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE;
 # --
ALTER TABLE iqcase_answer_searchterm ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_group ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_line ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_line ADD CONSTRAINT FOREIGN KEY (questionid) REFERENCES iqcase_question(questionid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_searchterm_section ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_section ADD CONSTRAINT FOREIGN KEY (groupid) REFERENCES iqcase_answer_searchterm_group(groupid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_searchterm_section_link ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_section_link ADD CONSTRAINT FOREIGN KEY (sectionid) REFERENCES iqcase_answer_searchterm_section(sectionid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_searchterm_section_link ADD CONSTRAINT FOREIGN KEY (searchtermid) REFERENCES iqcase_answer_searchterm(searchtermid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_searchterm_wrapper ENGINE=InnoDB;
ALTER TABLE iqcase_answer_searchterm_wrapper ADD CONSTRAINT FOREIGN KEY (lineid) REFERENCES iqcase_answer_searchterm_line(lineid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer_searchterm_wrapper ADD CONSTRAINT FOREIGN KEY (searchtermid) REFERENCES iqcase_answer_searchterm(searchtermid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_objectives_link ENGINE=InnoDB;
ALTER TABLE iqobjectives ENGINE=InnoDB;
ALTER TABLE iqcase_objectives_link ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_objectives_link ADD CONSTRAINT FOREIGN KEY (objectiveid) REFERENCES iqobjectives(objectiveid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE iqcaseimagelink ENGINE=InnoDB;
ALTER TABLE iqimage ENGINE=InnoDB;
ALTER TABLE iqcaseimagelink ADD CONSTRAINT FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcaseimagelink ADD CONSTRAINT FOREIGN KEY (imageid) REFERENCES iqimage(imageid) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE iqsetting ENGINE=InnoDB;
ALTER TABLE iqreference ENGINE=InnoDB;

# -- April 12, 2020
alter table iquserquiz add column tracker json default null;
rename table iqcompletedcase to iqcasecompleted;
alter table iqcasecompleted add column flagged boolean default false;
alter table iqcasecompleted change `completedcaseid` `casecompletedid` int(11) NOT NULL AUTO_INCREMENT;
alter table iqcasecompleted change `answers` `answersB` blob;
alter table iqcasecompleted add column answersJ json; 

CREATE TABLE `iqcase_answer` (
  `answerid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `casecompletedid` int(11) NOT NULL,
  `examid` int(11) NOT NULL,
  `questiontextid` varchar(60) NOT NULL,
  `text` text,
  `status` varchar(60),
  PRIMARY KEY (`answerid`),
  FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  FOREIGN KEY (`casecompletedid`) REFERENCES `iqcasecompleted` (`casecompletedid`) ON DELETE CASCADE,
  FOREIGN KEY (`examid`) REFERENCES `iqexam` (`examid`) ON DELETE CASCADE
) ENGINE=InnoDB;

select alternateanswer, count(*) from iqcase_answer_searchterm_wrapper group by alternateanswer limit 5;
alter table iqcase_answer_searchterm_wrapper drop column alternateanswer

CREATE TABLE `iqcase_authors_link` (
  `authorid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `role` varchar(60) NOT NULL,
  `createdBy` int(11) NOT NULL,
  PRIMARY KEY (`authorid`),
  FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE
) ENGINE=InnoDB;
ALTER TABLE iqcase CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_choice CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm_group CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm_line CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm_section CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm_section_link CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_answer_searchterm_wrapper CONVERT TO CHARACTER SET utf8;

ALTER TABLE iqcase_authors_link CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_objectives_link CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_question CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcase_question_availablegroup_link CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcasecomment CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcasecompleted CONVERT TO CHARACTER SET utf8;

ALTER TABLE iqcaseimagelink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcaserevisions CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcasetag CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqcasetaglink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqexam CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqexercise CONVERT TO CHARACTER SET utf8;

ALTER TABLE iqexercisecaselink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqexercisetaglink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqimage CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqobjectives CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqquizcaselink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqreference CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqsetting CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquser CONVERT TO CHARACTER SET utf8;

ALTER TABLE iquser_achievement CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquser_achievement_link CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqusergroup CONVERT TO CHARACTER SET utf8;
ALTER TABLE iqusergrouplink CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquserquiz CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquserquiz_performance CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquserquizhelper CONVERT TO CHARACTER SET utf8;
ALTER TABLE iquservar CONVERT TO CHARACTER SET utf8;
ALTER TABLE log_procedure CONVERT TO CHARACTER SET utf8;




update iqcase_authors_link set role="Author" where role="author";
update iqcase_authors_link set role="Reviewer" where role="reviewer";
update iqcase_authors_link set role="Copy Editor" where role="copy_editor";


update iqexam set options = "{}" where options='';
SELECT * FROM iqexam WHERE JSON_VALID(options)=0\G;
alter table iqexam change options options JSON;
select questiontype, count(*) from iqcase_question group by questiontype;
update iqcase_question set questiontype="sg" where questiontype="search_term";
update iqcase_question set questiontype2="sg" where questiontype2="search_term";
alter table iqcase_answer add itemid int(11) DEFAULT NULL;
alter table iqcase_answer add questiontype varchar(60) NOT NULL;
alter table iqcase_answer change examid questionid int(11) NOT NULL;
ALTER TABLE iqcase_answer DROP FOREIGN KEY `iqcase_answer_ibfk_3`;
ALTER TABLE iqcase_answer DROP INDEX examid;
ALTER TABLE iqcase_answer CHANGE caseid quizid int(11) NOT NULL;
ALTER TABLE iqcase_answer DROP FOREIGN KEY `iqcase_answer_ibfk_1`;
ALTER TABLE iqcase_answer DROP INDEX caseid;
ALTER TABLE iqcase_answer DROP FOREIGN KEY `iqcase_answer_ibfk_2`;
ALTER TABLE iqcase_answer DROP INDEX casecompletedid;
ALTER TABLE iqcase_answer ADD CONSTRAINT FOREIGN KEY (casecompletedid) REFERENCES iqcasecompleted(casecompletedid) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE iqcase_answer ADD CONSTRAINT FOREIGN KEY (quizid) REFERENCES iquserquiz(quizid) ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE iqcasetag CHANGE resourcesJson resources json;
rename table iquserquiz_performance to iqcasetag_stat;
alter table iqcasetag_stat change totalScore score decimal(15,4) DEFAULT NULL;
alter table iqcasetag_stat change totalPassScore passScore decimal(15,4) DEFAULT NULL;
alter table iqcase_answer add createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
alter table iqcasecompleted change passscore passScore decimal(15,4) DEFAULT NULL;
alter table iqcase_question change passscore passScore decimal(15,4) DEFAULT NULL;
alter table iqcasecompleted add updatedAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
alter table iqcasecompleted add createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
alter table iqcasetag_stat change performanceid statid int(11) UNSIGNED NOT NULL AUTO_INCREMENT;
alter table iqcasecomment change createddatetime createdAt timestamp default CURRENT_TIMESTAMP;


--CREATE TABLE `iqcase_question_completed` (
--  `questioncompletedid` int(11) NOT NULL AUTO_INCREMENT,
--  `questionid` int(11) NOT NULL,
--  `casecompletedid` int(11) NOT NULL,
--  `score` decimal(15,4) NOT NULL DEFAULT '0.0000',
--  `passscore` decimal(15,4) NOT NULL DEFAULT '0.0000',
--  `pass` boolean DEFAULT NULL,
--  PRIMARY KEY (`questioncompletedid`),
--  FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE ON UPDATE CASCADE,
--  FOREIGN KEY (`casecompletedid`) REFERENCES `iqcasecompleted` (`casecompletedid`) ON DELETE CASCADE ON UPDATE CASCADE
--) ENGINE=InnoDB;
CREATE TABLE `iqsurvey` (
  `surveyid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `examid` int(11),
  `quizid` int(11),
  `difficulty` int(11) DEFAULT NULL,
  `time` int(11) DEFAULT NULL,
  `technical` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `details` json,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`surveyid`),
  FOREIGN KEY (`examid`) REFERENCES `iqexam` (`examid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

insert into iquser_achievement (achievementName, achievementShort, level, icon, color) values ('General Internal Medicine', 'GIM', 1, 'museum', '#fd8d8d');
-- ----
alter table iqcase_answer add score decimal(15,4) DEFAULT NULL;
alter table iqcase_answer modify questiontextid varchar(60) DEFAULT NULL;
alter table iquser_achievement drop created;
alter table iquser_achievement_link drop level;
alter table iquser_achievement_link CHANGE created createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
alter table iquser_achievement modify achievementName varchar(50) NOT NULL;
alter table iquser_achievement modify level varchar(10) DEFAULT NULL;
alter table iquserquiz change completedAllQuestions seenAllQuestions boolean DEFAULT false;
alter table iqcasecompleted add seen boolean DEFAULT NULL;
alter table iqcasecompleted add answered boolean DEFAULT NULL;

CREATE TABLE `error` (
  `errorid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` int(11),
  `message` varchar(60),
  `errorMessage` text,
  `stack` text,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`errorid`),
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON UPDATE CASCADE
) ENGINE=InnoDB;
-- ----------

alter table iqcasecomment add reviewed boolean DEFAULT false;
alter table iqcasecomment add reviewedBy int(11) DEFAULT NULL;
alter table iqcasecomment add reviewedAt datetime default NULL;

-- 
alter table iqcase_question add shuffle boolean DEFAULT false;

alter table iquser add invited boolean DEFAULT false;
alter table iquser add invitedAt datetime DEFAULT NULL;
alter table iquser add createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE `mgr_school` (
  `schoolid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `schoolname` varchar(60) NOT NULL,
  PRIMARY KEY (`schoolid`)
) ENGINE=InnoDB;


CREATE TABLE `mgr_rotation` (
  `rotationid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `rotationname` varchar(60) NOT NULL,
  `schoolid` int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`rotationid`),
  FOREIGN KEY (`schoolid`) REFERENCES `mgr_school` (`schoolid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_block` (
  `blockid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `schoolid` int(11) UNSIGNED,
  `blockname` varchar(60),
  `startdate` datetime,
  `enddate` datetime,
  PRIMARY KEY (`blockid`),
  FOREIGN KEY (`schoolid`) REFERENCES `mgr_school` (`schoolid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_userenrollment` (
  `enrollmentid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `blockid` int(11) UNSIGNED NOT NULL,
  `rotationid` int(11) UNSIGNED NOT NULL,
  `enrolledAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remindedAt` datetime DEFAULT NULL,
  `invitedAt` datetime DEFAULT NULL,
  `details` json,
  PRIMARY KEY (`enrollmentid`),
  FOREIGN KEY (`blockid`) REFERENCES `mgr_block` (`blockid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_rotationachievementlink` (
  `rotationachievementid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `rotationid` int(11) UNSIGNED NOT NULL,
  `achievementid` int(11) NOT NULL,
  PRIMARY KEY (`rotationachievementid`),
  FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`achievementid`) REFERENCES `iquser_achievement` (`achievementid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_block` (
  `blockid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `schoolid` int(11) UNSIGNED,
  `blockname` varchar(60),
  `startdate` datetime,
  `enddate` datetime,
  PRIMARY KEY (`blockid`),
  FOREIGN KEY (`schoolid`) REFERENCES `mgr_school` (`schoolid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_userenrollment` (
  `enrollmentid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `blockid` int(11) UNSIGNED NOT NULL,
  `rotationid` int(11) UNSIGNED NOT NULL,
  `enrolledAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remindedAt` datetime DEFAULT NULL,
  `invitedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`enrollmentid`),
  FOREIGN KEY (`blockid`) REFERENCES `mgr_block` (`blockid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mgr_rotationachievementlink` (
  `rotationachievementid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `rotationid` int(11) UNSIGNED NOT NULL,
  `achievementid` int(11) NOT NULL,
  PRIMARY KEY (`rotationachievementid`),
  FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`achievementid`) REFERENCES `iquser_achievement` (`achievementid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


update iquser_achievement set icon='mdi-heart-pulse' where achievementid=5;
update iquser_achievement set icon='mdi-heart-pulse' where achievementid=6;
insert into iquser_achievement (achievementName, achievementShort, level, icon, color) values ('Arrhythmia/Syncope', 'Arrhythmia', 1, 'mdi-heart-flash', '#64b5f6');
insert into iquser_achievement (achievementName, achievementShort, level, icon, color) values ('Arrhythmia/Syncope', 'Arrhythmia', 2, 'mdi-heart-flash', '#4f91e8');
update iquser_achievement set color="#6f62a5" where achievementid=4;
update iquser_achievement set color="#52ccb5" where achievementid=5;
update iquser_achievement set color="#219e81" where achievementid=6;
update iqcasecomment set reviewed=false where reviewed is NULL;
alter table iqcasecomment modify reviewed boolean NOT NULL DEFAULT false;

CREATE TABLE `iquser_permission` (
  `permissionid` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `item` varchar(60),
  `itemid` int(11) NOT NULL,
  `details` json,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdById` int(11) NOT NULL,
  PRIMARY KEY (`permissionid`),
  FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

alter table iquserquiz add options json;
alter table iquser_achievement_link add grantedBy json;

-- Imagequiz update Nov 1, 2020
ALTER TABLE mgr_rotation ADD details json;

CREATE TABLE `iqlog` (
  `logid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11),
  `module` varchar(60),
  `message` text,
  `details` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`logid`),
  KEY `userid` (`userid`)
) ENGINE=InnoDB;

alter table iqcase_question add options json
alter table iqcase_answer_searchterm_line add `primaryanswer` tinyint(1) NOT NULL DEFAULT '1';
alter table iqcase_answer_searchterm_line add `scoremodifier` decimal(15,4) NOT NULL DEFAULT '0.0000';
alter table iqcase_answer_searchterm_line add `scoremissed` decimal(15,4) DEFAULT NULL;
alter table iqcase_answer_searchterm_line add `correctanswer` tinyint(1) NOT NULL DEFAULT '1'
ALTER TABLE iqcase_question CHANGE questiontype2 questiontype_java varchar(100) NOT NULL;

INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('PFT', 'PFT', 1, 'mdi-lung', '#eed478');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('POC-US', 'POCUS', 1, 'mdi-wifi', '#74c8f1');

alter table iquser add options json
--alter table iqcase_question add questiontype_java varchar(20);
--update iqcase_question set questiontype_java = questiontype;
--  `primaryanswer` tinyint(1) NOT NULL DEFAULT '1',
--  `scoremodifier` decimal(15,4) NOT NULL DEFAULT '0.0000',
--  `scoremissed` decimal(15,4) DEFAULT NULL,
--  `correctanswer` tinyint(1) NOT NULL DEFAULT '1',

