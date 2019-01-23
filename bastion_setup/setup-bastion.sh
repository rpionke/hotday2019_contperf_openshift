#!/bin/bash

cd ~

# Will make sure the bastion host is setup with all necessary tools such as hub and j2
sudo wget https://github.com/github/hub/releases/download/v2.6.0/hub-linux-amd64-2.6.0.tgz
tar -xzf hub-linux-amd64-2.6.0.tgz
sudo cp hub-linux-amd64-2.6.0/bin/hub /bin/
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq
chmod +x jq
mv jq /usr/bin/

# clone workshop repo - first remove the dir in case it was already there
rm -rf hotday2019_contperf_openshift
git clone https://github.com/grabnerandi/hotday2019_contperf_openshift

# now lets update creds with our studentid
if [[ $STUDENTID = '' ]]
then 
  STUDENTID=0
fi
export DT_TENANT_ID=$(cat init.json | jq -r '.students[$STUDENTID].tenant')
export DT_PAAS_TOKEN=$(cat init.json | jq -r '.students[$STUDENTID].paastoken')
export DT_API_TOKEN=$(cat init.json | jq -r '.students[$STUDENTID].apitoken')
export NL_WEB_API_KEY=$(cat init.json | jq -r '.students[$STUDENTID].nltoken')

echo $DT_TENANT_ID
echo $DT_PAAS_TOKEN
echo $DT_API_TOKEN
echo $NL_WEB_API_KEY

sed -i 's/DTENV_PLACEHOLDER/'"$DT_TENANT_ID"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/DTAPI_PLACEHOLDER/'"$DT_PAAS_TOKEN"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/DTPAPI_PLACEHOLDER/'"$DT_API_TOKEN"'/' ./hotday2019_contperf_openshift/scripts/creds.sh
sed -i 's/NLAPI_PLACEHOLDER/'"$NL_WEB_API_KEY"'/' ./hotday2019_contperf_openshift/scripts/creds.sh