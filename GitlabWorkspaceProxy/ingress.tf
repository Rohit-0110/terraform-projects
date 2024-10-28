locals {
  subnet-1 = ""
  subnet-2 = ""
}

resource "kubernetes_ingress_v1" "gitlab-gitlab_workspaces_proxy" {
  metadata {
    name      = "gitlab-workspaces"
    namespace = "gitlab-workspaces"
    annotations = {
      alb.ingress.kubernetes.io / scheme       = "internal"
      alb.ingress.kubernetes.io / subnets      = "local.subnet-2, local.subnet-1"
      alb.ingress.kubernetes.io / listen-ports = jsondecode([{ HTTP = 80 }, { HTTPS = 443 }])
      alb.ingress.kubernetes.io / ssl-redirect = "443"

    }
  }

  spec {
    ingress_class_name = "alb"
    tls {
      hosts       = var.gitlab_workspaces_proxy_domain
      secret_name = "gitlab-workspaces-proxy-workspaces-cert"

    }
    tls {
      hosts       = var.gitlab_workspaces_wildcard_domain
      secret_name = "gitlab-workspaces-proxy-workspaces-wildcard-cert"

    }
    rule {
      host = var.gitlab_workspaces_proxy_domain
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
      host = "*.${var.gitlab_workspaces_proxy_domain}"
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