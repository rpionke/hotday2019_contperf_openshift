#!/bin/bash
########################################################################################################
# This script was created to deploy hotday OCP clusters in AWS
# usage: /> ./hotday.sh <GUID> <NODE COUNT> <CLUSTER COUNT> <DEPLOY COUNT> <DEPLOY DELAY IN SECONDS> "
########################################################################################################
if [ ! $1 ]
then
  echo " usage: /> ./hotday <GUID> <NODE COUNT> <CLUSTER COUNT> <DEPLOY COUNT> <DEPLOY DELAY IN SECONDS> "
  exit
fi

# Generic Vars
ENVTYPE="ocp-workshop"
GUID=$1
echo "cluster GUID is $GUID"
if [[ $2 ]]
then
  NODES=$2
else
  NODES=1
fi
echo "nodes count = $NODES"

if [[ $3 ]]
then
  CLUSTER_COUNT=$3
else
  CLUSTER_COUNT=1
fi
echo "cluster count = $CLUSTER_COUNT"

if [[ $4 ]]
then
  DEPLOY_COUNT=$4
else
  DEPLOY_COUNT=1
fi
echo "deploying $DEPLOY_COUNT clusters at a time"

if [[ $5 ]]
then
  DEPLOY_DELAY=$5
else
  DEPLOY_DELAY=300
fi
echo "deployment groups separated by $DEPLOY_DELAY seconds"

if [ $DEPLOY_COUNT -gt $CLUSTER_COUNT ]
then
  let DEPLOY_COUNT=$CLUSTER_COUNT
fi

# Cloud Provider Settings
KEYNAME=ocpworkshop
REGION=us-east-1
CLOUDPROVIDER=ec2
HOSTZONEID='ZV8X17UOJBJNN'
BASESUFFIX='.ocpworkshop.dtinnovationlabs.net'

# OCP Vars
NODE_COUNT=$NODES
REPO_VERSION=3.11
REPO_PATH='http://d3s3zqyaz8cp2d.cloudfront.net/repos/ocp/3.11.51/'
OSRELEASE=3.11.51

# Begin Loop
x=$CLUSTER_COUNT
while [ $x -ge 1 ]
  do
  i=1
  if [ $DEPLOY_COUNT -gt $x ]
  then
    i=$x
  else
    i=$DEPLOY_COUNT
  fi
  echo "Group Count is now $i of $x "
  until [ $i -lt 1 ]
  do

ansible-playbook ansible/main.yml \
  -e "guid=student${GUID}" \
  -e "env_type=${ENVTYPE}" \
  -e "cloud_provider=${CLOUDPROVIDER}" -e "aws_region=${REGION}" \
  -e "HostedZoneId=${HOSTZONEID}" -e "key_name=${KEYNAME}" \
  -e "subdomain_base_suffix=${BASESUFFIX}" \
  -e "node_instance_count=${NODE_COUNT}" \
  -e "install_idm=htpasswd" -e "software_to_deploy=openshift" \
  -e "bastion_instance_type=t2.large" -e "master_instance_type=c4.xlarge" \
  -e "nfs_instance_type=t2.large" \
  -e "own_repo_path=${REPO_PATH}" \
  -e "osrelease=${OSRELEASE}" -e "repo_version=${REPO_VERSION}" \
  -e "email=peter.hack@dynatrace.com"  -e"output_dir=/tmp/workdir" -e@../secret.yml -vv > ~/deploylogs/logfile$GUID.txt 2>&1 &

    let i=($i-1)
    if [ $i -gt $x ]
    then
      break
    else
      let GUID=($GUID+1)
    fi
  done
  if [ $x -gt 1 ]
  then
    let x=($x-$DEPLOY_COUNT)
  else
    echo "$CLUSTER_COUNT clusters deployed"
    break
  fi
  echo "Clusters left to deploy now $x"
  echo "pausing for traffic"
  sleep $DEPLOY_DELAY
done
