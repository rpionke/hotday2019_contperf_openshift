#!/bin/bash
if [ $# -lt 5 ]
  then
  echo "usage: ./builder.sh <GUID> <INDEX> <OCPADMIN> <OCPPWD> <COUNT>"
  exit
fi

GUID=$1
INDEX=$2
OCPADMIN=$3
OCPPWD=$4
COUNT=$5

while [ $COUNT -gt 0 ]
do
HOST=bastion.student${GUID}.ocpworkshop.dtinnovationlabs.net

# execution
scp -i ~/.ssh/ocpworkshop.pem ./setup-bastion* ec2-user@${HOST}:~/
ssh -i ~/.ssh/ocpworkshop.pem -t $HOST bash -c "'
export HOST=$HOST
echo $HOST
export INDEX=$INDEX
echo $INDEX
export GUID=$GUID
echo $GUID
export OCPADMIN=$OCPADMIN
export OCPPWD=$OCPPWD
chmod +x ~/setup-bastion.sh
~/setup-bastion.sh $INDEX $OCPADMIN $OCPPWD > $GUID.log 2>&1
rm -rf setup*
rm -rf hub*
'"
scp -i ~/.ssh/ocpworkshop.pem ec2-user@${HOST}:~/${GUID}.log ./logs/
let COUNT=($COUNT - 1)
let GUID=($GUID + 1)
let INDEX=($INDEX + 1)
done