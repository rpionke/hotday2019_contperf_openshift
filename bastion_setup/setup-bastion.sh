#!/bin/bash

# Will make sure the bastion host is setup with all necessary tools such as hub and j2
sudo wget https://github.com/github/hub/releases/download/v2.6.0/hub-linux-amd64-2.6.0.tgz
tar -xzf ~/hub-linux-amd64-2.6.0.tgz
sudo cp ~/hub-linux-amd64-2.6.0/bin/hub /bin/
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq
chmod +x ~/jq
sudo mv ~/jq /usr/bin/

# clone workshop repo - first remove the dir in case it was already there
rm -rf hotday2019_contperf_openshift
git clone https://github.com/grabnerandi/hotday2019_contperf_openshift

STUDENTIX=$1
# now lets update creds with our studentid
if [[ $STUDENTIX = '' ]]
then
  STUDENTIX=0
fi

echo "Setting up StudentID=$STUDENTIX"
echo $(pwd)

export DT_TENANT_ID=$(cat ./setup-bastion-init.json | jq -r ".students[$STUDENTIX].tenant")
export DT_PAAS_TOKEN=$(cat ./setup-bastion-init.json | jq -r ".students[$STUDENTIX].paastoken")
export DT_API_TOKEN=$(cat ./setup-bastion-init.json | jq -r ".students[$STUDENTIX].apitoken")
export NL_WEB_API_KEY=$(cat ./setup-bastion-init.json | jq -r ".students[$STUDENTIX].nltoken")
export STUDENT_ID=$(cat ./setup-bastion-init.json | jq -r ".students[$STUDENTIX].studentid")

echo $DT_TENANT_ID
echo $DT_PAAS_TOKEN
echo $DT_API_TOKEN
echo $NL_WEB_API_KEY

sed -i 's/DTENV_PLACEHOLDER/'"$DT_TENANT_ID"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/DTPAPI_PLACEHOLDER/'"$DT_PAAS_TOKEN"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/DTAPI_PLACEHOLDER/'"$DT_API_TOKEN"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/NLAPI_PLACEHOLDER/'"$NL_WEB_API_KEY"'/' ./hotday2019_contperf_openshift/scripts/creds.sh

# lets login to oc
# TODO - REPLACE username & PWD with real values!!
oc login https://master1 --insecure-skip-tls-verify=true -u $2 -p $3