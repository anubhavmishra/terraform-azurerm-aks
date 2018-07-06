provider "kubernetes" {}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "${var.namespace}"
  }
}

resource "kubernetes_pod" "web" {
  metadata {
    name = "nginx"

    labels {
      name = "nginx"
    }

    namespace = "${kubernetes_namespace.example.metadata.0.name}"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "nginx"
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "nginx"
    namespace = "${kubernetes_namespace.example.metadata.0.name}"
  }

  spec {
    selector {
      name = "${kubernetes_pod.web.metadata.0.labels.name}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
