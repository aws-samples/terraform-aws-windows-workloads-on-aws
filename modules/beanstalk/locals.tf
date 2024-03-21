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

  eb_environment_settings = [
    {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = var.vpc_id == null ? data.aws_vpc.default_vpc_id.id : var.vpc_id
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(",", var.private_subnets == null ? data.aws_subnets.default_private_subnets.ids : var.private_subnets)
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "AssociatePublicIpAddress"
      value     = false
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(",", var.public_subnets == null ? data.aws_subnets.default_public_subnets.ids : var.public_subnets)
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "ELBScheme"
      value     = "public"
    },
    {
      namespace = "aws:elasticbeanstalk:environment:process:default"
      name      = "MatcherHTTPCode"
      value     = "200-299,300-304,307-308"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "LoadBalancerType"
      value     = "application"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = var.ec2_instance_type
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "RootVolumeType"
      value     = "gp3"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = "${aws_iam_instance_profile.beanstalk_net_windows_instance_profile.name}"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SecurityGroups"
      value     = "${aws_security_group.secgroup_beanstalk_net_windows.id}"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SSHSourceRestriction"
      value     = "tcp,22,22,${aws_security_group.secgroup_beanstalk_net_windows.id}"
      #  https://github.com/hashicorp/terraform-provider-aws/issues/2002
      #  https://github.com/aws/elastic-beanstalk-roadmap/issues/44
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = var.key_name
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = var.asg_min_instances
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value     = var.asg_max_instances
    },
    {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "ManagedActionsEnabled"
      value     = "true"
    },
    {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "PreferredStartTime"
      value     = "Sat:00:00"
    },
    {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "ServiceRoleForManagedUpdates"
      value     = "AWSServiceRoleForElasticBeanstalkManagedUpdates"
    },
    {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name      = "UpdateLevel"
      value     = "minor"
    },
    {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "SystemType"
      value     = "enhanced"
    },
    {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "EnhancedHealthAuthEnabled"
      value     = "true"
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
      name      = "HealthStreamingEnabled"
      value     = "true"
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "StreamLogs"
      value     = "true"
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "RetentionInDays"
      value     = 7
    },
    {
      namespace = "aws:elbv2:loadbalancer"
      name      = "SecurityGroups"
      value     = "${aws_security_group.secgroup_beanstalk_elb.id}"
    },
    {
      namespace = var.acm_arn == null ? "aws:elbv2:listener:default" : "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = "true"
    },
    {
      namespace = var.acm_arn == null ? "aws:elbv2:listener:default" : "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = var.acm_arn == null ? "HTTP" : "HTTPS"
    },
    {
      namespace = var.acm_arn == null ? "aws:elbv2:listener:default" : "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.acm_arn == null ? "" : var.acm_arn
    }
  ]
}