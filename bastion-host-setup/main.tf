/*
   BASTION HOST generation
*/

// Configure the Google Cloud provider
provider "google" {
  // see here how to get this file
  // https://console.cloud.google.com/apis/credentials/serviceaccountkey 
  credentials = "${file("sai-research-a5aa3362e25a.json")}"
  project     = "sai-research"
  region      = "us-west1"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
  name         = "acm-bastion-${random_id.instance_id.hex}"
  machine_type = "f1-micro" // size of the bastion host
  zone         = "us-west1-a" 

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-1804-lts" // OS version
      size = "40" // size of the disk in GB
    }
  }

  /* Startup script to make sure everything is installed
    - git
    - hub
    - docker
    - oc
    - kubectl
    - gcloud (comes by default with this instance)
    - istioctl
    - node8
    - npm
  */ 
  metadata_startup_script = <<EOF
    sudo apt-get update;
    sudo apt-get install git -y; 
    sudo snap install --classic hub; 
    sudo apt-get install -y 
    apt-transport-https 
    ca-certificates 
    curl 
    software-properties-common;
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -;
    sudo add-apt-repository 
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu 
      $(lsb_release -cs) 
      stable";
    sudo apt-get install docker-ce -y;
    sudo wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz; 
    sudo tar xzvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz; 
    sudo cp openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /bin/; 
    sudo cp openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/kubectl /bin/; 
    sudo wget https://github.com/istio/istio/releases/download/1.0.4/istio-1.0.4-linux.tar.gz; 
    sudo tar xzvf istio-1.0.4-linux.tar.gz; 
    sudo cp istio-1.0.4-linux/bin/istioctl /bin/; 
    sudo apt-get install nodejs -y; 
    sudo apt-get install npm -y;
  EOF

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
      nat_ip = "${google_compute_address.static.address}"
    }
  }

  metadata {
    sshKeys = "acl:${file("./key.pub")}"
  }
}

output "ip" {
 value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
