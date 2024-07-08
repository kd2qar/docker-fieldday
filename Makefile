TAG=kd2qar/fieldday
NAME=fieldday

#PORT=-p 5899:5900

All: Build

Build: stop remove
	docker  build --rm --tag ${TAG} .

log:  Build
	docker run --rm -t --name ${NAME} ${TAG} mdb-export --insert=mysql  LogDataFieldDay.mdb tblContacts

scrape: Build
	docker run --rm -t --name ${NAME} ${TAG} /root/bin/scraper

run: Build log

shell: Build
	docker run --rm -it --name ${NAME} ${TAG} /bin/bash

stop:
	docker stop ${NAME} 2>/dev/null | true

remove: stop
	docker rm ${NAME} 2>/dev/null | true
