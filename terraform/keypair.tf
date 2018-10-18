// create a keypair to ssh into the drupal and database instance
resource "aws_key_pair" "drupal_key" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}