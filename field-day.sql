-- - CREATE DATABASE AND TABLES FOR ANYLIZING FIELD DAY LOGS
-- -

CREATE database IF NOT EXISTS fieldday;

-- DESTINATION FOR YOUR FIELD DAY LOG DATA

DROP TABLE IF EXISTS fieldday.fieldday_log;
CREATE TABLE IF NOT EXISTS fieldday.fieldday_log (
  `date` varchar(50) DEFAULT NULL,
  `frequency` varchar(50) DEFAULT NULL,
  `band`      varchar(50) DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL,
  `callsign` varchar(50) DEFAULT NULL,
  `rst_sent` varchar(50) DEFAULT NULL,
  `rst_rcvd` varchar(50) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `mode` varchar(50) DEFAULT NULL,
  `comment` varchar(200) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(200) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `station` varchar(50) DEFAULT NULL,
  `operator` varchar(50) DEFAULT NULL,
  `class` varchar(50) DEFAULT NULL,
  `section` varchar(50) DEFAULT NULL
) COMMENT='Field day log data extracted from logging software';

-- TABLE OF DATA SCRAPED FROM ARRL LOG SUBMISSION STATUS PAGE
-- e.g. https://field-day.arrl.org/fdentry.php
--

CREATE TABLE IF NOT EXISTS fieldday.fieldday_status (
  `callsign` varchar(50) NOT NULL,
  `gota` varchar(50) DEFAULT NULL,
  `status` varchar(80) DEFAULT NULL,
  `club` varchar(80) DEFAULT NULL,
  `class` varchar(10) DEFAULT NULL,
  `section` varchar(10) DEFAULT NULL
) COMMENT='Copied data from the field day status site used to verify call, class and section';

-- SCHEMA TO CONTAIN ALL THE DATA FROM THE N3FJP Field Day Logger

CREATE TABLE IF NOT EXISTS fieldday.tblContacts
 (
        `fldAge`                        VARCHAR (255),
        `fldARCI`                       VARCHAR (255),
        `fldBand`                       VARCHAR (255),
        `fldCall`                       VARCHAR (255),
        `fldCategory`                   VARCHAR (255),
        `fldCheck`                      VARCHAR (255),
        `fldClass`                      VARCHAR (255),
        `fldComments`                   VARCHAR (255),
        `fldComputerName`               VARCHAR (255),
        `fldContestID`                  VARCHAR (255),
        `fldContinent`                  VARCHAR (255),
        `fldCountryDXCC`                VARCHAR (255),
        `fldCountryWorked`              VARCHAR (255),
        `fldCountyR`                    VARCHAR (255),
        `fldCountyS`                    VARCHAR (255),
        `fldCQZone`                     VARCHAR (255),
        `fldDateStr`                    VARCHAR (255),
        `fldFists`                      VARCHAR (255),
        `fldFrequency`                  VARCHAR (255),
        `fldFuture1`                    VARCHAR (255),
        `fldFuture2`                    VARCHAR (255),
        `fldGridR`                      VARCHAR (255),
        `fldGridS`                      VARCHAR (255),
        `fldIARUZone`                   VARCHAR (255),
        `fldInitials`                   VARCHAR (255),
        `fldIOTA`                       VARCHAR (255),
        `fldITUZone`                    VARCHAR (255),
        `fldLightHouse`                 VARCHAR (255),
        `fldMode`                       VARCHAR (255),
        `fldModeContest`                VARCHAR (255),
        `fldNameR`                      VARCHAR (255),
        `fldNameS`                      VARCHAR (255),
        `fldOperator`                   VARCHAR (255),
        `fldOther1`                     VARCHAR (255),
        `fldOther2`                     VARCHAR (255),
        `fldOther3`                     VARCHAR (255),
        `fldOther4`                     VARCHAR (255),
        `fldOther5`                     VARCHAR (255),
        `fldOther6`                     VARCHAR (255),
        `fldOther7`                     VARCHAR (255),
        `fldOther8`                     VARCHAR (255),
        `fldPoints`                     Double,
        `fldPower`                      VARCHAR (255),
        `fldPrecedence`                 VARCHAR (255),
        `fldPrefix`                     VARCHAR (255),
        `fldPropMode`                   VARCHAR (255),
        `fldQSLConfByR`                 VARCHAR (255),
        `fldQSLConfByS`                 VARCHAR (255),
        `fldQSLR`                       VARCHAR (255),
        `fldQSLS`                       VARCHAR (255),
        `fldQTHGroup`                   VARCHAR (255),
        `fldRstR`                       VARCHAR (255),
        `fldRstS`                       VARCHAR (255),
        `fldSatName`                    VARCHAR (255),
        `fldSection`                    VARCHAR (255),
        `fldSerialNoR`                  VARCHAR (255),
        `fldSerialNoS`                  VARCHAR (255),
        `fldSPC`                        VARCHAR (255),
        `fldSPCNum`                     VARCHAR (255),
        `fldState`                      VARCHAR (255),
        `fldStation`                    VARCHAR (255),
        `fldTenTen`                     VARCHAR (255),
        `fldTimeOffStr`                 VARCHAR (255),
        `fldTimeOnStr`                  VARCHAR (255),
        `fldTransmitterID`              VARCHAR (255),
        `fldPrimaryKey`                 Integer
) COMMENT='Data extracted from N3FJP field day logger';

