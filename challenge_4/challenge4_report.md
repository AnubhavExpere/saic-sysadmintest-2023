# Challenge-4: Docker and Networking

 As it was asked that images have to be deployed using their image id(s) but I was not able to find the image id of the provided image metavinayak/matrix on Dockerhub. So, I pulled the image first and then used its local image id to deploy it and perform other tasks. After researching, I found that nginx is used for load balancing and its configuration (.conf) file is used for the same. Hence, I have used it for the load balancing task and it performs the load balancing in **Round-Robin method** (it can be changed easily).

On searching for custom log formats for docker, I again found that nginx can be used. To show the load balancing I used the command:`docker-compose logs -f` [in the same directory as compose file].

The default logging method logs for each container separately which makes it harder for us to manage and monitor all the containers running with the same image because we have to access each log separately. Nginx stores access logs and error logs in separate log files in the container itself which is not persistent, and it does not show to which instance/container the log belongs to. We have to store logs on some persistent storage as the log of a container is lost once the container is removed/deleted and add the container details also to the log. 

## Details of the solution
  
- I have created a **bash script** which will create `N_INSTANCES` number of instances of the image with load balancing.
- Script stores local image id in .env file for Docker compose file to access the image.
- Change `IMAGE_NAME` variable to the required Dockerhub image and `N_INSTANCES` to required number of instance of the image.
- On running the script `N_INSTANCES` number of instances will be started of the image with name `IMAGE_NAME` on Dockerhub. 
- All file must be in the same directory for script to run, i.e. `docker_hub_deploy.script, compose.yaml, nginx.conf, .env`

Docker compose file `compose.yaml` is used to run nginx and Dockerhub image simultaneoulsy with load balancing and nginx configuration file has been added into the image using `volume`.

```yml
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

Code which has to be added in nginx configuration file (`nginx.conf` in this folder only):
```apacheconf
http {
    server {
        listen 3000;
        location / {
            proxy_pass http://matrix:3000;
        }
    }
}
events{
    worker_connections 1024;
}
```

#### Load Balancing Illustration Video: [Click here](https://drive.google.com/drive/folders/16TLg086u2oC4Fvwrpz9C5RuPykFqfh2c?usp=drive_link)

---

### Log format

***Nginx logs can easily be modified by adding log format into its configuratiion file and setting log format for access and error log as I have done in `nginx.conf`***

1. Making logs persistent: map the logs directory in nginx container to persistent directory `logs` on the host

```yml
	volumes:
        ./logs:/var/log/nginx
```

2. Including container identification in access log:
    - Initially I was using **matavinayak/matrix** image which does not log the container ID, then I saw  **matavinayak/matrix-custom** image description, it stated that it logs host info. It logs host info in the container log.
    - I tried to access container ID using **nginx variable** in `log_format` in nginx.conf but I could not find it.
    - Then, I tried to include each container log running that image into `access.log` file but I was not able to do so even after spending a lot of time on it.  

*I accessed a url which does not exist on **metavinayak/matrix** image. It produced an error 404 but did not reflect in the error.log file, I think the application is not mapped to the stderr output stream.

****change the respective listen ports if ports of nginx service is modified***

## STEPS TO RUN THE SCRIPT

1. Add execution permission to the script: `sudo chmod +x <script_path>`
2. Change variables in the script if required, i.e. `IMAGE_NAME, N_INSTANCES`.
3. Run the script `docker_hub_deploy.script`
4. You can use `docker-compose logs -f` command to check if load balancing is working [being in the same directory as compose file].



***comments are also added in script***