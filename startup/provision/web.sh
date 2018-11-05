#!/bin/bash

set -o errexit

ROOT_PATH="$(realpath $(dirname $(realpath $0))/../..)"

function init {
    echo "10.0.0.10 elastic-vm" >> /etc/hosts

    yum install -y epel-release 
    yum install -y python34-pip uwsgi uwsgi-plugin-python34 nginx

    sudo pip3 install flask requests

    systemctl enable uwsgi
    mkdir /run/{uwsgi,luxsoft_test}
    mkdir /var/log/uwsgi

    chown uwsgi:uwsgi /run/uwsgi
    chown nginx:nginx /run/luxsoft_test
    chown uwsgi:uwsgi /var/log/uwsgi 
    cp "${ROOT_PATH}/etc/uwsgi.ini" /etc/uwsgi.d/
    chown nginx:nginx /etc/uwsgi.d/uwsgi.ini
    systemctl start uwsgi

    systemctl enable nginx.service
    cp "${ROOT_PATH}/etc/luxsoft_test.conf" /etc/nginx/conf.d/
    systemctl start nginx.service
}

function main {
    init

    printf "The application is deployed. Please open http://localhost:8080 in your browser."
}

main
