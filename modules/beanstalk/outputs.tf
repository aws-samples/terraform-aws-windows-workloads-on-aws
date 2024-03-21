output "beanstalk_net_windows_uri" {
  value = aws_elastic_beanstalk_environment.net_windows_environment.endpoint_url
}

output "beanstalk_net_windows_cname" {
  value = aws_elastic_beanstalk_environment.net_windows_environment.cname
}