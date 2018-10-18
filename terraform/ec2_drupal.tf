// Get the drupal image 
data "aws_ami" "drupal" {
  most_recent = true

  filter {
    name = "name"
    values = ["drupal-setup*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// Create the drupal instance using the drupal image
resource "aws_instance" "web_instance" {
  ami   = "${data.aws_ami.drupal.id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = true
  private_ip  = "192.168.0.24"
  security_groups = ["${aws_security_group.drupal_sg.id}"]
  key_name  = "${var.key_name}"

  tags {
    Name  = "compucorp_instance"
  }
}