#!/bin/bash
DT_TENANT_ID=$1
DT_PAAS_TOKEN=$2

oc adm policy add-scc-to-user anyuid -z default -n production
oc adm policy add-scc-to-user privileged -z default -n production

export MASTER_URL_TMP=$(oc config view -o=json | jq -r '.["current-context"]' | sed -e 's/[^\/]*\///')
IFS=':' read -ra MASTER_URL <<< "$MASTER_URL_TMP"

oc new-project istio-operator
oc new-app -f https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.3/istio/istio_product_operator_template.yaml --param OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=$MASTER_URL --param OPENSHIFT_RELEASE=v3.11.16

oc create -f ../manifests/istio/istio-installation.yml

# wait for the istio installation to complete - usually takes quite some time
sleep 250

oc project istio-system
oc create -f ../manifests/istio/istio-gateway.yml

oc label namespace production istio-injection=enabled

./create-service-entry.sh DT_TENANT_ID DT_PAAS_TOKEN