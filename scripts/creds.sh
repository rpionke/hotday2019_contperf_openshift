#!/bin/bash

# TODO - these cred placeholders will be replaced in the Bastian Host setup process!
export DTENV=DTENV_PLACEHOLDER
export DTAPI=DTAPI_PLACEHOLDER
export DTPAPI=DTPAPI_PLACEHOLDER
export NLAPI=NLAPI_PLACEHOLDER

CREDS=./creds.json
cp ./creds.sav $CREDS

echo Please enter the credentials as requested below:  
read -p "Dynatrace Tenant: (default=$DTENV)" DTENVC
read -p "Dynatrace API Token: (default=$DTAPI) " DTAPIC
read -p "Dynatrace PaaS Token: (default=$DTPAPI) " DTPAAST
read -p "NeoLoadWeb Api KEY: (default=$NLAPI)" NLWEBAPI
read -p "github User Name: " GITU 
read -p "github Personal Access Token: " GITAT
read -p "github User Email: " GITE
read -p "github Organization: " GITO
echo ""

if [ $DTENVC != '' ]
then 
  DTENV=$DTENVC
fi

if [ $DTAPIC != '' ]
then 
  DTAPI=$DTAPIC
fi

if [ $DTPAAST != '' ]
then 
  DTPAPI=$DTPAAST
fi

if [ $NLWEBAPI != '' ]
then 
  NLAPI=$NLWEBAPI
fi

echo ""
echo "Please confirm all are correct:"
echo "Dynatrace Tenant: $DTENV"
echo "Dynatrace API Token: $DTAPI"
echo "Dynatrace PaaS Token: $DTPAPI"
echo "NeoLoad Web API Key :$NLAPI"
echo "github User Name: $GITU"
echo "github Personal Access Token: $GITAT"
echo "github User Email: $GITE"
echo "github Organization: $GITO" 
read -p "Is this all correct?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sed -i 's/DYNATRACE_TENANT_PLACEHOLDER/'"$DTENV"'/' $CREDS
  sed -i 's/DYNATRACE_API_TOKEN/'"$DTAPI"'/' $CREDS
  sed -i 's/DYNATRACE_PAAS_TOKEN/'"$DTPAPI"'/' $CREDS
  sed -i 's/GITHUB_USER_NAME_PLACEHOLDER/'"$GITU"'/' $CREDS
  sed -i 's/PERSONAL_ACCESS_TOKEN_PLACEHOLDER/'"$GITAT"'/' $CREDS
  sed -i 's/GITHUB_USER_EMAIL_PLACEHOLDER/'"$GITE"'/' $CREDS
  sed -i 's/GITHUB_ORG_PLACEHOLDER/'"$GITO"'/' $CREDS
  sed -i 's/NL_WEB_API_KEY_PLACEHOLDER/'"$NLAPI"'/' $CREDS

fi
cat $CREDS
echo ""
echo "the creds file can be found here:" $CREDS
echo ""
