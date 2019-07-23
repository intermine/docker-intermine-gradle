# docker-intermine-gradle
Docker for InterMine

## Requirements
 - Docker
 - Docker compose

## Quickstart
### Option 1: Build images locally and start mine
```bash
docker-compose -f local.docker-compose.yml up --build --force-recreate
```

### Option 2: Pull images from Docker Hub and start mine
```bash
docker-compose -f dockerhub.docker-compose.yml up 
```

Wait for 10-15 mins for the build to finish. Then visit **`localhost:9999/biotestmine`**
to visit your mine (yes it is that easy now!!)
> to surely determine whether build is finished or not, search for `intermine_builder exited with code 0` message in your docker-compose logs.
## Customizing your mine instance

### Using a custom mine
You can use your custom mine for the builds. 

#### Step 1

- Set the git url of your mine to the env var `MINE_REPO_URL`. (directory structure similar to biotestmine is assumed)


   If you do not have your mine hosted on github/gitlab then you can also mount your   mine files directly to the build container. Add your mine folder inside `./data/mine`  folder created by docker compose and uncomment the following line in the    docker-compose.yml file. 
   ```bash
   # - ./data/mine/[PUT_YOUR_MINE_NAME_HERE]:/home/intermine/intermine/ [PUT_YOUR_MINE_NAME_HERE]

   ```
   > Note: build will do a few changes to your mine files when mine files are directly mounted to the build container. So, it is recommended to use a copy of your mine for the build. This is not the case when you are using MINE_REPO_URL to pull mine files.

#### Step 2
- Set `MINE_NAME` env var to your mine name.

   > Make sure that the folder name matches with your mine name.

#### Step 3
- Set `IM_DATA_DIR` env var to the data dir prefix that you have in your project.xml file. This will be used for search and replace to fix data locations inside the build container.

  > Note: DO NOT add the trailing "/"

#### Step 4
- Follow [Adding data and project configs](#adding-data-and-project-configs) section to load data and config to your mine.


### Adding data and project configs

#### Data

After quickstart you have a data folder created at your **current working directory**. 

You can also create the folder structure on your own if you do not want to do a quickstart. Create a folder structure like `./data/mine/data`  

Add your data files to **`./data/mine/data`** folder and then uncomment the following line in intermine_builder section of your docker-compose file:
```bash
# - ./data/mine/data:/home/intermine/intermine/data
```

 If you do not want to copy your data files over then change location of data files in your docker-compose file from **`./data/mine/data`** folder to your desired folder location in docker-compose.yml file.

> Remeber to create a folder for every data source you use. Also make sure that you have appropriate permissions for mounting your data dir to a docker container.

#### Configs

Add your config files to **`./data/mine/config`** folder. Configs include your properties file.

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

### Changing default settings
You can configure a lot of options by creating a `.env` file in the current working directory and adding the required key value pairs. These are used as env vars by docker-compose. For example:
```bash
MINE_NAME=humanmine
MINE_REPO_URL=https://github.com/julie-sullivan/humanmine
IM_DATA_DIR=/tmp/data
```

Available options are:
 - MINE_NAME

   Set your desired mine name here.

 - MINE_REPO_URL
   
   Add you mine github/gitlab url. It will be used to pull your mine inside build container

 - IM_DATA_DIR

   Set it to the data dir prefix that you have in your project.xml file. This will be used for search and replace to fix data locations inside the build container.

    > Note: DO NOT add the trailing "/"

 - TOMCAT_HOST_PORT
   
   Set the port of your host machine to which tomcat docker container binds to. This is the port that you will use to access the mine webapp.
