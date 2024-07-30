# docker-fieldday
Docker container and scripts for comparing field day log to class and section data on ARRL log submission site
The docker image is used by the script to downoad data and convert it to SQL.

Create the docker image with your field day log file (N3FJP Field Day logger)
Create the databbase using the field-day.sql file (mariadb or mysql)


run the script '`checkfielddata`' to compare callsign, class and section data to information provided
on the log submission site.

run with -u or --update periodically to download fresh data from the log submission site:
	- `./checkfielddata -u`

The docker image can be created by running `make`.
The container is created and run by the '`checkfielddata`' script

The docker container encapsulates the tools used to manipulate the data.

## Additional pieces needed
1. A mariadb or mysql databaase. (any other will work but you may need to modify the SQL syntax)
2. A tool to pull callbook data and convert it to sql to load into the **`qrzdata`** table.
3. Two copies of your Field Day log in an N3FJP log database. One is the original version that is
   unmodified. The second contains changes/corrections discovered using this tool.
4. A **helmet**! This is what I would classify as a'persononal productivity' tool that fits my
   specific environment and use case. You will, likely, need to modify and adapt it to meet your
   own needs. It was created for the **2024** versions of both the ARRL site and the N3FJP database. 

## How this works
First create the database and tables used to collect the data and perform the analysis using the **field-day.sql** file.

The bash script **checkfielddata** is run from the command line and, roughly does the following:

1. Extract data from the Local field day log in the N3FJP software datbase using mdb-export
 and loads it into a mariadb database.
 The raw data is extracted into the table `tblContacts` and then loaded
 to a simpler table, `fieldday_log`, which is used for the comparison queries.

2. Updates the information from the ARRL log submission site:
  [entries received](https://field-day.arrl.org/fdentriesrcvd.php).
  Using the python script **scraper**; log entry summary information scraped from the ARRL field day site
  is loaded into a table, `fieldday_status`, so that the class and section data provided
  for the uploaded logs can be compared to the ones recorded in the
  local log during field day. **Note** that this works with the **2024** version of the site so, *your mileage may vary*.
 
3. Runs a series of queries to provide the following information:
- All callsign matches found in the submitted entries table. 
   Those that don't match the class and section exchange are flagged. 
- Log entries that do not match any of the callsigns in the submitted entries.
- Comparison of the *club* names on the submitted entries and the callsign name from the callbook data in the `qrzdata` table.
- Some simple statistics including; the number of matches, match percentage, total log entries, number of class or section mismatches and the total number of entries found in the ARRL table.
- A list of the callsigns with class or section exchanges that don't match the entries on the ARRL site.
- A list of *broken* calls. i.e. Calls that cannot be found in the callbook data.

 
## Loading the callbook data.
Currently, I use the script `qrzcheck` to load callbook data for the calls in the field day entries table. 
There is a column `fdcall` that is the callsign used for the exchange or in the entry submission.
That is the call used to query the callbook information. There is a second column '`callsign`' which is the
callsign that is *returned* when the callbook is queried. Usually, they are the same. 
However, when the fdcall is an old call that has been changed to a vanity call, they will not match.
There were, at least, two cases in 2024 where someone was using their old callsign (presumably out of habit) 
durring the FD exchange so this attempts to handle that.

The `qrzcheck` script uses the (not publshed yet) `callinfo` script to query the callbook and return the necessary 
SQL to insert or update the callbook data.

For Example:
```
DELIMITER $$
IF (SELECT fdcall FROM fieldday.qrzdata WHERE fdcall = 'w1aw') = 'w1aw' THEN
     UPDATE fieldday.qrzdata SET `callsign`='w1aw',`addr2`='NEWINGTON',`grid`='FN31pr',`state`='CT',`country`='United States',`lastname`='ARRL HQ OPERATORS CLUB',`qrz_email`='W1AW@ARRL.ORG',`class`='C'     WHERE `fdcall`='w1aw';
 ELSE
     INSERT INTO fieldday.qrzdata (`fdcall`, `callsign`,`addr2`,`grid`,`state`,`country`,`lastname`,`email`,`qrz_email`,`class`) VALUES('w1aw', 'w1aw','NEWINGTON','FN31pr','CT','United States','ARRL HQ OPERATORS CLUB','W1AW@ARRL.ORG','W1AW@ARRL.ORG','C') ;
END IF $$
DELIMITER ;
```


**This is more interesting than useful.**

## Possible Improvements:
- embed the callbook scripts in this image or publish the `callinfo` stuff. 
- automate the 'harvesting' of the N3FJP files, possibly copy or link to them at runtime.
- ...