-- DATA PULLED FROM CALLBOOK SITES SUCH AS QRZ and HAMQTH
-- FIRST COLUMN CONTAINS THE CALL 'HEARD' FROM THE FIELD DAY
-- STATION

CREATE TABLE IF NOT EXISTS fieldday.`qrzdata` (
        `fdcall` VARCHAR(20) NOT NULL         ,
        `callsign` VARCHAR(20) DEFAULT NULL ,
        `nickname` TEXT NULL DEFAULT NULL ,
        `firstname` TEXT NULL DEFAULT NULL ,
        `lastname` TEXT NULL DEFAULT NULL ,
        `phone` VARCHAR(20) NULL DEFAULT NULL ,
        `grid` VARCHAR(6) NULL DEFAULT NULL ,
        `addr2` TEXT NULL DEFAULT NULL ,
        `state` VARCHAR(20) NULL DEFAULT NULL,
        `country` TEXT NULL DEFAULT NULL ,
        `class` TEXT NULL DEFAULT NULL ,
        `fullname` TEXT AS (if(`firstname` is null and `lastname` is null and `nickname` is NULL,NULL,
			       concat(if(`nickname` is null,if(firstname IS NULL,'',concat(`firstname`,' ')),		             
			       concat(`nickname`,' ')),'',if(`lastname` is null,'',`lastname`)))) 
			   VIRTUAL,
        `location` TEXT AS (if(`country` is null,'',if(`country` = 'United States' or `country` = 'USA',concat(`state`,', USA'),`country`))) VIRTUAL,
        `email` TEXT NULL DEFAULT NULL,
        `qrz_email` TEXT NULL DEFAULT NULL,
        PRIMARY KEY (`fdcall`) USING BTREE
)
COMMENT='Details from QRZ and other sources for each callsign'
;

-- USEFUL FUNCTIONS USED IN QUEriES

DELIMITER ;;

CREATE OR REPLACE FUNCTION fieldday.isNumber(inputValue VARCHAR(50))   RETURNS INT
  COMMENT 'check for numeric value'
  BEGIN
    IF (inputValue REGEXP ('^[0-9]+$'))
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

-- REMOVES TRAILING NUMBERS FROM SUBMITTED CLASS DESIGNATION

CREATE OR REPLACE FUNCTION fieldday.fixClass(origClass VARCHAR(50)) RETURNS VARCHAR(50)
COMMENT 'Lops off extraneous number from end of class for ARRL Field Day submissions'
BEGIN
  SET @pos = LENGTH(origClass)-1;
  SET @tail = SUBSTRING(origClass,@pos+1);

  IF (fieldday.isNumber(@tail) = 1)
  THEN
    RETURN SUBSTRING(origClass,1,@pos);
  ELSE
    RETURN origClass;
  END IF;
  RETURN  "test";
END;

;;
DELIMITER ;

