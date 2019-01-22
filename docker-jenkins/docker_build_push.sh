#!/bin/bash -eu
# Builds Jenkins Image and pushes to docker hub
docker build --no-cache -t jenkinshotday2019 .
docker tag jenkinshotday2019 grabnerandi/jenkinshotday2019:0.1
docker push grabnerandi/jenkinshotday2019:0.1