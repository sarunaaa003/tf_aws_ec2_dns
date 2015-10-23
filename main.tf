/* Setup our aws provider */
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}

resource "template_file" "yaml" {
  count = "${var.instance_count}"
  filename = "${var.cloud_init}"

  vars {
    hostname = "${var.hostname}${count.index+1}"
    internal_domain = "${var.internal_domain}"
  }
}

resource "aws_instance" "ec2" {
  count = "${var.instance_count}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  security_groups = [ "${split(",", var.sg_ids)}" ]
  key_name = "${var.key_name}"
  source_dest_check = false
  user_data = "${element(template_file.yaml.*.rendered, count.index)}"
  tags = {
    Name = "${var.hostname}${count.index+1}"
  }
}

resource "aws_route53_record" "host" {
  count = "${var.instance_count}"
  zone_id = "${var.zone_id}"
  name = "${var.hostname}${count.index+1}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.ec2.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "host-rev" {
  count = "${var.instance_count}"
  zone_id = "${var.rev_zone_id}"
  name = "${element(split(".",element(aws_instance.ec2.*.private_ip, count.index)),3)}.${element(split(".",element(aws_instance.ec2.*.private_ip, count.index)),2)}"
  type = "PTR"
  ttl = "300"
  records = ["${var.hostname}${count.index+1}.${var.internal_domain}."]
}