
CREATE TABLE `iqcase` (
  `caseid` int(11) NOT NULL AUTO_INCREMENT,
  `casename` varchar(60) DEFAULT NULL,
  `casexml` text,
  `difficulty` int(5) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `casetext` text,
  `caseanswertext` text,
  `displaytype` int(1) DEFAULT '0',
  `editortype` varchar(20) DEFAULT '',
  `prefix` varchar(20) DEFAULT '',
  PRIMARY KEY (`caseid`)
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_choice` (
  `choiceid` int(11) NOT NULL AUTO_INCREMENT,
  `questionid` int(11) NOT NULL,
  `answerstring` text,
  `correct` tinyint(1) DEFAULT NULL,
  `selectscore` decimal(15,4) DEFAULT NULL,
  `missscore` decimal(15,4) DEFAULT NULL,
  PRIMARY KEY (`choiceid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_answer_choice_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm` (
  `searchtermid` int(11) NOT NULL AUTO_INCREMENT,
  `searchtermstring` varchar(200) DEFAULT NULL,
  `searchkeys` text,
  PRIMARY KEY (`searchtermid`),
  UNIQUE KEY `searchtermstring` (`searchtermstring`)
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm_group` (
  `groupid` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`groupid`),
  UNIQUE KEY `groupname` (`groupname`)
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm_line` (
  `lineid` int(11) NOT NULL AUTO_INCREMENT,
  `questionid` int(11) NOT NULL,
  PRIMARY KEY (`lineid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_answer_searchterm_line_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm_section` (
  `sectionid` int(11) NOT NULL AUTO_INCREMENT,
  `groupid` int(11) DEFAULT NULL,
  `sectionname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`sectionid`),
  KEY `groupid` (`groupid`),
  CONSTRAINT `iqcase_answer_searchterm_section_ibfk_1` FOREIGN KEY (`groupid`) REFERENCES `iqcase_answer_searchterm_group` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm_section_link` (
  `linkid` int(11) NOT NULL AUTO_INCREMENT,
  `sectionid` int(11) DEFAULT NULL,
  `searchtermid` int(11) DEFAULT NULL,
  PRIMARY KEY (`linkid`),
  KEY `sectionid` (`sectionid`),
  KEY `searchtermid` (`searchtermid`),
  CONSTRAINT `iqcase_answer_searchterm_section_link_ibfk_1` FOREIGN KEY (`sectionid`) REFERENCES `iqcase_answer_searchterm_section` (`sectionid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_answer_searchterm_section_link_ibfk_2` FOREIGN KEY (`searchtermid`) REFERENCES `iqcase_answer_searchterm` (`searchtermid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_answer_searchterm_wrapper` (
  `wrapperid` int(11) NOT NULL AUTO_INCREMENT,
  `lineid` int(11) NOT NULL,
  `searchtermid` int(11) DEFAULT NULL,
  `primaryanswer` tinyint(1) NOT NULL DEFAULT '1',
  `scoremodifier` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `scoremissed` decimal(15,4) DEFAULT NULL,
  `correctanswer` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`wrapperid`),
  KEY `lineid` (`lineid`),
  KEY `searchtermid` (`searchtermid`),
  CONSTRAINT `iqcase_answer_searchterm_wrapper_ibfk_1` FOREIGN KEY (`lineid`) REFERENCES `iqcase_answer_searchterm_line` (`lineid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_answer_searchterm_wrapper_ibfk_2` FOREIGN KEY (`searchtermid`) REFERENCES `iqcase_answer_searchterm` (`searchtermid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_objectives_link` (
  `objectivelinkid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `objectiveid` int(11) NOT NULL,
  PRIMARY KEY (`objectivelinkid`),
  KEY `caseid` (`caseid`),
  KEY `objectiveid` (`objectiveid`),
  CONSTRAINT `iqcase_objectives_link_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_objectives_link_ibfk_2` FOREIGN KEY (`objectiveid`) REFERENCES `iqobjectives` (`objectiveid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_question` (
  `questionid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `questiontype` varchar(100) NOT NULL,
  `questiontext` text NOT NULL,
  `passscore` decimal(15,4) DEFAULT NULL,
  `scoreincorrectchoice` decimal(15,4) DEFAULT NULL,
  `questiontextid` varchar(100) DEFAULT NULL,
  `questiontype2` varchar(100) NOT NULL,
  `height` int(3) DEFAULT NULL,
  `maxUserSelections` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`questionid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcase_question_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcase_question_availablegroup_link` (
  `linkid` int(11) NOT NULL AUTO_INCREMENT,
  `groupid` int(11) DEFAULT NULL,
  `questionid` int(11) DEFAULT NULL,
  PRIMARY KEY (`linkid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_question_availablegroup_link_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcasecomment` (
  `commentid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `text` text NOT NULL,
  `createddatetime` datetime NOT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`commentid`),
  KEY `caseid` (`caseid`),
  KEY `userid` (`userid`),
  CONSTRAINT `iqcasecomment_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqcasecomment_ibfk_2` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE `iqcaseimagelink` (
  `caseimageid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `imageid` int(11) NOT NULL,
  PRIMARY KEY (`caseimageid`),
  FOREIGN KEY (caseid) REFERENCES iqcase(caseid) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (imageid) REFERENCES iqimage(imageid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcaserevisions` (
  `revisionid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `caseid` int(11) NOT NULL,
  `casexml` text,
  `casexmldiff` text,
  `contributionWeight` int(11) DEFAULT NULL,
  `datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `role` varchar(40) DEFAULT '',
  PRIMARY KEY (`revisionid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcaserevisions_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcasetag` (
  `tagid` int(11) NOT NULL AUTO_INCREMENT,
  `tagname` varchar(60) DEFAULT NULL,
  `prefix` varchar(20) DEFAULT '',
  `resourcesText` text,
  `resourcesJson` text,
  PRIMARY KEY (`tagid`)
) ENGINE=InnoDB;

CREATE TABLE `iqcasetaglink` (
  `casetagid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `tagid` int(11) NOT NULL,
  PRIMARY KEY (`casetagid`),
  KEY `caseid` (`caseid`),
  KEY `tagid` (`tagid`),
  CONSTRAINT `iqcasetaglink_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqcasetaglink_ibfk_2` FOREIGN KEY (`tagid`) REFERENCES `iqcasetag` (`tagid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqcasecompleted` (
  `casecompletedid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `quizid` int(11) NOT NULL,
  `answersB` blob,
  `answers` json,
  `score` decimal(15,4) DEFAULT NULL,
  `passscore` decimal(15,4) DEFAULT NULL,
  `pass` tinyint(1) DEFAULT NULL,
  `secondstaken` int(11) DEFAULT NULL,
  `flagged` boolean default false,
  `answers` json,
  PRIMARY KEY (`completedcaseid`),
  KEY `quizid` (`quizid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcompletedcase_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE,
  CONSTRAINT `iqcompletedcase_ibfk_2` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqexam` (
  `examid` int(11) NOT NULL AUTO_INCREMENT,
  `examname` varchar(60) DEFAULT NULL,
  `exerciseid` int(11) DEFAULT NULL,
  `usergroupid` int(11) DEFAULT NULL,
  `uniquecode` varchar(60) DEFAULT NULL,
  `timelimit` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '0',
  `deleted` tinyint(1) DEFAULT '0',
  `exammode` varchar(20) DEFAULT 'exam',
  `randomorder` tinyint(1) NOT NULL DEFAULT '1',
  `options` text NOT NULL,
  `achievementid` int(11) DEFAULT NULL,
  PRIMARY KEY (`examid`),
  KEY `exerciseid` (`exerciseid`),
  CONSTRAINT `iqexam_ibfk_1` FOREIGN KEY (`exerciseid`) REFERENCES `iqexercise` (`exerciseid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqexercise` (
  `exerciseid` int(11) NOT NULL AUTO_INCREMENT,
  `exerciseName` varchar(60) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`exerciseid`),
  UNIQUE KEY `singlename` (`exerciseName`)
) ENGINE=InnoDB;

CREATE TABLE `iqexercisecaselink` (
  `exercisecaselinkid` int(11) NOT NULL AUTO_INCREMENT,
  `exerciseid` int(11) NOT NULL,
  `caseid` int(11) NOT NULL,
  `caseorder` int(11) DEFAULT NULL,
  PRIMARY KEY (`exercisecaselinkid`),
  KEY `caseid` (`caseid`),
  KEY `exerciseid` (`exerciseid`),
  CONSTRAINT `iqexercisecaselink_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqexercisecaselink_ibfk_2` FOREIGN KEY (`exerciseid`) REFERENCES `iqexercise` (`exerciseid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqexercisetaglink` (
  `exercisetagid` int(11) NOT NULL AUTO_INCREMENT,
  `exerciseid` int(11) NOT NULL,
  `tagid` int(11) NOT NULL,
  PRIMARY KEY (`exercisetagid`),
  KEY `exerciseid` (`exerciseid`),
  KEY `tagid` (`tagid`),
  CONSTRAINT `iqexercisetaglink_ibfk_1` FOREIGN KEY (`exerciseid`) REFERENCES `iqexercise` (`exerciseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqexercisetaglink_ibfk_2` FOREIGN KEY (`tagid`) REFERENCES `iqcasetag` (`tagid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqimage` (
  `imageid` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(60) DEFAULT NULL,
  `description` text,
  `createddate` datetime DEFAULT '2018-05-17 10:55:31',
  `createdby` int(11) NOT NULL DEFAULT '2',
  PRIMARY KEY (`imageid`)
) ENGINE=InnoDB;

CREATE TABLE `iqobjectives` (
  `objectiveid` int(11) NOT NULL AUTO_INCREMENT,
  `objectivecode` varchar(60) NOT NULL,
  `objectivename` text,
  PRIMARY KEY (`objectiveid`)
) ENGINE=InnoDB;

CREATE TABLE `iqquizcaselink` (
  `quizcaseid` int(11) NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `caseid` int(11) NOT NULL,
  `caseorder` int(11) DEFAULT NULL,
  PRIMARY KEY (`quizcaseid`),
  KEY `caseid` (`caseid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iqquizcaselink_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqquizcaselink_ibfk_2` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqreference` (
  `referenceid` int(11) NOT NULL AUTO_INCREMENT,
  `searchtext` varchar(100) NOT NULL,
  `replacelink` text NOT NULL,
  PRIMARY KEY (`referenceid`)
) ENGINE=InnoDB;

CREATE TABLE `iqsetting` (
  `settingid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`settingid`)
) ENGINE=InnoDB;

CREATE TABLE `iquser` (
  `userid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(60) DEFAULT NULL,
  `password` varchar(256) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `lastname` varchar(60) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `lastLogin` datetime DEFAULT NULL,
  `totalminutes` int(11) DEFAULT NULL,
  `firstname` varchar(60) DEFAULT NULL,
  `photoLink` varchar(255) DEFAULT NULL,
  `loginAttempts` int(11) NOT NULL DEFAULT '0',
  `loginCount` int(11) NOT NULL DEFAULT '0',
  `active` tinyint(1) DEFAULT '1',
  `email2` varchar(255) DEFAULT NULL,
  `level` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB;

CREATE TABLE `iquser_achievement` (
  `achievementid` int(11) NOT NULL AUTO_INCREMENT,
  `achievementName` varchar(25) NOT NULL,
  `achievementShort` varchar(25) NOT NULL,
  `level` int(5) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`achievementid`)
) ENGINE=InnoDB;

CREATE TABLE `iquser_achievement_link` (
  `userachievementid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `achievementid` int(11) NOT NULL,
  `level` int(5) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userachievementid`),
  KEY `userid` (`userid`),
  KEY `achievementid` (`achievementid`),
  CONSTRAINT `iquser_achievement_link_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iquser_achievement_link_ibfk_2` FOREIGN KEY (`achievementid`) REFERENCES `iquser_achievement` (`achievementid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iqusergroup` (
  `groupid` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(60) DEFAULT NULL,
  `public` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`groupid`)
) ENGINE=InnoDB;

CREATE TABLE `iqusergrouplink` (
  `usergroupid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `groupid` int(11) NOT NULL,
  PRIMARY KEY (`usergroupid`),
  KEY `userid` (`userid`),
  KEY `groupid` (`groupid`),
  CONSTRAINT `iqusergrouplink_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iqusergrouplink_ibfk_2` FOREIGN KEY (`groupid`) REFERENCES `iqusergroup` (`groupid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iquserquiz` (
  `quizid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `completed` tinyint(1) DEFAULT '0',
  `dateStarted` datetime DEFAULT NULL,
  `dateLastActive` datetime DEFAULT NULL,
  `fixedquestions` tinyint(1) DEFAULT '1',
  `quizname` varchar(60) DEFAULT '',
  `pass` tinyint(1) DEFAULT NULL,
  `score` decimal(15,4) DEFAULT NULL,
  `passScore` decimal(15,4) DEFAULT NULL,
  `examid` int(11) DEFAULT NULL,
  `completedAllQuestions` tinyint(1) DEFAULT '0',
  `tracker` json default null,
  PRIMARY KEY (`quizid`),
  KEY `userid` (`userid`),
  KEY `examid` (`examid`),
  CONSTRAINT `iquserquiz_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iquserquiz_ibfk_2` FOREIGN KEY (`examid`) REFERENCES `iqexam` (`examid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iquserquiz_performance` (
  `performanceid` int(11) NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `tagid` int(11) DEFAULT NULL,
  `totalScore` decimal(15,4) DEFAULT NULL,
  `totalPassScore` decimal(15,4) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`performanceid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iquserquiz_performance_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iquserquizhelper` (
  `helperid` int(11) NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `completedids` text,
  `incompleteids` text,
  `performance` text,
  PRIMARY KEY (`helperid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iquserquizhelper_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `iquservar` (
  `userid` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `value` varchar(256) NOT NULL,
  PRIMARY KEY (`userid`,`name`),
  CONSTRAINT `iquservar_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `log_procedure` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `public` tinyint(1) DEFAULT '0',
  `pin` varchar(255) DEFAULT NULL,
  `comment` text,
  `eventDate` datetime DEFAULT NULL,
  `procedureType` varchar(255) DEFAULT NULL,
  `procedureTypeLong` varchar(255) DEFAULT NULL,
  `details` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `supervisor` varchar(255) DEFAULT NULL,
  `proficiency` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`),
  CONSTRAINT `log_procedure_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE
) ENGINE=InnoDB;

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

insert into iquser (username, password, lastname, firstname, email, admin) values ('admin', sha2('admin', 256), 'Admin', 'Admin', 'xxxx@gmail.com', true);
insert into iquser (username, password, lastname, firstname, email) values ('user1', sha2('test', 256), 'user@user.org', 'User', 'First');
insert into iquser (username, password, lastname, firstname, email) values ('guest', sha2('guest3458', 256), 'guest@guest.org', 'Guest', 'Guest');
insert into iqexercise (exerciseName) values ('Public');
insert into iqusergroup (groupname) values ('Public');
insert into iqusergroup (groupname) values ('Research');

INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('Coronary Artery Disease', 'CAD', 1, 'local_hospital', '#66bb6a');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('Coronary Artery Disease', 'CAD', 2, 'local_hospital', '#548256');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('Heart Failure', 'HF', 1, 'mdi-heart-circle', '#9b89e2');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('Heart Failure', 'HF', 2, 'mdi-heart-circle', '#6f62a5');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('ECG Interpretation', 'ECG', 1, 'timeline', '#66bb6a');
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES ('ECG Interpretation', 'ECG', 2, 'timeline', '#4f91e8');

