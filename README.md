# Provision ACM Workshop Cluster

1. Prepare the GCP project so that it fulfills the following quota requirements per participant.
    - Global quotas for service `Compute Engine API` **per GKE cluster, i.e. per participant**

        | Name | Value | Details |
        | --- | --- | --- |
        | Firewall rules | 11 | One for each public IP (also the regional ones) | 
        | Forwarding rules | 8 | One for each k8s service with public IP |
        | In-use IP addresses global | 8 | One for each k8s service with public IP |
        | Routes | 2 | One for each worker node |
        | Target pools | 8 | One for each k8s service with public IP |

    - Regional quotas for service `Compute Engine API` (e.g. us-central1) **per GKE cluster, i.e. per participant**

        | Name | Value | More |
        | --- | --- | --- |
        | CPU | 16 | 2 `n1-standard-8` instances |
        | Persistent Disk Standard (GB) | 200 | 100GB for each worker node |
        | Persistent Disk SSD (GB) | 100 | 100GB in total for all PVC |
        | In-use IP addresses | 3 | IPs for k8s master and worker nodes, service LBs are counted in Global quota |

1. Create GKE clusters for participants from your local machine. Execute the following n times, where n = number of participants. Parameters that need to be adapted:
    - PROJECT_NAME (e.g. "detroit-acl-v2")
    - CLUSTER_NAME (e.g. "acllab1")
    - ZONE (e.g. "us-central1-a")

    ```
    gcloud beta container --project PROJECT_NAME clusters create CLUSTER_NAME --zone ZONE --username "admin" --cluster-version "1.10.7-gke.11" --machine-type "n1-standard-8" --image-type "UBUNTU" --disk-type "pd-standard" --disk-size "100" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias --network "projects/sai-research/global/networks/default" --subnetwork "projects/sai-research/regions/us-central1/subnetworks/default" --addons HorizontalPodAutoscaling,HttpLoadBalancing --no-enable-autoupgrade --no-enable-autorepair
    ```

1. Create service accounts for participants

    ```
    $ scripts/createGcloudServiceAccounts.sh n
    ```

1. Provision bastion host

   - To be done
   - make sure all files needed lie in the /etc/skel directory, so those files get automatically copied over to the users directory as soon as the user is created

1. Create user accounts and home directories for participants on bastion host

    ```
    $ scripts/createUsers.sh 5 ACMpart2018"
    ```

1. Do gcloud authentication for participants in their user accounts

    ```
    $ scripts/configureGcloud.sh 14 us-central1-a
    ```

