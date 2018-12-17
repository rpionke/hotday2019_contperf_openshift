#!/bin/bash

entries=$(curl https://art25310.live.dynatrace.com/api/v1/deployment/installer/agent/connectioninfo?Api-Token=lb8yfSgOSTWmS0xVTavsy | jq -r '.communicationEndpoints[]')

mkdir se_tmp
touch se_tmp/hosts
touch se_tmp/service_entries_oneagent.yml
touch se_tmp/service_entries

cat ../manifests/istio/service_entries_tpl/part1 >> se_tmp/service_entries_oneagent.yml

for row in $entries; do
    row=$(echo $row | sed 's~https://~~')
    row=$(echo $row | sed 's~/communication~~')
    echo -e "  - $row" >> se_tmp/hosts
    # sed -i '' 's/ENDPOINT_PLACEHOLDER/'"$row"'/' ../manifests/manifests-istio/service_entry_tmpl | echo
    cat ../manifests/istio/service_entry_tmpl | sed 's~ENDPOINT_PLACEHOLDER~'"$row"'~' >> se_tmp/service_entries
done

cat se_tmp/hosts >> se_tmp/service_entries_oneagent.yml
cat ../manifests/istio/service_entries_tpl/part2 >> se_tmp/service_entries_oneagent.yml
cat se_tmp/hosts >> se_tmp/service_entries_oneagent.yml
cat ../manifests/istio/service_entries_tpl/part3 >> se_tmp/service_entries_oneagent.yml
cat se_tmp/service_entries >> se_tmp/service_entries_oneagent.yml

# todo: oc apply

rm -r se_tmp