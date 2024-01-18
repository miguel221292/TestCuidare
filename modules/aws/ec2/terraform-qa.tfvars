region = "us-east-2"
bucket = "crowdar-tfstate-test"
enviroment = "qa"
launch_template_name = "ecs-launch-template"
instance_type = "t2.micro"
image = "ami-09c0b8e7f21923ac0" #Use an AMI image compatible with ECS
volume_size = 30
volume_type = "gp2"
health_check = "/healthcheck"
ecs_tg_name = "ecs-target-group"
ecs_tg_port = 3000
ecs_tg_protocol = "tcp"
ecs_lt_port = 3000
ecs_lt_protocol = "tcp"
ecs_lb_name = "ecs-load-balancer"
ssh-key = "ec2ecsglog"