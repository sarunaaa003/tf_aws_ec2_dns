output "private_ip" {
  value = "${aws_instance.ec2.private_ip}"
}

output "public_ip" {
  value = "${aws_instance.ec2.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.ec2.id}"
}