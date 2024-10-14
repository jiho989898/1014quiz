resource "aws_alb" "example-alb" {
  name = "example-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.alb.id ]
  subnets = [ aws_subnet.example_subnet_1a.id , aws_subnet.example_subnet_1c.id ]
  enable_cross_zone_load_balancing = true
}


resource "aws_alb_target_group" "example" {
  name = "alb-target-example"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.example.id
}

resource "aws_alb_target_group_attachment" "example1" {
  target_group_arn = aws_alb_target_group.example.arn
  target_id = aws_instance.web[0].id
  port = 80
}

resource "aws_alb_target_group_attachment" "example2" {
  target_group_arn = aws_alb_target_group.example.arn
  target_id = aws_instance.web[1].id
  port = 80
}

resource "aws_alb_listener" "example" {
  load_balancer_arn = aws_alb.example-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.example.arn
  }
}
