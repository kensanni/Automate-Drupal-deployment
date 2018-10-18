#!/usr/bin/env bash

installAnsible () {
  sudo apt-get update
  sudo apt-get install software-properties-common -y
  sudo apt-add-repository ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get install ansible -y
}

installCerbot () {
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install python-certbot-nginx -y
}

main () {
  installAnsible
  installCerbot
}

main