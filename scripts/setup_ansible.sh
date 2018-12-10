export TOKEN=$(oc whoami -t)
export mysecret=$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random)
./ansible-tower-openshift-setup-3.3.1/setup_openshift.sh -e openshift_token=$TOKEN -e secret_key=$mysecret
