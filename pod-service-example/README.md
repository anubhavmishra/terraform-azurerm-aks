# Pod and a Service Example

This Terraform configuration creates a kubernetes pod and service in the namespace.

## Usage

Run Terraform init, plan and apply

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

*Creating a kubernetes service of `Type=LoadBalancer` might take upwards of 3-5 mins since
Azure is creating a load balancer in the background and Terraform will wait for the
load balancer to be available.*

Check whether pod, service, and namespace is created successfully

```bash
kubectl get pods,services,namespace
```