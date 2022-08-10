locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips_ipv4 = ["0.0.0.0/0"]
  all_ips_ipv6 = ["::/0"]
}