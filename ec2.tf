resource "aws_instance" "slave" {
  count = var.slave_count

  ami                    = var.ami
  instance_type          = var.slave_host_type
  key_name               = var.key_name
  # subnet_id              = [aws_subnet.subnet_priv[*].id][count.index]
  subnet_id              = element(aws_subnet.subnet_priv[*].id, count.index)
  iam_instance_profile   = "CloudWatchAgentServerRole"
  vpc_security_group_ids = [aws_security_group.sg_slave.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }
  tags = {
    Name        = "${var.project}-${var.environment}-s-${count.index}"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}

resource "aws_instance" "master" {

  ami                    = var.ami
  instance_type          = var.slave_host_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet_dmz[0].id
  iam_instance_profile   = "CloudWatchAgentServerRole"
  vpc_security_group_ids = [aws_security_group.sg_master.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }
  tags = {
    Name        = "${var.project}-${var.environment}-m"
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}

resource "aws_security_group" "sg_slave" {
  name        = "${var.project}-sg-s"
  description = "${var.project}-sg-s"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Default egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-s"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_security_group" "sg_master" {
  name        = "${var.project}-sg-m"
  description = "${var.project}-sg-m"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["217.66.97.52/32"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    description = "Default egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-m"
    Environment = var.environment
    Project     = var.project
  }
}
