aws_region           = "us-east-1"

vpc_id               = "vpc-01c861f3c2d6eae3b"
subnet_ids           = ["subnet-07a051982d0989feb", "subnet-01dd0cd312c928d19"]
security_group_id    = "sg-05570d67260604fcb"

execution_role_arn   = "arn:aws:iam::816069165502:role/ecsTaskExecutionRole"
task_role_arn        = "arn:aws:iam::816069165502:role/ecsTaskExecutionRole"

ecr_image_url        = "816069165502.dkr.ecr.us-east-1.amazonaws.com/pedido-service:latest"

db_host              = "pedido-db.c2xiqmcqyg89.us-east-1.rds.amazonaws.com"
db_port              = 3306
db_user              = "admin"
db_password          = "Senha123"
db_name              = "pedidos"

cognito_user_pool_id = "us-east-1_NS0kvTWfX"
cognito_client_id    = "2v1oesgaetn7r095qle6i19cvm"

api_base_url         = "http://ms-shared-alb-1023094345.us-east-1.elb.amazonaws.com"
node_env             = "production"


