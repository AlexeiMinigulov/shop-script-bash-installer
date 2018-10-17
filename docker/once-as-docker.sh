#!/usr/bin/env bash

source /app/docker/common.sh

#== Import script args ==

github_token=$(echo "$1")

#== Provision script ==

echo "Configure composer"
composer config --global github-oauth.github.com ${github_token}
echo "Done!"

echo "Install project dependencies"
cd /app
composer --no-progress --prefer-dist install

echo "Init project"
php /app/init --env=Development --overwrite=y

echo "Apply migrations"
php /app/yii migrate --interactive=0
#php /app/yii_test migrate --interactive=0

echo "Create bash-alias 'app' for vagrant user"
echo 'alias app="cd /app"' | tee /home/vagrant/.bash_aliases

echo "Enabling colorized prompt for guest console"
sed -i "s/#force_color_prompt=yes/force_color_prompt=yes/" /home/alexey/.bashrc
