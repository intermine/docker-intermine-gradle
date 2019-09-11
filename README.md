# docker-intermine-gradle

You can use these docker images to create your own InterMine instance. You can launch our test InterMine (BioTestMine) or you can use your own data to build a custom mine.

## Requirements

 - [Docker](https://docs.docker.com/install/)
 - [Docker compose](https://docs.docker.com/compose/install/)

## Quickstart

Run the command to build the images locally and start an example InterMine instance - BioTestMine.

```bash
# Build images locally and start mine
docker-compose -f local.docker-compose.yml up --build --force-recreate
```

Alternatively, you can also use our images on docker hub.

```bash
# OR
# use the images on dockerhub
docker-compose -f dockerhub.docker-compose.yml up 
```

Wait for 10-15 mins for the build to finish. Then visit **`localhost:9999/biotestmine`** to see your new mine.

To determine whether build is finished or not, search for `intermine_builder exited with code 0` message in your docker-compose logs.

## Deploy your own InterMine with Docker

Instead of building our test mine, you can launch your own custom InterMine by following these instructions.

### Set Environment variables


| ENV variable  | Notes | Example |
| ------------- | ------------- | ------------- |
| MINE_REPO_URL | the git url of your mine | https://github.com/intermine/biotestmine  |
| MINE_NAME  | Name of your mine | FlyMine  |
| IM_DATA_DIR | Data directory as used in your project XML file. | /data/flymine (no trailing slash "/") |

If you do not have your mine publically hosted then you can also mount your mine files directly to the build container. Add your mine folder inside `./data/mine`  folder created by docker compose and uncomment the following line in the docker-compose.yml file. This is not recommended as the build will alter your source files.

```bash
# - ./data/mine/[PUT_YOUR_MINE_NAME_HERE]:/home/intermine/intermine/[PUT_YOUR_MINE_NAME_HERE]

```

### Update data location

Create the directory `./data/mine/data` in your **current working directory**. If you did the quickstart above, it will already have been created for you.

Uncomment the following line in intermine_builder section of your docker-compose file:

```bash
# - ./data/mine/data:/home/intermine/intermine/data
```

Update "./data/mine/data" to be the full path to your data directory. 

### Configs

Add your mine property file (e.g. flymine.properties) to the **`./data/mine/config`** folder. 

> In your properties file, do the following changes:

      db.production.datasource.serverName=postgres
      db.production.datasource.databaseName=PSQL_DB_NAME
      db.production.datasource.user=PSQL_USER
      db.production.datasource.password=PSQL_PWD
  
      db.common-tgt-items.datasource.serverName=postgres
      db.common-tgt-items.datasource.databaseName=items-PSQL_DB_NAME
      db.common-tgt-items.datasource.user=PSQL_USER
      db.common-tgt-items.datasource.password=PSQL_PWD
      
      db.userprofile-production.datasource.serverName=postgres
      db.userprofile-production.datasource.databaseName=userprofile-PSQL_DB_NAME
      db.userprofile-production.datasource.user=PSQL_USER
      db.userprofile-production.datasource.password=PSQL_PWD

      webapp.manager=TOMCAT_USER
      webapp.password=TOMCAT_PWD

The build will replace these placeholders with the generated usernames and passwords.

### Change default settings (optional)

You can configure a lot of options by creating a `.env` file in the current working directory and adding the required key value pairs. These are used as env vars by docker-compose. For example:
```bash
MINE_NAME=humanmine
MINE_REPO_URL=https://github.com/intermine/humanmine
IM_DATA_DIR=/tmp/data
```

Here are the ENV variables available.

| ENV variable  | Notes | 
| ------------- | ------------- |
| MINE_REPO_URL | the git url of your mine | 
| MINE_NAME  | Name of your mine |
| IM_DATA_DIR | Data directory as used in your project XML file. This will be used for search and replace to fix data locations inside the build container.| 
| TOMCAT_HOST_PORT  | the port of your host machine to which tomcat docker container binds to | 
