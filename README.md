# docker-intermine-gradle
Docker for InterMine

## Requirements
 - Docker
 - Docker compose

## Quickstart
### Build images locally and start mine
```bash
docker-compose -f local.docker-compose.yml up --build
```

### Pull images from Dokcer Hub and start mine
```bash
docker-compose -f dockerhub.docker-compose.yml up 
```

Wait for 10-15 mins for the build to finish. Then visit **`localhost:9999/biotestmine`**
to visit your mine (yes it is that easy now!!)
> to surely determine whether build is finished or not, search for `intermine_builder exited with code 0` message in your docker-compose logs.
## Customizing your mine instance

### Adding data and project configs

After quickstart you have a data folder created at your current working directory.

Add your data files to **`data/mine/data`** folder.

> Remeber to create a folder for each of your data files

Add your config files to **`data/mine/config`** folder.

### Changing default settings
You can configure a lot of options by just creating a .env file in the current working directory and adding the required key value pairs.

Available options are:
 - MINE_NAME
    - Set your desired mine name here.
 - TOMCAT_HOST_PORT
    - Set the port of your host machine to which tomcat docker container binds to. This is the port that you will use to access the mine webapp.