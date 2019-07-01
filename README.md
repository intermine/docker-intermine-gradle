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

### Pull images from Docker Hub and start mine
```bash
docker-compose -f dockerhub.docker-compose.yml up 
```

Wait for 10-15 mins for the build to finish. Then visit **`localhost:9999/biotestmine`**
to visit your mine (yes it is that easy now!!)
> to surely determine whether build is finished or not, search for `intermine_builder exited with code 0` message in your docker-compose logs.
## Customizing your mine instance

### Using a custom mine
You can use your custom mine for the builds. Just set the git url of your mine to the env var `MINE_URL`. (directory structure similar to biotestmine is assumed)

If you do not have your mine hosted on github then you can also mount your mine files directly to the container. Just add your mine files inside /data/mine folder created by docker compose and uncomment the respective lines
    in the docker-compose.yml file.


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
 - MINE_URL
    - Add you mine github url. It will be used to pull your mine inside build container
    > You can also mount your mine files directly to the container. Just add your mine files inside /data/mine folder created by docker compose and uncomment the respective lines
    in the docker-compose.yml file.  
 - TOMCAT_HOST_PORT
    - Set the port of your host machine to which tomcat docker container binds to. This is the port that you will use to access the mine webapp.
