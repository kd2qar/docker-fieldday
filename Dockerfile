FROM debian:bookworm-slim as root

RUN apt-get update  \
     && apt-get -y upgrade  \
     && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        python3-requests python3-xmltodict python3-certifi python3-urllib3 ca-certificates \
        python3-soupsieve python3-bs4 mdbtools \
     && rm -rf /var/lib/apt/lists*

#RUN apt-get update \
#    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends vim vim-common aptitude  \
#    && rm -rf /var/lib/apt/lists*

WORKDIR /root

RUN mkdir /root/bin
COPY scraper /root/bin/scraper
COPY dot.bashrc /root/.bashrc
RUN chmod +x /root/bin/scraper && ln -s /root/bin/scraper

COPY LogDataFieldDay-Original.mdb /root/LogDataFieldDay-Original.mdb
COPY LogDataFieldDay.mdb /root/LogDataFieldDay.mdb

CMD "/bin/bash"
