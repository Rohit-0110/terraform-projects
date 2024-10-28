data "aws_acm_certificate" "issued" {
  domain   = "workspaces.psiquantum.com"
  statuses = ["ISSUED"]
}

resource "helm_release" "gitlab_workspaces_proxy" {
  name             = "gitlab-workspaces-proxy"
  repository       = "https://gitlab.com/api/v4/projects/gitlab-org%2fremote-development%2fgitlab-workspaces-proxy/packages/helm/devel"
  chart            = "gitlab-workspaces-proxy"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "auth.client_id"
    value = var.client_id
  }

  set {
    name  = "auth.client_secret"
    value = var.client_secret
  }

  set {
    name  = "auth.host"
    value = var.gitlab_url
  }

  set {
    name  = "auth.redirect_uri"
    value = var.redirect_uri
  }

  set {
    name  = "auth.signing_key"
    value = var.signing_key
  }

  set {
    name  = "ingress.host.workspaceDomain"
    value = var.gitlab_workspaces_proxy_domain
  }

  set {
    name  = "ingress.host.wildcardDomain"
    value = var.gitlab_workspaces_wildcard_domain
  }

  set {
    name  = "ingress.tls.workspaceDomainCert"
    value = data.aws_acm_certificate.issued.certificate
  }

  set {
    name  = "ingress.tls.workspaceDomainKey"
    value = data.aws_acm_certificate.issued.certificate_chain
  }

  set {
    name  = "ingress.tls.wildcardDomainCert"
    value = data.aws_acm_certificate.issued.certificate
  }

  set {
    name  = "ingress.tls.wildcardDomainKey"
    value = data.aws_acm_certificate.issued.certificate_chain
  }

  set {
    name  = "ssh.host_key"
    value = var.ssh_host_key
  }

  set {
    name  = "ingress.className"
    value = var.ingress_class
  }
}
