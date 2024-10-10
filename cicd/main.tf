module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0ae3a12e7b7696e53"] #replace your SG
  subnet_id = "subnet-0be035a5a62ef124e" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0ae3a12e7b7696e53"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0be035a5a62ef124e"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0ae3a12e7b7696e53"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0be035a5a62ef124e"
  ami = data.aws_ami.nexus_ami_info.id
  tags = {
    Name = "nexus"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    }
  ]

}