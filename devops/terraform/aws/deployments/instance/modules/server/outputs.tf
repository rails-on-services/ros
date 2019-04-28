output "public_ip" {
  description = "Public IP address of the instance/services"
  value       = "${aws_eip.this.public_ip}"
}
