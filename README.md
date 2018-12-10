# Provision ACM Workshop Cluster on OpenShift

This repository contains all scripts and instructions needed to deploy the ACM Sockshop demo to OpenShift (3.11).
## Prerequisites:

* jq (https://stedolan.github.io/jq/) has to be installed to run the setup script.
* A GitHub Organization to fork the Sockshop application to
* A GitHub Personal Access Token
* OpenShift command line util (oc), and logged in to your cluster
* Git

## Instructions:
1. Execute the `~/forkGitHubRepositories.sh` script in your home directory. This script takes the name of the GitHub organization you have created earlier.

    ```
    $ ./forkGitHubRepositories.sh <GitHubOrg>
    ```

    This script `clone`s all needed repositories and the uses the `hub` command ([hub](https://hub.github.com/)) to fork those repositories to the passed GitHub organization. After that, the script deletes all repositories and `clone`s them again from the new URL.
    
1. Insert information in ./scripts/creds.json

1. Execute ./scripts/createJenkins.sh

Manual configuration step in Jenkins: Configure the Performance Signature Plugin (add the Dynatrace Server + API Token).

