# Creating AMI

/*resource "aws_ami" "AMI" {
  name                = "AMI_ASC"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = "snap-xxxxxxxx"
    volume_size = 8
  }
}*/

#Creating AMI with existing EC2 instance

data "aws_ami" "RHEL-8" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.0.0_HVM-20190618-x86_64-1-Hourly2-GP2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Canonical
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.RHEL-8.id}"
  instance_type = "t2.micro"
}

# Creating Launch Configuration

resource "aws_launch_configuration" "launch_Configuration" {
  name_prefix   = "ASC_LC"
  image_id      = "${data.aws_ami.RHEL-8.id}"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "ASC_GP"
  launch_configuration      = "${aws_launch_configuration.launch_Configuration.name}"
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  vpc_zone_identifier = ["${aws_subnet.public_subnet.id}", "${aws_subnet.private_subnet.id}"]
  lifecycle {
    create_before_destroy = true
  }
}
