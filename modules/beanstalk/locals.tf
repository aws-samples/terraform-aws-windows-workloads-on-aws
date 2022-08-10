locals {
  managedpolicies_beanstalk_service_role = [
    "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
  ]

  managedpolicies_beanstalk_service_ec2_role = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  ]

  inbound_ports = [80, 443]
}