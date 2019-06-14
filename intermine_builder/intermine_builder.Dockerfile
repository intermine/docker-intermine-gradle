FROM alpine:3.9
LABEL maintainer="Ank"

ENV JAVA_HOME="/usr/lib/jvm/default-jvm"
ENV GRADLE_OPTS="-server -Xmx2g -XX:+UseParallelGC -Xms1g -XX:SoftRefLRUPolicyMSPerMB=1 -XX:MaxHeapFreeRatio=99 -Dorg.gradle.daemon=false"

RUN apk add --no-cache openjdk8-jre && \
    ln -sf "${JAVA_HOME}/bin/"* "/usr/bin/"

RUN apk add --no-cache git \
                       maven \
                       postgresql-client

RUN apk add --no-cache openjdk8

RUN mkdir /home/intermine && mkdir /home/intermine/.intermine && mkdir /home/intermine/intermine && mkdir /home/intermine/intermine/scripts

ENV HOME="/home/intermine"
ENV PSQL_USER="postgres"
ENV PSQL_PWD="postgres"
ENV TOMCAT_USER="tomcat"
ENV TOMCAT_PWD="tomcat"
ENV TOMCAT_PORT=8080
ENV PGPORT=5432

COPY ./build.sh /home/intermine/.intermine/
WORKDIR /home/intermine/intermine

CMD ["/bin/sh","/home/intermine/.intermine/build.sh"]