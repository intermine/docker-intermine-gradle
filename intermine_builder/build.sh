#!/bin/bash

if [ -d ${MINE_NAME:-biotestmine} ] && [ ! -z "$(ls -A ${MINE_NAME:-biotestmine})" ] && [ ! $FORCE_MINE_BUILD ]; then
    echo "$(date +%Y/%m/%d-%H:%M) Mine already exists"
    echo "$(date +%Y/%m/%d-%H:%M) Gradle: build webapp"
    cd /home/intermine/intermine
    cd ${MINE_NAME:-biotestmine}
    ./gradlew cargoDeployRemote
    sleep 60
    ./gradlew cargoRedeployRemote  --stacktrace
    exit 0
fi

set -e

cd /home/intermine/intermine

# Empty log
echo "" > /home/intermine/intermine/build.progress

# Build InterMine if any of the envvars are specified.
if [ ! -z ${IM_REPO_URL} ] || [ ! -z ${IM_REPO_BRANCH} ]; then
    echo "$(date +%Y/%m/%d-%H:%M) Start InterMine build" #>> /home/intermine/intermine/build.progress
    echo "$(date +%Y/%m/%d-%H:%M) Cloning ${IM_REPO_URL:-https://github.com/intermine/intermine} branch ${IM_REPO_BRANCH:-master} for InterMine build" #>> /home/intermine/intermine/build.progress
    git clone ${IM_REPO_URL:-https://github.com/intermine/intermine} intermine --single-branch --branch ${IM_REPO_BRANCH:-master} --depth=1

    cd intermine

    (cd plugin && ./gradlew clean && ./gradlew install) &&
    (cd intermine && ./gradlew clean && ./gradlew install) &&
    (cd bio && ./gradlew clean && ./gradlew install) &&
    (cd bio/sources && ./gradlew clean && ./gradlew install) &&
    (cd bio/postprocess/ && ./gradlew clean && ./gradlew install)

    # Read the version numbers of the built InterMine, as we'll need to set
    # the mine to use the same versions for it to use the local build.
    IM_VERSION=$(sed -n "s/^\s*version.*\+'\(.*\)'\s*$/\1/p" intermine/build.gradle)
    BIO_VERSION=$(sed -n "s/^\s*version.*\+'\(.*\)'\s*$/\1/p" bio/build.gradle)

    cd /home/intermine/intermine
fi


echo "Starting mine build"
echo $MINE_REPO_URL
# Check if mine exists and is not empty
if [ -d ${MINE_NAME:-biotestmine} ] && [ ! -z "$(ls -A ${MINE_NAME:-biotestmine})" ]; then
    echo "$(date +%Y/%m/%d-%H:%M) Update ${MINE_NAME:-biotestmine} to newest version" #>> /home/intermine/intermine/build.progress
    cd ${MINE_NAME:-biotestmine}
    # git pull
    cd /home/intermine/intermine
else
    # echo "$(date +%Y/%m/%d-%H:%M) Clone ${MINE_NAME:-biotestmine}" #>> /home/intermine/intermine/build.progress
    echo "$(date +%Y/%m/%d-%H:%M) Clone ${MINE_NAME:-biotestmine}"
    git clone ${MINE_REPO_URL:-https://github.com/intermine/biotestmine} ${MINE_NAME:-biotestmine}
    echo "$(date +%Y/%m/%d-%H:%M) Update keyword_search.properties to use http://solr" #>> /home/intermine/intermine/build.progress
    sed -i 's/localhost/'${SOLR_HOST:-solr}'/g' ./${MINE_NAME:-biotestmine}/dbmodel/resources/keyword_search.properties
fi

# If InterMine or Bio versions have been set (likely because of a custom
# InterMine build), update gradle.properties in the mine.
if [ ! -z ${IM_VERSION} ]; then
    sed -i "s/\(systemProp\.imVersion=\).*\$/\1${IM_VERSION}/" /home/intermine/intermine/${MINE_NAME:-biotestmine}/gradle.properties
fi
if [ ! -z ${BIO_VERSION} ]; then
    sed -i "s/\(systemProp\.bioVersion=\).*\$/\1${BIO_VERSION}/" /home/intermine/intermine/${MINE_NAME:-biotestmine}/gradle.properties
fi

# Copy project_build from intermine_scripts repo
if [ ! -f /home/intermine/intermine/${MINE_NAME:-biotestmine}/project_build ]; then
    echo "$(date +%Y/%m/%d-%H:%M) Cloning intermine scripts repo to /home/intermine/intermine/intermine-scripts"
    git clone https://github.com/intermine/intermine-scripts
    echo "$(date +%Y/%m/%d-%H:%M) Copy project_build to /home/intermine/intermine/${MINE_NAME:-biotestmine}"
    cp /home/intermine/intermine/intermine-scripts/project_build /home/intermine/intermine/${MINE_NAME:-biotestmine}/project_build
    chmod +x /home/intermine/intermine/${MINE_NAME:-biotestmine}/project_build
fi

# Copy mine properties
if [ ! -f /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties ]; then
    if [ ! -f /home/intermine/intermine/configs/${MINE_NAME:-biotestmine}.properties ]; then
        echo "$(date +%Y/%m/%d-%H:%M) Copy biotestmine.properties to ~/.intermine/${MINE_NAME:-biotestmine}.properties" #>> /home/intermine/intermine/build.progress
        cp /home/intermine/intermine/${MINE_NAME:-biotestmine}/data/${MINE_NAME:-biotestmine}.properties /home/intermine/.intermine/
    else
        echo "$(date +%Y/%m/%d-%H:%M) Copy ${MINE_NAME:-biotestmine}.properties to ~/.intermine/${MINE_NAME:-biotestmine}.properties"
        cp /home/intermine/intermine/configs/${MINE_NAME:-biotestmine}.properties /home/intermine/.intermine/
    fi

    echo -e "$(date +%Y/%m/%d-%H:%M) Set properties in .intermine/${MINE_NAME:-biotestmine}.properties to\nPSQL_DB_NAME\tbiotestmine\nPSQL_USER\t$PSQL_USER\nPSQL_PWD\t$PSQL_PWD\nTOMCAT_USER\t$TOMCAT_USER\nTOMCAT_PWD\t$TOMCAT_PWD\nGRADLE_OPTS\t$GRADLE_OPTS" #>> /home/intermine/intermine/build.progress

    #sed -i "s/PSQL_PORT/$PGPORT/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/PSQL_DB_NAME/${MINE_NAME:-biotestmine}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/PSQL_USER/${PSQL_USER:-postgres}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/PSQL_PWD/${PSQL_PWD:-postgres}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/TOMCAT_USER/${TOMCAT_USER:-tomcat}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/TOMCAT_PWD/${TOMCAT_PWD:-tomcat}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/webapp.deploy.url=http:\/\/localhost:8080/webapp.deploy.url=http:\/\/${TOMCAT_HOST:-tomcat}:${TOMCAT_PORT:-8080}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    sed -i "s/serverName=localhost/serverName=${PGHOST:-postgres}:${PGPORT:-5432}/g" /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties


    # echo "project.rss=http://localhost:$WORDPRESS_PORT/?feed=rss2" >> /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
    # echo "links.blog=https://localhost:$WORDPRESS_PORT" >> /home/intermine/.intermine/${MINE_NAME:-biotestmine}.properties
fi

# Copy mine configs
if [ ! -f /home/intermine/intermine/${MINE_NAME:-biotestmine}/project.xml ]; then
    if [ -f /home/intermine/intermine/configs/project.xml ]; then
        echo "$(date +%Y/%m/%d-%H:%M) Copy project.xml to ~/${MINE_NAME:-biotestmine}/project.xml"
        cp /home/intermine/intermine/configs/project.xml /home/intermine/intermine/${MINE_NAME:-biotestmine}/
        echo "$(date +%Y/%m/%d-%H:%M) Set correct source path in project.xml"
        sed -i 's/'${IM_DATA_DIR:-DATA_DIR}'/\/home\/intermine\/intermine\/data/g' /home/intermine/intermine/${MINE_NAME:-biotestmine}/project.xml
        sed -i 's/dump="true"/dump="false"/g' /home/intermine/intermine/${MINE_NAME:-biotestmine}/project.xml
    else
        echo "$(date +%Y/%m/%d-%H:%M) Copy project.xml to ~/biotestmine/project.xml" #>> /home/intermine/intermine/build.progress
        cp /home/intermine/intermine/biotestmine/data/project.xml /home/intermine/intermine/biotestmine/

        echo "$(date +%Y/%m/%d-%H:%M) Set correct source path in project.xml" #>> /home/intermine/intermine/build.progress
        sed -i 's/'${IM_DATA_DIR:-DATA_DIR}'/\/home\/intermine\/intermine\/data/g' /home/intermine/intermine/biotestmine/project.xml
        sed -i 's/dump="true"/dump="false"/g' /home/intermine/intermine/biotestmine/project.xml

    fi
else
    echo "$(date +%Y/%m/%d-%H:%M) Set correct source path in project.xml"
    sed -i "s~${IM_DATA_DIR:-DATA_DIR}~/home/intermine/intermine/data~g" /home/intermine/intermine/${MINE_NAME:-biotestmine}/project.xml
    sed -i 's/dump="true"/dump="false"/g' /home/intermine/intermine/${MINE_NAME:-biotestmine}/project.xml
fi

# Copy data
if [ -d /home/intermine/intermine/data ]; then
    echo "$(date +%Y/%m/%d-%H:%M) found user data directory"
    if [ !  -n "$(find /home/intermine/intermine/data -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
        for f in *.tar.gz; do
            tar xzf "$f" && rm "$f"
        done
        cd /home/intermine/intermine
    fi
else
    echo "$(date +%Y/%m/%d-%H:%M) No user data directory found"
    if [ ! -d /home/intermine/intermine/data/malaria ]; then
        echo "$(date +%Y/%m/%d-%H:%M) Copy malria-data to ~/data" #>> /home/intermine/intermine/build.progress
        mkdir -p /home/intermine/intermine/data/
        cp /home/intermine/intermine/biotestmine/data/malaria-data.tar.gz /home/intermine/intermine/data/
        cd /home/intermine/intermine/data/
        tar -xf malaria-data.tar.gz
        rm malaria-data.tar.gz
        cd /home/intermine/intermine
    fi
fi


echo "$(date +%Y/%m/%d-%H:%M) Connect and create Postgres databases" #>> /home/intermine/intermine/build.progress

# # Wait for database
# dockerize -wait tcp://postgres:$PGPORT -timeout 60s
until psql -U postgres -h ${PGHOST:-postgres} -c '\l'; do
  echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is unavailable - sleeping"
  sleep 1
done
echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is up - executing command"

# Close all open connections to database
psql -U postgres -h ${PGHOST:-postgres} -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();"

echo "$(date +%Y/%m/%d-%H:%M) Database is now available ..." #>> /home/intermine/intermine/build.progress
echo "$(date +%Y/%m/%d-%H:%M) Reset databases and roles" #>> /home/intermine/intermine/build.progress

# Delete Databases if exist
psql -U postgres -h ${PGHOST:-postgres} -c "DROP DATABASE IF EXISTS \"${MINE_NAME:-biotestmine}\";"
psql -U postgres -h ${PGHOST:-postgres} -c "DROP DATABASE IF EXISTS \"items-${MINE_NAME:-biotestmine}\";"
psql -U postgres -h ${PGHOST:-postgres} -c "DROP DATABASE IF EXISTS \"userprofile-${MINE_NAME:-biotestmine}\";"

# psql -U postgres -h ${PGHOST:-postgres} -c "DROP ROLE IF EXISTS ${PSQL_USER:-postgres};"

# Create Databases
echo "$(date +%Y/%m/%d-%H:%M) Creating postgres database tables and roles.." #>> /home/intermine/intermine/build.progress
# psql -U postgres -h ${PGHOST:-postgres} -c "CREATE USER ${PSQL_USER:-postgres} WITH PASSWORD '${PSQL_PWD:-postgres}';"
psql -U postgres -h ${PGHOST:-postgres} -c "ALTER USER ${PSQL_USER:-postgres} WITH SUPERUSER;"
psql -U postgres -h ${PGHOST:-postgres} -c "CREATE DATABASE \"${MINE_NAME:-biotestmine}\";"
psql -U postgres -h ${PGHOST:-postgres} -c "CREATE DATABASE \"items-${MINE_NAME:-biotestmine}\";"
psql -U postgres -h ${PGHOST:-postgres} -c "CREATE DATABASE \"userprofile-${MINE_NAME:-biotestmine}\";"
psql -U postgres -h ${PGHOST:-postgres} -c "GRANT ALL PRIVILEGES ON DATABASE ${MINE_NAME:-biotestmine} to ${PSQL_USER:-postgres};"
psql -U postgres -h ${PGHOST:-postgres} -c "GRANT ALL PRIVILEGES ON DATABASE \"items-${MINE_NAME:-biotestmine}\" to ${PSQL_USER:-postgres};"
psql -U postgres -h ${PGHOST:-postgres} -c "GRANT ALL PRIVILEGES ON DATABASE \"userprofile-${MINE_NAME:-biotestmine}\" to ${PSQL_USER:-postgres};"


cd ${MINE_NAME:-biotestmine}

echo "$(date +%Y/%m/%d-%H:%M) Running project_build script"
./project_build -b -T localhost /home/intermine/intermine/dump/dump

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: buildDB" #>> /home/intermine/intermine/build.progress
# ./gradlew buildDB --stacktrace #>> /home/intermine/intermine/build.progress

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: integrate uniprot-malaria" #>> /home/intermine/intermine/build.progress
# ./gradlew integrate -Psource=uniprot-malaria --stacktrace

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: integrate malaria-gff" #>> /home/intermine/intermine/build.progress
# ./gradlew integrate -Psource=malaria-gff --stacktrace

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: integrate malaria-chromosome-fasta" #>> /home/intermine/intermine/build.progress
# ./gradlew integrate -Psource=malaria-chromosome-fasta --stacktrace

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: integrate entrez-organism" #>> /home/intermine/intermine/build.progress
# ./gradlew integrate -Psource=entrez-organism --stacktrace

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: integrate update-publications" #>> /home/intermine/intermine/build.progress
# ./gradlew integrate -Psource=update-publications --stacktrace #>> /home/intermine/intermine/build.progress

# echo "$(date +%Y/%m/%d-%H:%M) Gradle: run post_processess" #>> /home/intermine/intermine/build.progress
# ./gradlew postProcess --stacktrace #>> /home/intermine/intermine/build.progress

echo "$(date +%Y/%m/%d-%H:%M) Gradle: build userDB" #>> /home/intermine/intermine/build.progress
./gradlew buildUserDB --stacktrace #>> /home/intermine/intermine/build.progress

echo "$(date +%Y/%m/%d-%H:%M) Gradle: build webapp" #>> /home/intermine/intermine/build.progress
# ./gradlew clean
./gradlew cargoDeployRemote
sleep 60
./gradlew cargoRedeployRemote  --stacktrace #>> /home/intermine/intermine/build.progress
