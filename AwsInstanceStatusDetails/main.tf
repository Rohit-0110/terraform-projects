provider "aws" {
  region = "ap-south-1"
}

data "aws_instances" "all_instances" {
  instance_state_names = ["pending", "running", "shutting-down", "stopped", "stopping"]
}

data "aws_instance" "selected" {
  count       = length(data.aws_instances.all_instances.ids)
  instance_id = data.aws_instances.all_instances.ids[count.index]
}

output "instance_tags" {
  value = { for instance in data.aws_instance.selected : instance.id => instance.tags }
}

# Write the output to a file
resource "local_file" "instances_output_file" {
  filename = "output.csv"
  content  = <<-EOT
    All Instances: ${jsonencode({ for instance in data.aws_instance.selected : instance.id => instance.tags })}
  EOT
}