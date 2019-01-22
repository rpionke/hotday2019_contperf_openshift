#!/bin/bash -eu

# Builds Jenkins Image and pushes to docker hub
docker build --no-cache -t jenkinshotday2019_neotys .
docker tag jenkinshotday2019_neotys docker.io/grabnerandi/jenkinshotday2019_neotys:0.1
docker push docker.io/grabnerandi/jenkinshotday2019_neotys:0.1