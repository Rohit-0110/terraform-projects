data "aws_instances" "all_instances" {
  instance_tags = {
    Name = "*"
  }
  instance_state_names = ["running", "stopped", "pending", "shutting-down", "terminated", "stopping"]
}

output "all_instances" {
  value = data.aws_instances.all_instances.ids
}

data "aws_instance" "details" {
  count       = length(data.aws_instances.all_instances.ids)
  instance_id = data.aws_instances.all_instances.ids[count.index]
}

resource "local_file" "instances_output_file" {
  filename = "output.json"
  content = <<-EOT
    ${jsonencode([for instance in data.aws_instance.details : {
  launch_time    = instance.launch_time
  instance_id    = instance.id
  instance_type  = instance.instance_type
  instance_state = instance.instance_state
  instance_tags  = instance.tags[*]
}])
}
    EOT
}