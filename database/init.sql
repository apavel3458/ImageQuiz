-- MySQL dump 10.13  Distrib 5.7.32, for Linux (x86_64)
--
-- Host: localhost    Database: imagequiz
-- ------------------------------------------------------
-- Server version	5.7.32-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `con_test`
--

DROP TABLE IF EXISTS `con_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `con_test` (
  `a` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `error`
--

DROP TABLE IF EXISTS `error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `error` (
  `errorid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `message` varchar(60) DEFAULT NULL,
  `errorMessage` text,
  `stack` text,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`errorid`),
  KEY `userid` (`userid`),
  CONSTRAINT `error_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase`
--

DROP TABLE IF EXISTS `iqcase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase` (
  `caseid` int(11) NOT NULL AUTO_INCREMENT,
  `casename` varchar(60) DEFAULT NULL,
  `casexml` mediumtext,
  `difficulty` int(5) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `casetext` mediumtext,
  `caseanswertext` mediumtext,
  `displaytype` int(1) DEFAULT '0',
  `editortype` varchar(20) DEFAULT '',
  `prefix` varchar(20) DEFAULT '',
  PRIMARY KEY (`caseid`)
) ENGINE=InnoDB AUTO_INCREMENT=724 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer`
--

DROP TABLE IF EXISTS `iqcase_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer` (
  `answerid` int(11) NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `casecompletedid` int(11) NOT NULL,
  `questionid` int(11) NOT NULL,
  `questiontextid` varchar(60) DEFAULT NULL,
  `text` mediumtext,
  `status` varchar(60) DEFAULT NULL,
  `itemid` int(11) DEFAULT NULL,
  `questiontype` varchar(60) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `score` decimal(15,4) DEFAULT NULL,
  PRIMARY KEY (`answerid`),
  KEY `casecompletedid` (`casecompletedid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iqcase_answer_ibfk_1` FOREIGN KEY (`casecompletedid`) REFERENCES `iqcasecompleted` (`casecompletedid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_answer_ibfk_2` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20367 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_choice`
--

DROP TABLE IF EXISTS `iqcase_answer_choice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_choice` (
  `choiceid` int(11) NOT NULL AUTO_INCREMENT,
  `questionid` int(11) NOT NULL,
  `answerstring` mediumtext,
  `correct` tinyint(1) DEFAULT NULL,
  `selectscore` decimal(15,4) DEFAULT NULL,
  `missscore` decimal(15,4) DEFAULT NULL,
  PRIMARY KEY (`choiceid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_answer_choice_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8767 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_searchterm` (
  `searchtermid` int(11) NOT NULL AUTO_INCREMENT,
  `searchtermstring` varchar(200) DEFAULT NULL,
  `searchkeys` mediumtext,
  PRIMARY KEY (`searchtermid`),
  UNIQUE KEY `searchtermstring` (`searchtermstring`)
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm_group`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_searchterm_group` (
  `groupid` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`groupid`),
  UNIQUE KEY `groupname` (`groupname`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm_line`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm_line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_searchterm_line` (
  `lineid` int(11) NOT NULL AUTO_INCREMENT,
  `questionid` int(11) NOT NULL,
  `primaryanswer` tinyint(1) NOT NULL DEFAULT '1',
  `scoremodifier` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `scoremissed` decimal(15,4) DEFAULT NULL,
  `correctanswer` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`lineid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_answer_searchterm_line_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3242 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm_section`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_searchterm_section` (
  `sectionid` int(11) NOT NULL AUTO_INCREMENT,
  `groupid` int(11) DEFAULT NULL,
  `sectionname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`sectionid`),
  KEY `groupid` (`groupid`),
  CONSTRAINT `iqcase_answer_searchterm_section_ibfk_1` FOREIGN KEY (`groupid`) REFERENCES `iqcase_answer_searchterm_group` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm_section_link`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm_section_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_answer_searchterm_section_link` (
  `linkid` int(11) NOT NULL AUTO_INCREMENT,
  `sectionid` int(11) DEFAULT NULL,
  `searchtermid` int(11) DEFAULT NULL,
  PRIMARY KEY (`linkid`),
  KEY `sectionid` (`sectionid`),
  KEY `searchtermid` (`searchtermid`),
  CONSTRAINT `iqcase_answer_searchterm_section_link_ibfk_1` FOREIGN KEY (`sectionid`) REFERENCES `iqcase_answer_searchterm_section` (`sectionid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_answer_searchterm_section_link_ibfk_2` FOREIGN KEY (`searchtermid`) REFERENCES `iqcase_answer_searchterm` (`searchtermid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=216 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_answer_searchterm_wrapper`
--

DROP TABLE IF EXISTS `iqcase_answer_searchterm_wrapper`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3400 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_authors_link`
--

DROP TABLE IF EXISTS `iqcase_authors_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_authors_link` (
  `authorid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `role` varchar(60) NOT NULL,
  `createdBy` int(11) NOT NULL,
  PRIMARY KEY (`authorid`),
  KEY `caseid` (`caseid`),
  KEY `userid` (`userid`),
  CONSTRAINT `iqcase_authors_link_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqcase_authors_link_ibfk_2` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=590 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_objectives_link`
--

DROP TABLE IF EXISTS `iqcase_objectives_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_objectives_link` (
  `objectivelinkid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `objectiveid` int(11) NOT NULL,
  PRIMARY KEY (`objectivelinkid`),
  KEY `caseid` (`caseid`),
  KEY `objectiveid` (`objectiveid`),
  CONSTRAINT `iqcase_objectives_link_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcase_objectives_link_ibfk_2` FOREIGN KEY (`objectiveid`) REFERENCES `iqobjectives` (`objectiveid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3286 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_question`
--

DROP TABLE IF EXISTS `iqcase_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_question` (
  `questionid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `questiontype` varchar(100) NOT NULL,
  `questiontext` mediumtext NOT NULL,
  `passScore` decimal(15,4) DEFAULT NULL,
  `scoreincorrectchoice` decimal(15,4) DEFAULT NULL,
  `questiontextid` varchar(100) DEFAULT NULL,
  `questiontype_java` varchar(100) NOT NULL,
  `maxUserSelections` tinyint(4) DEFAULT NULL,
  `shuffle` tinyint(1) DEFAULT '0',
  `options` json,
  PRIMARY KEY (`questionid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcase_question_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3930 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcase_question_availablegroup_link`
--

DROP TABLE IF EXISTS `iqcase_question_availablegroup_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcase_question_availablegroup_link` (
  `linkid` int(11) NOT NULL AUTO_INCREMENT,
  `groupid` int(11) DEFAULT NULL,
  `questionid` int(11) DEFAULT NULL,
  PRIMARY KEY (`linkid`),
  KEY `questionid` (`questionid`),
  CONSTRAINT `iqcase_question_availablegroup_link_ibfk_1` FOREIGN KEY (`questionid`) REFERENCES `iqcase_question` (`questionid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3196 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcasecomment`
--

DROP TABLE IF EXISTS `iqcasecomment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcasecomment` (
  `commentid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `text` mediumtext NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hidden` tinyint(1) DEFAULT '0',
  `reviewed` tinyint(1) DEFAULT '0',
  `reviewedBy` int(11) DEFAULT NULL,
  `reviewedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`commentid`),
  KEY `caseid` (`caseid`),
  KEY `userid` (`userid`),
  CONSTRAINT `iqcasecomment_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqcasecomment_ibfk_2` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=530 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcasecompleted`
--

DROP TABLE IF EXISTS `iqcasecompleted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcasecompleted` (
  `casecompletedid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `quizid` int(11) NOT NULL,
  `answersB` blob,
  `score` decimal(15,4) DEFAULT NULL,
  `passScore` decimal(15,4) DEFAULT NULL,
  `pass` tinyint(1) DEFAULT NULL,
  `secondstaken` int(11) DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT '0',
  `answersJ` json DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `seen` tinyint(1) DEFAULT NULL,
  `answered` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`casecompletedid`),
  KEY `quizid` (`quizid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcasecompleted_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE,
  CONSTRAINT `iqcasecompleted_ibfk_2` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18462 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcaseimagelink`
--

DROP TABLE IF EXISTS `iqcaseimagelink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcaseimagelink` (
  `caseimageid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `imageid` int(11) NOT NULL,
  PRIMARY KEY (`caseimageid`),
  KEY `caseid` (`caseid`),
  KEY `imageid` (`imageid`),
  CONSTRAINT `iqcaseimagelink_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqcaseimagelink_ibfk_2` FOREIGN KEY (`imageid`) REFERENCES `iqimage` (`imageid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2186 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcaserevisions`
--

DROP TABLE IF EXISTS `iqcaserevisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcaserevisions` (
  `revisionid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `caseid` int(11) NOT NULL,
  `casexml` mediumtext,
  `casexmldiff` mediumtext,
  `contributionWeight` int(11) DEFAULT NULL,
  `datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `role` varchar(40) DEFAULT '',
  PRIMARY KEY (`revisionid`),
  KEY `caseid` (`caseid`),
  CONSTRAINT `iqcaserevisions_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5483 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcasetag`
--

DROP TABLE IF EXISTS `iqcasetag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcasetag` (
  `tagid` int(11) NOT NULL AUTO_INCREMENT,
  `tagname` varchar(60) DEFAULT NULL,
  `prefix` varchar(20) DEFAULT '',
  `resourcesText` mediumtext,
  `resources` json DEFAULT NULL,
  PRIMARY KEY (`tagid`)
) ENGINE=InnoDB AUTO_INCREMENT=234 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcasetag_stat`
--

DROP TABLE IF EXISTS `iqcasetag_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcasetag_stat` (
  `statid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `tagid` int(11) DEFAULT NULL,
  `score` decimal(15,4) DEFAULT NULL,
  `passScore` decimal(15,4) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`statid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iqcasetag_stat_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6183 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqcasetaglink`
--

DROP TABLE IF EXISTS `iqcasetaglink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqcasetaglink` (
  `casetagid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `tagid` int(11) NOT NULL,
  PRIMARY KEY (`casetagid`),
  KEY `caseid` (`caseid`),
  KEY `tagid` (`tagid`),
  CONSTRAINT `iqcasetaglink_ibfk_1` FOREIGN KEY (`caseid`) REFERENCES `iqcase` (`caseid`) ON DELETE CASCADE,
  CONSTRAINT `iqcasetaglink_ibfk_2` FOREIGN KEY (`tagid`) REFERENCES `iqcasetag` (`tagid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18366 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqexam`
--

DROP TABLE IF EXISTS `iqexam`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `options` json DEFAULT NULL,
  `achievementid` int(11) DEFAULT NULL,
  PRIMARY KEY (`examid`),
  KEY `exerciseid` (`exerciseid`),
  CONSTRAINT `iqexam_ibfk_1` FOREIGN KEY (`exerciseid`) REFERENCES `iqexercise` (`exerciseid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqexercise`
--

DROP TABLE IF EXISTS `iqexercise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqexercise` (
  `exerciseid` int(11) NOT NULL AUTO_INCREMENT,
  `exerciseName` varchar(60) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`exerciseid`),
  UNIQUE KEY `singlename` (`exerciseName`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqexercisecaselink`
--

DROP TABLE IF EXISTS `iqexercisecaselink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2074 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqexercisetaglink`
--

DROP TABLE IF EXISTS `iqexercisetaglink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqexercisetaglink` (
  `exercisetagid` int(11) NOT NULL AUTO_INCREMENT,
  `exerciseid` int(11) NOT NULL,
  `tagid` int(11) NOT NULL,
  PRIMARY KEY (`exercisetagid`),
  KEY `exerciseid` (`exerciseid`),
  KEY `tagid` (`tagid`),
  CONSTRAINT `iqexercisetaglink_ibfk_1` FOREIGN KEY (`exerciseid`) REFERENCES `iqexercise` (`exerciseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqexercisetaglink_ibfk_2` FOREIGN KEY (`tagid`) REFERENCES `iqcasetag` (`tagid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqimage`
--

DROP TABLE IF EXISTS `iqimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqimage` (
  `imageid` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(60) DEFAULT NULL,
  `description` mediumtext,
  `createddate` datetime DEFAULT '2018-05-17 10:55:31',
  `createdby` int(11) NOT NULL DEFAULT '2',
  PRIMARY KEY (`imageid`)
) ENGINE=InnoDB AUTO_INCREMENT=1046 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqlog`
--

DROP TABLE IF EXISTS `iqlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqlog` (
  `logid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `module` varchar(60) DEFAULT NULL,
  `message` text,
  `details` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`logid`),
  KEY `userid` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqobjectives`
--

DROP TABLE IF EXISTS `iqobjectives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqobjectives` (
  `objectiveid` int(11) NOT NULL AUTO_INCREMENT,
  `objectivecode` varchar(60) NOT NULL,
  `objectivename` mediumtext,
  PRIMARY KEY (`objectiveid`)
) ENGINE=InnoDB AUTO_INCREMENT=328 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqquizcaselink`
--

DROP TABLE IF EXISTS `iqquizcaselink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=29360 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqreference`
--

DROP TABLE IF EXISTS `iqreference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqreference` (
  `referenceid` int(11) NOT NULL AUTO_INCREMENT,
  `searchtext` varchar(100) NOT NULL,
  `replacelink` mediumtext NOT NULL,
  PRIMARY KEY (`referenceid`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqsetting`
--

DROP TABLE IF EXISTS `iqsetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqsetting` (
  `settingid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `value` mediumtext NOT NULL,
  PRIMARY KEY (`settingid`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqsurvey`
--

DROP TABLE IF EXISTS `iqsurvey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqsurvey` (
  `surveyid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `examid` int(11) DEFAULT NULL,
  `quizid` int(11) DEFAULT NULL,
  `difficulty` int(11) DEFAULT NULL,
  `time` int(11) DEFAULT NULL,
  `technical` text,
  `content` text,
  `details` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`surveyid`),
  KEY `examid` (`examid`),
  KEY `userid` (`userid`),
  CONSTRAINT `iqsurvey_ibfk_1` FOREIGN KEY (`examid`) REFERENCES `iqexam` (`examid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `iqsurvey_ibfk_2` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=409 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquser`
--

DROP TABLE IF EXISTS `iquser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `invited` tinyint(1) DEFAULT '0',
  `invitedAt` datetime DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=779 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquser_achievement`
--

DROP TABLE IF EXISTS `iquser_achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iquser_achievement` (
  `achievementid` int(11) NOT NULL AUTO_INCREMENT,
  `achievementName` varchar(50) NOT NULL,
  `achievementShort` varchar(25) NOT NULL,
  `level` varchar(10) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`achievementid`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquser_achievement_link`
--

DROP TABLE IF EXISTS `iquser_achievement_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iquser_achievement_link` (
  `userachievementid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `achievementid` int(11) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userachievementid`),
  KEY `userid` (`userid`),
  KEY `achievementid` (`achievementid`),
  CONSTRAINT `iquser_achievement_link_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iquser_achievement_link_ibfk_2` FOREIGN KEY (`achievementid`) REFERENCES `iquser_achievement` (`achievementid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=547 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquser_permission`
--

DROP TABLE IF EXISTS `iquser_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iquser_permission` (
  `permissionid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `item` varchar(60) DEFAULT NULL,
  `itemid` int(11) NOT NULL,
  `details` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdById` int(11) NOT NULL,
  PRIMARY KEY (`permissionid`),
  KEY `userid` (`userid`),
  CONSTRAINT `iquser_permission_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqusergroup`
--

DROP TABLE IF EXISTS `iqusergroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqusergroup` (
  `groupid` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(60) DEFAULT NULL,
  `public` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`groupid`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iqusergrouplink`
--

DROP TABLE IF EXISTS `iqusergrouplink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iqusergrouplink` (
  `usergroupid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `groupid` int(11) NOT NULL,
  PRIMARY KEY (`usergroupid`),
  KEY `userid` (`userid`),
  KEY `groupid` (`groupid`),
  CONSTRAINT `iqusergrouplink_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iqusergrouplink_ibfk_2` FOREIGN KEY (`groupid`) REFERENCES `iqusergroup` (`groupid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34703 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquserquiz`
--

DROP TABLE IF EXISTS `iquserquiz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `seenAllQuestions` tinyint(1) DEFAULT '0',
  `tracker` json DEFAULT NULL,
  `options` json DEFAULT NULL,
  PRIMARY KEY (`quizid`),
  KEY `userid` (`userid`),
  KEY `examid` (`examid`),
  CONSTRAINT `iquserquiz_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE,
  CONSTRAINT `iquserquiz_ibfk_2` FOREIGN KEY (`examid`) REFERENCES `iqexam` (`examid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1755 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquserquizhelper`
--

DROP TABLE IF EXISTS `iquserquizhelper`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iquserquizhelper` (
  `helperid` int(11) NOT NULL AUTO_INCREMENT,
  `quizid` int(11) NOT NULL,
  `completedids` mediumtext,
  `incompleteids` mediumtext,
  `performance` mediumtext,
  PRIMARY KEY (`helperid`),
  KEY `quizid` (`quizid`),
  CONSTRAINT `iquserquizhelper_ibfk_1` FOREIGN KEY (`quizid`) REFERENCES `iquserquiz` (`quizid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=890 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iquservar`
--

DROP TABLE IF EXISTS `iquservar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iquservar` (
  `userid` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `value` varchar(256) NOT NULL,
  PRIMARY KEY (`userid`,`name`),
  CONSTRAINT `iquservar_ibfk_1` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_procedure`
--

DROP TABLE IF EXISTS `log_procedure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_procedure` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `public` tinyint(1) DEFAULT '0',
  `pin` varchar(255) DEFAULT NULL,
  `comment` mediumtext,
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
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mgr_block`
--

DROP TABLE IF EXISTS `mgr_block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mgr_block` (
  `blockid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `schoolid` int(11) unsigned DEFAULT NULL,
  `blockname` varchar(60) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  PRIMARY KEY (`blockid`),
  KEY `schoolid` (`schoolid`),
  CONSTRAINT `mgr_block_ibfk_1` FOREIGN KEY (`schoolid`) REFERENCES `mgr_school` (`schoolid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mgr_rotation`
--

DROP TABLE IF EXISTS `mgr_rotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mgr_rotation` (
  `rotationid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rotationname` varchar(60) NOT NULL,
  `schoolid` int(11) unsigned NOT NULL,
  `details` json DEFAULT NULL,
  PRIMARY KEY (`rotationid`),
  KEY `schoolid` (`schoolid`),
  CONSTRAINT `mgr_rotation_ibfk_1` FOREIGN KEY (`schoolid`) REFERENCES `mgr_school` (`schoolid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mgr_rotationachievementlink`
--

DROP TABLE IF EXISTS `mgr_rotationachievementlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mgr_rotationachievementlink` (
  `rotationachievementid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rotationid` int(11) unsigned NOT NULL,
  `achievementid` int(11) NOT NULL,
  PRIMARY KEY (`rotationachievementid`),
  KEY `rotationid` (`rotationid`),
  KEY `achievementid` (`achievementid`),
  CONSTRAINT `mgr_rotationachievementlink_ibfk_1` FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mgr_rotationachievementlink_ibfk_2` FOREIGN KEY (`achievementid`) REFERENCES `iquser_achievement` (`achievementid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mgr_school`
--

DROP TABLE IF EXISTS `mgr_school`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mgr_school` (
  `schoolid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `schoolname` varchar(60) NOT NULL,
  PRIMARY KEY (`schoolid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mgr_userenrollment`
--

DROP TABLE IF EXISTS `mgr_userenrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mgr_userenrollment` (
  `enrollmentid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `blockid` int(11) unsigned NOT NULL,
  `rotationid` int(11) unsigned NOT NULL,
  `enrolledAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remindedAt` datetime DEFAULT NULL,
  `invitedAt` datetime DEFAULT NULL,
  `details` json DEFAULT NULL,
  PRIMARY KEY (`enrollmentid`),
  KEY `blockid` (`blockid`),
  KEY `rotationid` (`rotationid`),
  KEY `userid` (`userid`),
  CONSTRAINT `mgr_userenrollment_ibfk_1` FOREIGN KEY (`blockid`) REFERENCES `mgr_block` (`blockid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mgr_userenrollment_ibfk_2` FOREIGN KEY (`rotationid`) REFERENCES `mgr_rotation` (`rotationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mgr_userenrollment_ibfk_3` FOREIGN KEY (`userid`) REFERENCES `iquser` (`userid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=139 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-11-01 14:12:30


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
INSERT INTO iquser_achievement (achievementName, achievementShort, level, icon, color) VALUES {'PFT', 'PFT', 1, 'mdi-lung', '#eed478');

