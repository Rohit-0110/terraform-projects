locals {
  worker_ami_owner = ""

}

locals {
  runner_ami_filter_name         = ""
  runner_ami_filter_architecture = var.build_type

}

locals {
  worker_ami_filter_name         = ""
  worker_ami_filter_architecture = var.build_type

}

locals {
  runner_before_start_script = <<EOF
  #!/bin/bash
  echo "Before_start_script"

  EOF

}

locals {
  worker_start_script = <<EOF
  #!/bin/bash
  echo "worker_start_script"

  EOF

}
