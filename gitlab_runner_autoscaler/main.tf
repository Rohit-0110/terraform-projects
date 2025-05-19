data "aws_iam_policy_document" "autoscaling" {
  statement {
    sid     = "ManageASGs"
    actions = ["autoscaling:*"]
    # No need for scoping because the permission boundary prevents rogue changes
    resources = ["*"]
  }
}

resource "aws_iam_policy" "autoscaling" {
  name        = "${var.environment}-autoscaling"
  description = "Permissions needed for the GitLab Runners to scale"
  policy      = data.aws_iam_policy_document.autoscaling.json
}

module "gitlab_docker_autoscaler_runner" {
  source  = "cattle-ops/gitlab-runner/aws"
  version = "7.12.1"

  environment = var.environment
  tags = {
    gitlab_runner_type = "docker-autoscaler"
    application        = "gitlab-runners"
  }

  runner_gitlab = {
    url                                           = var.gitlab_runner_url
    preregistered_runner_token_ssm_parameter_name = var.gitlab_runner_token
    runner_version                                = "17.2.1"
  }

  # Infra
  iam_permissions_boundary = var.gitlab_runners_ci_boundary
  iam_object_prefix        = var.environment
  security_group_prefix    = var.environment
  subnet_id                = var.aws_subnet_ids
  vpc_id                   = var.aws_vpc_id
  runner_networking = {
    security_group_ids = [
      var.aws_security_group_id
    ]
  }
  runner_cloudwatch = {
    enable         = true
    retention_days = 14
  }

  # The Primary Runner instance that creates spot instances with Docker+Machine
  runner_instance = {
    name                        = var.environment
    collect_autoscaling_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity"]
    ssm_access                  = true
    type                        = var.runner_instance_type
    additional_tags = {
      gitlab_role = "docker_autoscaler_manager"
      Name        = "${var.environment}-scheduler"
    }
  }

  runner_manager = {
    maximum_concurrent_jobs   = 30
    prometheus_listen_address = "0.0.0.0:9252"
  }

  runner_ami_filter = {
    name         = [local.runner_ami_filter_name]
    architecture = [local.runner_ami_filter_architecture]
  }

  runner_role = {
    policy_arns = concat(
      [
        aws_iam_policy.autoscaling.arn,
      ],
      var.policy_arns,
    )
    additional_tags = {
      gitlab_role = "docker_autoscaler_manager"
      Name        = "${var.environment}-scheduler"
    }
  }

  runner_install = {
    amazon_ecr_credential_helper = "true"
    post_install_script          = local.runner_before_start_script
  }

  # Runner config and scaling
  runner_worker = {
    max_jobs   = var.max_concurrency
    ssm_access = true
    type       = "docker-autoscaler"
    environment_variables = [
      "PIP_CACHE_DIR=/root/.cache/pip",
      "PIP_DEFAULT_TIMEOUT=30",
      "PIP_INDEX_URL=https://pypi.org/simple",
      "DOCKER_BUILDKIT=1"
    ]
  }

  runner_worker_docker_autoscaler_asg = {
    subnet_ids      = var.aws_subnet_ids
    types           = var.worker_instance_types
    max_growth_rate = 0
  }

  runner_worker_cache = {
    shared = true
    create = false
    bucket = var.cache_bucket_name
  }

  runner_worker_docker_add_dind_volumes = true

  runner_worker_docker_options = {
    disable_cache         = "false"
    image                 = var.default_image
    privileged            = "true"
    pull_policies         = ["always", "if-not-present"]
    allowed_pull_policies = ["always", "if-not-present"]
    shm_size              = 0
    volumes = [
      # https://docs.gitlab.com/ee/ci/yaml/index.html#cache
      "/cache",
      # Cache pip between builds on the same runner
      "/root/.cache/pip:/root/.cache/pip",
      # Share docker config with Docker-in-Docker containers
      "/root/.docker:/root/.docker"
    ]
  }

  # Settings for the child job-runner machines
  runner_worker_docker_autoscaler = {
    fleeting_plugin_version = "1.0.0"
    connector_config_user   = "ubuntu"
  }

  runner_worker_docker_autoscaler_ami_owners = [local.worker_ami_owner]

  runner_worker_docker_autoscaler_ami_filter = {
    name         = [local.worker_ami_filter_name]
    architecture = [local.worker_ami_filter_architecture]
  }

  runner_worker_docker_autoscaler_role = {
    policy_arns = var.policy_arns
    additional_tags = {
      gitlab_role = "docker_autoscaler_worker"
      application = "gitlab-runners"
    }
  }

  runner_worker_docker_autoscaler_instance = {
    volume_type  = "gp2"
    root_size    = 512
    start_script = local.worker_start_script
    monitoring   = true
  }

  runner_worker_docker_autoscaler_autoscaling_options = [
    {
      periods            = ["* * * * *"]
      idle_count         = var.idle_machine_count
      idle_time          = "300s"
      scale_factor       = 2
      scale_factor_limit = var.max_concurrency
    },
  ]
}
