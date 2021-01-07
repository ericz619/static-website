#!/bin/bash

echo "UPDATING PACKAGES"
sudo apt-get update

echo "INSTALLING DOCKER"
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

echo "INSTALLING NODEJS"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
echo 'export NVM_DIR="/home/ubuntu/.nvm"' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ubuntu/.bashrc
# Dot source the files to ensure that variables are available within the current shell
. /home/ubuntu/.nvm/nvm.sh
. /home/ubuntu/.profile
. /home/ubuntu/.bashrc
# Install NVM, NPM, Node.JS & Grunt
nvm install --lts
nvm ls

echo "DOWNLOADING REPO"
git clone https://github.com/ericz1232/static-website.git && cd static-website && npm install && sudo docker build -t ericz99/static-website:latest . --no-cache && sudo docker -d -p 80:8080 ericz99/static-website:latest
private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
curl "http://$private_ip.com"
