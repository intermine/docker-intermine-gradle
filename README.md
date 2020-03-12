# docker-intermine-gradle

You can use these docker images to create your own InterMine instance. You can launch our test InterMine (BioTestMine) or you can use your own data to build a custom mine.

## Requirements

 - [Docker](https://docs.docker.com/install/)
 - [Docker compose](https://docs.docker.com/compose/install/)

## Quickstart

If you're not logged in as root, you will need to create the volume directories which will be shared with the docker containers, to avoid permission errors. This can be done by using the convenience script.

```bash
./mkdatadirs.sh local.docker-compose.yml
```

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

### Environment variables

| ENV variable  | Description | Default | Example |
| ------------- | ------------- | ------------- | ------------- |
| MINE_REPO_URL | The Git URL of your mine | https://github.com/intermine/biotestmine | https://github.com/intermine/flymine |
| MINE_NAME  | Name of your mine | biotestmine | FlyMine |
| IM_DATA_DIR | Data directory as used in your project XML file. | `/data` | `/data/flymine` |
| IM_REPO_URL | The Git URL of the InterMine to build | https://github.com/intermine/intermine | https://github.com/yourfork/intermine |
| IM_REPO_BRANCH | The branch to checkout in IM_REPO_URL | master | dev |
| TOMCAT_HOST_PORT | Tomcat will bind to this port on your host machine | 9999 | 1234 |

**Additional notes:**
- At least one of *IM_REPO_URL* or *IM_REPO_BRANCH* need to be specified to trigger a custom build of InterMine. This build of InterMine will then be used to build your mine.
- *IM_DATA_DIR* should not have a trailing slash (`/`)

### Update data location

We now need to tell Docker where the data is located.

1. Create the directory `./data/mine/data` in your **current working directory**. If you did the quickstart above, it will already have been created for you.

2. Uncomment the following line in intermine_builder section of your docker-compose file:

```bash
# - ./data/mine/data:/home/intermine/intermine/data
```

3. Update `./data/mine/data` to be the absolute path to your data directory. 

### Configs

Add your mine property file (e.g. flymine.properties) to the **`./data/mine/config`** folder. 

In your properties file, do the following changes:

```
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
```

The build will replace these placeholders with the generated usernames and passwords.

### Change default settings (optional)

You can configure a lot of options by creating a `.env` file in the current working directory and adding the required key value pairs. These are used as env vars by docker-compose. For example:
```bash
MINE_NAME=humanmine
MINE_REPO_URL=https://github.com/intermine/humanmine
IM_DATA_DIR=/tmp/data
```
