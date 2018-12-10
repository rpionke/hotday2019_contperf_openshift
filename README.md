# Provision ACM Workshop Cluster on OpenShift

This repository contains all scripts and instructions needed to deploy the ACM Sockshop demo to OpenShift (3.11).
## Prerequisites:

* jq (https://stedolan.github.io/jq/) has to be installed to run the setup script.
* A GitHub Organization to fork the Sockshop application to
* A GitHub Personal Access Token

## Instructions:
Insert information in ./scripts/creds.json

Execute ./scripts/createJenkins.sh

Manual configuration step in Jenkins: Configure the Performance Signature Plugin (add the Dynatrace Server + API Token).

