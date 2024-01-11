#!/bin/bash

IMAGE_NAME=metavinayak/matrix-custom  #paste the image name here

#number of instances of the image to be deployed
N_INSTANCES=3   #change this to required number of instances

# pulling the image from docker hub
docker pull $IMAGE_NAME 

# Extracting the local image id of the pulled image 
IMAGE_ID=`docker images --filter=reference=$IMAGE_NAME --format "{{.ID}}"` 

# Creating a .env file which will be used by docker-compose.yml file to get variables
# .env file has the extracted IMAGE_ID variable to be used by docker-compose.yml file
echo "IMAGE_ID=$IMAGE_ID" > ./.env

# Running the docker-compose.yml file
docker compose up -d --scale matrix=$N_INSTANCES #running N_INSTANCES instances of the image  





