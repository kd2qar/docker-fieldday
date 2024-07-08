# docker-fieldday
Docker container and script for comparing field day log to class and section data on ARRL log submission site
The docker image is used by the script to downoad data and convert it to SQL.

Create the docker image with your field day log file (N3FJP Field Day logger)
Create the databbase using the field-day.sql file (mariadb or mysql)

run the script 'checkfielddata' to compare callsign, class and section data to information provided
on the log submission site.

This is more interesting than useful.
