#!/bin/bash

cd ../manifests/backend-services/user-db
oc apply -f dev/
oc apply -f staging/
oc apply -f production/

cd ../shipping-rabbitmq
oc apply -f dev/
oc apply -f staging/
oc apply -f production/

cd ../carts-db
oc apply -f carts-db.yml

cd ../catalogue-db
oc apply -f catalogue-db.yml

cd ../orders-db
oc apply -f orders-db.yml

cd ../../sockshop-app
oc apply -f dev/
oc apply -f staging/
oc apply -f production/


