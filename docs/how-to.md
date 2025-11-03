# How to run the infra
You have several options available to check the provisioned infra yourself:
- Use the `docker-compose.yaml` file (_recommended_)
- Use the `docker-compose.with-build.yaml` file
- Use just the pki-provisioner image

## Docker compose (recommended)
Get the `docker-compose.yaml` file and simply run
```bash
docker compose up -d
```

## Docker compose with build
Clone the repo, then once inside run
```bash
docker compose up -d -f docker-compose.with-build.yaml
```

This setup is similar to usual compose file with the exception that pki provisioner is being built using Dockerfile from the repo rather than using the pre-built image.
Use this option if you want more granular control of the deployment.

## Provision your infra with pki-provisioner
Using this option you can create the PKI infra on your own cluster with just this docker image. It simply runs terraform with configuration supplied in `/provisioning` folder. 
When you run the image, specify the address of your cluster via `CLUSTER_ADDR` env variable so terraform can patch it
