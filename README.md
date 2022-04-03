Linode Static Site Infrastructure (in Kube!)
===============

The following configuration will deploy a [Linode](https://linode.com) Kubernetes Cluster and NodeBalancer with Terraform, install the necessary Kubernetes resources to serve a static website, and deploy a [Jekyll](https://jekyllrb.com/) site using Helm.

The jekyll site provided in this repo is an example and includes a basic Dockerfile and script for building and pushing the images to Dockerhub.

## Usage

### Hard-mode

#### Infrastructure

1. Clone the repo.

2. Edit the values in `.envrc` to values appropriate for your project. Run `direnv allow` once set.

        # The DockerHub repo associated with the image to build.
        export IMGREPO=

        # The Linode API key of the account to create the resources.
        # Storing API keys for an account in this fashion is _NOT RECOMMENDED_! Consider using a secrets manager to store this value locally for your project (i.e. doppler).
        export TF_VAR_token=

        # This file is created automatically when the infra is created in Terraform.
        export KUBECONFIG=./.kube-config

3. Change to the `/terraform` directory and create the LKE cluster.

        terraform apply

4. Once the infrastructure has been created, change directory to the root of the project `cd ..` and check Kubernetes connection.

        kubectl get namespaces

5. Apply the Kubernetes manifest configurations for necessary services. **_Apply in order!_**

        kubectl apply -f nginx-ingress-controller-v4.0.19.yaml
        kubectl apply -f cert-manager-v1.7.2.yaml
        kubectl apply -f cert-manager-clusterissuer.yaml

6. Navigate to the Linode NodeBalancer page, or use the following command, to acquire the Public IP address of the new LoadBalancer.

        kubectl get services

7. Create an `A` record in your DNS provider using the acquired public IP address.

#### Site Development

1. Change to the `/site` directory. _Refer to `about.markdown` in this directory for information on applying a custom Jekyll theme._

2. Run `./deploy/docker.sh` to build a new image of the site and push it to Dockerhub.

#### Deploy

1. Use `charts/site/override.yaml` to set the necessary values for the project site.

2. Install the new site. _Value files are read left->right and will overwrite in that order._

    helm install site charts/site --values charts/site/values.yaml -f charts/site/override.yaml    

#### Update the website

1. If not using _latest_ as your image tag, set the new image version tag using `appVersion` in `/charts/site/Chart.yaml`. _This may also be set by using `image.tag` in `/charts/site/values.yaml` or `/charts/site/override.yaml`._

2. Use `/site/deploy/docker.sh` to build the new image.

3. Use Helm to perform a rolling upgrade.

    helm upgrade site charts/site --values charts/site/values.yaml -f charts/site/override.yaml


## Improvement Notes

- If the NGINX Ingress Controller is not destroyed prior to destroying the infrastructure using Terraform, the Linode NodeBalancer will continue to exist within the account. This must be deleted manually. Automation for this process will come with a new version of this project.

- The kube-config only works properly in the root directory.

- Automation for the entire infra build process.
    - Image tags need an env var.
    - Helm should use env vars to identify new for deployment.
    - CI/CD pipeline for use in Gitlab/Github/etc.