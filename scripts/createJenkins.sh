#!/bin/bash

# convenience script if you don't want to apply all yaml files manually

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
export GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
export DT_TENANT_URL=$(cat creds.json | jq -r '.dynatraceTenant')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')

sed -i '' 's/GITHUB_USER_EMAIL_PLACEHOLDER/'"$GITHUB_USER_EMAIL"'/' ../manifests/k8s-jenkins-deployment.yml
sed -i '' 's/GITHUB_ORGANIZATION_PLACEHOLDER/'"$GITHUB_ORGANIZATION"'/' ../manifests/k8s-jenkins-deployment.yml
sed -i '' 's/DOCKER_REGISTRY_IP_PLACEHOLDER/docker-registry.default.svc/' ../manifests/k8s-jenkins-deployment.yml
sed -i '' 's/DT_TENANT_URL_PLACEHOLDER/'"$DT_TENANT_URL"'/' ../manifests/k8s-jenkins-deployment.yml
sed -i '' 's/DT_API_TOKEN_PLACEHOLDER/'"$DT_API_TOKEN"'/' ../manifests/k8s-jenkins-deployment.yml

# configure the host path volume plugin
oc create -f ../manifests/oc-scc-hostpath.yml
oc patch scc hostpath -p '{"allowHostDirVolumePlugin": true}'
oc adm policy add-scc-to-group hostpath system:authenticated

oc create -f ../manifests/k8s-namespaces.yml 

oc create -f ../manifests/k8s-jenkins-pvcs.yml 
oc create -f ../manifests/k8s-jenkins-deployment.yml
oc create -f ../manifests/k8s-jenkins-rbac.yml
oc project cicd
# create a route for the jenkins service
oc expose svc/jenkins

# store the jenkins route in a variable
export JENKINS_URL=$(oc get route jenkins -o=json | jq -r '.spec.host')

# set up the OpenShift registry
oc new-project sockshop-registry
oc project sockshop-registry
oc create serviceaccount pusher
oc policy add-role-to-user system:image-builder system:serviceaccount:sockshop-registry:pusher


oc create -f ../manifests/oc-imagestreams.yml

oc policy add-role-to-user system:image-puller system:serviceaccount:dev:default -n sockshop-registry
oc policy add-role-to-user system:image-puller system:serviceaccount:staging:default -n sockshop-registry
oc policy add-role-to-user system:image-puller system:serviceaccount:production:default -n sockshop-registry

oc describe sa pusher
export PUSHER_TOKEN=$(oc describe sa pusher | grep -m1 pusher-token | sed -e 's/^[ \t]*//')
export TOKEN_VALUE=$(oc describe secret $PUSHER_TOKEN | grep token: | sed -e 's/token:[ \t]*//')
echo $TOKEN_VALUE

# create the backend services for the sockshop (user-db shipping-queue)
./backend-services.sh

# set up credentials in Jenkins
sleep 300
curl -X POST http://$JENKINS_URL/credentials/store/system/domain/_/createCredentials --user $JENKINS_USER:$JENKINS_PASSWORD \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "registry-creds",
    "username": "user",
    "password": "'$TOKEN_VALUE'",
    "description": "test",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

curl -X POST http://$JENKINS_URL/credentials/store/system/domain/_/createCredentials --user $JENKINS_USER:$JENKINS_PASSWORD \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "git-credentials-acm",
    "username": "'$GITHUB_USER_NAME'",
    "password": "'$GITHUB_PERSONAL_ACCESS_TOKEN'",
    "description": "test",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

# manual step: configure perfsig plugin in jenkins (add dynatrace server)
