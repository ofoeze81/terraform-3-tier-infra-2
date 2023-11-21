resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids = [var.private_subnet1, var.private_subnet2]
    name = "${local.Name}-subnet-group"

  tags = merge(var.tags, {
    Name = "${local.Name}-subnet-group"
  })
}

locals {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}"
}


resource "aws_security_group" "rds_sg" {
  name        = "${local.Name}-rds-sg"
  description = "Allow db traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "DB port"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = merge(var.tags, {
     Name = "${local.Name}-rds-sg"
    })
}


resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  db_name              = "jjtech"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}