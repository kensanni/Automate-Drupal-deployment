# Drupal instance IP address
output "Drupal instance IP address" {
  value = "${aws_instance.web_instance.public_ip}"
}

# Drupal instance DNS name
output "Drupal instance DNS name" {
  value = "${aws_instance.web_instance.public_dns}"
}

#Database Instance DNS name
output "Compucorp Database DNS name" {
  value = "${aws_instance.database_instance.public_dns}"
}

#Database Instance IP address
output "Compucorp Database IP address" {
  value = "${aws_instance.database_instance.public_ip}"
}