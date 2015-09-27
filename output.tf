output "private_ip" {
  value = "${join(",", aws_instance.ec2.*.private_ip)}"
}

output "public_ip" {
  value = "${join(",", aws_instance.ec2.*.public_ip)}"
}

output "instance_ids" {
  value = "${join(",", aws_instance.ec2.*.id)}"
}

output "instance_hostnames" {
  value = "${join(",", aws_instance.ec2.*.tags.Name)}"
}