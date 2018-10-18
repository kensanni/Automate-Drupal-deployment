
data "aws_ami" "mysql" {
  most_recent = true

  filter {
    name = "name"
    values = ["mysql-setup*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "database_instance" {
  ami   = "${data.aws_ami.mysql.id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = true
  private_ip  = "192.168.0.30"
  security_groups = ["${aws_security_group.drupal_sg.id}"]
  key_name  = "${var.key_name}"

  tags {
    Name  = "database_instance"
  }
}