/* Setup our aws provider */
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}

resource "template_file" "yaml" {
  filename = "${var.cloud_init}"

  vars {
    hostname = "${var.hostname}"
    internal_domain = "${var.internal_domain}"
  }
}

resource "aws_instance" "ec2" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  security_groups = [ "${split(",", var.sg_ids)}" ]
  key_name = "${var.key_name}"
  source_dest_check = false
  user_data = "${template_file.yaml.rendered}"
  tags = {
    Name = "${var.hostname}"
  }
}

resource "aws_route53_record" "host" {
  zone_id = "${var.zone_id}"
  name = "${var.hostname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.ec2.private_ip}"]
}