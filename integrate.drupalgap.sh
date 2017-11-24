#!/bin/bash

###################################
#        ROBOT DEVELOPMENT        #
#    integrate drupalgap script   #
#         by: Zak Schlemmer       #
###################################

#########
# Created from Example Integration Script from Robot Development Repository
#########

# just list the project names you will be integrating
for project in d7dg7 d7dg8 d8dg8
do
    # update local /etc/hosts
    export project=$project
    if [ `uname -s` == "Darwin" ]; then
        sudo -E bash -c 'echo "10.254.254.254 ${project}.robot" >> /etc/hosts'
    else
        sudo -E bash -c 'echo "172.72.72.254 ${project}.robot" >> /etc/hosts'
    fi
    if [ `grep -c ${project}  /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf` == "0" ]; then
        # find project web port for robot-nginx integration
        port=`cat /etc/robot/projects/drupalgap/apache2/$project.apache2.ports.conf | grep Listen | grep -v 443 | sed s'/Listen //'`
        # update nginx
        sed -i -e "s/} # the end of all the things//" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        cat /etc/robot/projects/robot-system/robot-nginx/nginx.server.template.conf >> /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        sed -i -e "s/template/${project}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
        sed -i -e "s/8080/${port}/g" /etc/robot/projects/robot-system/robot-nginx/template.nginx.conf
    fi
done

#-----------------------------------------------------------------------------------


# This part adds the IP allocation to the 'robot-nginx' container and rebuilds it

# I found it easier to set these one by one
if [ `grep -c myproject1 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject1.robot:172.72.72.121'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c myproject2 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject2.robot:172.72.72.123'" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi
if [ `grep -c myproject3 /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml` == "0" ]; then
    echo "      - 'myproject3.robot:172.72.72.125" >> /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml
fi


# I have trouble with OSX sed, and was ending up with "<modified_file_name>-e" copies of files
# feel free to let me know how I'm dumb at that so I can fix it and remove this part
find /etc/robot/projects/robot-system/robot-nginx/ -name "*-e" | xargs rm -rf


# this last part rebuilds robot-nginx to reflect the new addtions we just made

docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml build
docker-compose -p robot -f /etc/robot/projects/robot-system/robot-nginx/docker-compose.yml up -d


# let me know if you have any comments, questions, or concerns

#               !!! ENJOY !!!