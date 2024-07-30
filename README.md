# docker-fieldday
Docker container and scripts for comparing field day log to class and section data on ARRL log submission site
The docker image is used by the script to downoad data and convert it to SQL.

Create the docker image with your field day log file (N3FJP Field Day logger)
Create the databbase using the field-day.sql file (mariadb or mysql)


run the script 'checkfielddata' to compare callsign, class and section data to information provided
on the log submission site.

run with -u or --update periodically to download fresh data from the log submission site:
	./checkfielddata -u

The docker image can be created by running make
the container is created and run by the 'checkfielddata' script

This is more interesting than useful.
