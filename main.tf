## Azure resource provider ##
provider "azurerm" {
  version = "=1.5.0"
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers {
    key = "${tls_private_key.key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}

## Azure resource group for the kubernetes cluster ##
resource "azurerm_resource_group" "aks_demo" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "aks_demo" { 
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.aks_demo.location}"
  resource_group_name = "${azurerm_resource_group.aks_demo.name}"
  dns_prefix          = "${var.dns_prefix}"

  linux_profile {
    admin_username = "${var.admin_username}"

    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_D2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    Environment = "Production"
  }
}

## Outputs ##

# Example attributes available for output
#output "id" {
#    value = "${azurerm_kubernetes_cluster.aks_demo.id}"
#}
#
#output "client_key" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.client_key}"
#}
#
#output "client_certificate" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.client_certificate}"
#}
#
#output "cluster_ca_certificate" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.cluster_ca_certificate}"
#}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.host}"
}

output "configure" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes client:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl

$ kubectl get nodes
CONFIGURE
}