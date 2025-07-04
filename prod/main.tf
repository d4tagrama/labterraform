provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requestes"
  default = 8080
}
/* data "aws_availability_zone" "all" {
  
} */
/* output "public_ip" {
  value = "${aws_instance.example.public_ip}"
} */

resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.instance.id}" ]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
  lifecycle {
    create_before_destroy = true
  }
}
/* resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.instance.id}" ]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
 
  tags = {
    name = "terraform-example"
 } 
}
 */
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  min_size = 1
  max_size = 2
  availability_zones = ["us-east-1a", "us-east-1b"]

  tag  {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}