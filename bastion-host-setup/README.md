# Bastion Host Setup

The provisioning of the bastion host is scripted via Terraform.
The script will provide a compute instance in the Google Cloud.

## Terraform file

If needed, adapt the values in the `main.tf` file.


## Provisioning

1. Initialize Terraform

    ``` 
    $ terraform init
    ```

1. Plan and apply the provisioning

    ```
    $ terraform plan
    $ terraform apply
    ```

    During the `terraform apply` step you will be asked to confirm the provisioning of the resources.

    The output will look similar to this:
    ```
    ...

    Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

    Outputs:

    ip = xx.xx.xx.xx
    ```

1. Connect to the bastion host.
    ```
    $ ssh acl@`terraform output ip`
    ```

1. Clean up once the bastio host is not needed anymore.

    ```
    $ terraform destroy
    ```