#!/bin/bash

# convenience script if you don't want to apply all yaml files manually
# configure the host path volume plugin
oc create -f ../manifests/oc-scc-hostpath.yml
oc patch scc hostpath -p '{"allowHostDirVolumePlugin": true}'
oc adm policy add-scc-to-group hostpath system:authenticated

oc create -f ../manifests/k8s-namespaces.yml 

oc create -f ../manifests/k8s-jenkins-pvcs.yml 
oc create -f ../manifests/k8s-jenkins-deployment.yml
oc create -f ../manifests/k8s-jenkins-rbac.yml

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
oc describe secret $PUSHER_TOKEN

# create a route for the jenkins service

# manual step: add pusher token as credential in jenkins. the id of the credential pair should be 'registry-creds'

# manual step: add credentials with personal access token for github user with id 'git-credentials-acm'

# manual step: configure perfsig plugin in jenkins (add dynatrace server)
