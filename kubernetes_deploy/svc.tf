resource "kubernetes_service" "webapp_service" {
  metadata {
    name = "webapp-service"
  }

  spec {
    type = "NodePort"

    selector = {
      name = "webapp"
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }

    # Optional: Define the ports array if multiple ports are needed
    # ports {
    #   port        = 8080
    #   target_port = 8080
    #   node_port   = 30080
    # }
  }
}
