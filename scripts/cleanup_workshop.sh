#!/bin/bash

# THIS SCRIPT CAN BE USED TO CLEAN UP THE SOCKSHOP DEPLOYMENT #
oc adm policy remove-scc-from-group hostpath system:authenticated
oc delete -f ../manifests/oc-scc-hostpath.yml
oc delete -f ../manifests/k8s-jenkins-rbac.yml
oc delete -f ../manifests/k8s-jenkins-neotys-rbac.yml
oc delete -f ../manifests/istio/istio-gateway.yml
oc delete -f ../manifests/isito/istio-installation.yml
oc adm policy remove-scc-from-user anyuid -z default -n production
oc adm policy remove-scc-from-user privileged -z default -n production
oc delete projects cicd cicd-neotys dev staging production sockshop-registry istio-system istio-operator
kubectl delete mutatingwebhookconfiguration istio-sidecar-injector

# This cleansup Dynatrace OneAgent
oc delete -n dynatrace oneagent --all
oc delete -f https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/master/deploy/openshift.yaml
oc delete project dynatrace