#!/bin/bash

RECEIVER_EMAIL=anubhavlinus@gmail.com  # Change this to required receiver email address
SENDER_EMAIL=b21087@students.iitmandi.ac.in # Change this to your sender email address

# array of "Actions" which will trigger the email 
# Action has been explained in the report of this challenge
TRIGGER_OUTPUTS=( "destroy" "stop" "kill" "oom" "pause" "unpause" "die" )  

# Declaring a dictionary in which Key is "Action" and Value is some details about the event which will be sent in the email
declare -A DETAILS
DETAILS["destroy"]="Container destroyed"
DETAILS["stop"]="Container stopped"
DETAILS["kill"]="Container killed"
DETAILS["oom"]="Out-of-memory event in the container"
DETAILS["pause"]="Container paused"
DETAILS["unpause"]="Container unpaused"
DETAILS["die"]="Container died"


# This loop will run infinitely [real-time monitoring] and will check for the events in the docker
while VAR= read -r line; do     # "line" variable will store one event log from docker in json format
    
    # Getting current timestamp 
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Creating a JSON object with timestamp and event log 
    json_output="{ \"timestamp\": \"$timestamp\", \"event\": $line }"

    # Extracting the "Action" from the event log
    OUTPUT=`echo $json_output | jq '.event.Action'`  

    # Checking if the "Action" is in the array of trigerring actions[TRIGGER_OUTPUTS]
    for element in "${TRIGGER_OUTPUTS[@]}"; do

        #checking if the Action of current event is a triggering action
        if [ $OUTPUT == '"'$element'"' ]; then

            # Extracting the required details from the event log
            # More details can be extracted from the event log if required
            # *I have extracted only some of the details which I felt were important*
            TIME=`echo $json_output | jq '.timestamp'`
            ID=`echo $json_output | jq '.event.Actor.ID'`
            IMAGE=`echo $json_output | jq '.event.Actor.Attributes.image'`
            NAME=`echo $json_output | jq '.event.Actor.Attributes.name'`

            # Creating a message to be sent in a txt file by echoeing the required details into it
            
            echo $'FROM:'$SENDER_EMAIL > msg.txt
            echo $'SUBJECT:Sysadmin test 2023 - Challenge 2' >> msg.txt
            echo $'TO: '$RECEIVER_EMAIL >> msg.txt
            echo $'\nTimestamp: '$TIME >> msg.txt   # Timestamp of the event
            echo $'Container ID: '$ID >> msg.txt  # ID of the concerned container
            echo $'Image Name: '$IMAGE >> msg.txt # Image which was running in the concerned container
            echo $'Action on container: '$OUTPUT >> msg.txt   # triggering action
            echo $'Details: '${DETAILS[$element]} >> msg.txt  # appending corresponding details of triggering action

            # *I have used ssmtp to send the email*
            # Text in msg.txt will be sent as email to the RECEIVER_EMAIL address
            ssmtp $RECEIVER_EMAIL < msg.txt

            # uncomment the below line to see the contents of sent email
            # cat msg.txt

            #removing the msg.txt file
            rm msg.txt
            break
        fi
    done
done < <(docker events --format "{{json .}}")   #reading the docker events in json format
