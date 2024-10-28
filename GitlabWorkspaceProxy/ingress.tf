resource "kubernetes_ingress_v1" "gitlab-gitlab_workspaces_proxy" {
  metadata {
    name      = "gitlab-workspaces"
    namespace = "gitlab-workspaces"
    annotations = {
      alb.ingress.kubernetes.io / scheme       = "internal"
      alb.ingress.kubernetes.io / subnets      = "subnet-0a8b25c1d88cfba9b, subnet-0351b9ea761cb1b50"
      alb.ingress.kubernetes.io / listen-ports = jsondecode([{ HTTP = 80 }, { HTTPS = 443 }])
      alb.ingress.kubernetes.io / ssl-redirect = "443"

    }
  }

  spec {
    ingress_class_name = "alb"
    tls {
      hosts       = "workspaces.psiquantum.com"
      secret_name = "gitlab-workspaces-proxy-workspaces-cert"

    }
    tls {
      hosts       = "*.workspaces.psiquantum.com"
      secret_name = "gitlab-workspaces-proxy-workspaces-wildcard-cert"

    }
    rule {
      host = "workspaces.psiquantum.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = gitlab-workspaces-proxy-http
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = "*.workspaces.psiquantum.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = gitlab-workspaces-proxy-http
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}