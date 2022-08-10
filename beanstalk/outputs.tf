output "beanstalk_net_framework_uri" {
  value = aws_elastic_beanstalk_environment.net_framework_environment.endpoint_url
}

output "beanstalk_net_framework_cname" {
  value = aws_elastic_beanstalk_environment.net_framework_environment.cname
}