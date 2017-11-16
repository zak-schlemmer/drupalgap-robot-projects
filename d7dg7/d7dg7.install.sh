#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#        drupal7 install          #
#       by: Zak Schlemmer         #
###################################


# find operating system
OS=`uname -s`

# tell the user what is happening
echo "" && echo "" && echo -e "Building $1." && echo ""

# git clone
git clone --branch 7.54 https://git.drupal.org/project/drupal.git ~/robot.dev/$1

# start auto sync and use osx-specific .yml file if using OSX
if [ "$OS" == "Darwin" ]; then
    # docker-sync
    echo "Getting docker-sync ready. Just a moment." && echo ""
    cd /etc/robot/projects/drupalgap/$1/docker-sync/
    docker-sync start --dir ~/robot.dev/docker-sync/$1
    docker update --restart=always $1-sync
    cd - > /dev/null 2>&1
    # docker-compose build / up
    docker-compose -p robot -f /etc/robot/projects/drupalgap/$1/osx-docker-compose.yml build
    docker-compose -p robot -f /etc/robot/projects/drupalgap/$1/osx-docker-compose.yml up -d
else
    # docker-compose build / up
    docker-compose -p robot -f /etc/robot/projects/drupalgap/$1/docker-compose.yml build
    docker-compose -p robot -f /etc/robot/projects/drupalgap/$1/docker-compose.yml up -d
fi
sleep 8

# drush
docker exec -t $1_web_1 bash -c "wget http://files.drush.org/drush.phar"
docker exec -t $1_web_1 bash -c "chmod +x drush.phar && mv drush.phar /usr/local/bin/drush"

# drupal install
echo "" && echo "Drupal Install" && echo ""
docker exec -t $1_web_1 bash -c "cd /$1 && drush site-install -y standard --site-name=${1} --account-name=admin --account-pass=robot --account-mail=admin@robot.com --db-url=mysql://root:root@${1}-db:3305/${1}"
docker exec -t $1_web_1 bash -c "cd /$1 && drush cc all"

# fix permissions
docker exec -t $1_web_1 bash -c "cd /$1/sites/default && chmod 644 default.settings.php settings.php"
docker exec -t $1_web_1 bash -c "chown -R robot:robot /$1"


# optional memcache bits
#remove me memcache#docker exec -t $1_web_1 bash -c "cd /$1 && drush en -y memcache"
#remove me memcache#cat /etc/robot/projects/drupalgap/$1/memcache/template.drupal7.settings.php >> ~/robot.dev/${1}/sites/default/settings.php
#remove me memcache#docker exec -t $1_web_1 bash -c "cd /$1 && drush en -y memcache_admin"

# everything done
echo "" && echo "$1 - Finished" && echo ""