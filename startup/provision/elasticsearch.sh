#!/bin/bash

set -o errexit

WAIT_TIMEOUT=5
CHECK_ATTEMPTS=10
HTTP_OK=200
ROOT_PATH="$(realpath $(dirname $(realpath $0))/../..)"


function get_elastic_status {
    echo $(curl -w '%{http_code}' -o /dev/null -s localhost:9200)
}

function check_elastic_availability {
    printf "Checking Elasticsearch availability"
    local check_num=0
    while [[ $(get_elastic_status) -ne "${HTTP_OK}" && "${check_num}" -lt "${CHECK_ATTEMPTS}" ]]; do
        let "check_num += 1"
        printf "ElasticSearch is not available. Waiting for %s seconds" "${WAIT_TIMEOUT}"
        sleep "${WAIT_TIMEOUT}"
    done
    if [[ "${check_num}" -gt "${CHECK_ATTEMPTS}" ]]; then
        printf "Checking timeout reached. Exiting."
        exit 1
    fi
    printf "Elasticsearch has been started."
}

function init {
    yum install -y epel-release java-1.8.0-openjdk.x86_64 \
                   https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.rpm

    sed -i 's/^.*network.host.*/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml

    systemctl enable elasticsearch
    systemctl start elasticsearch
}

function main {
    init 
    check_elastic_availability
    
    curl -o /dev/null \
         -s \
         -H 'Content-Type: application/x-ndjson' \
         -XPOST 'localhost:9200/luxsoft/doc/_bulk?pretty' \
         --data-binary "@${ROOT_PATH}/data/sample_data.json"
}

main
