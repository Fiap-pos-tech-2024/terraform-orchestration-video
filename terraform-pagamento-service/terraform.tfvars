aws_region           = "us-east-1"

vpc_id               = "vpc-01c861f3c2d6eae3b"
subnet_ids           = ["subnet-07a051982d0989feb", "subnet-01dd0cd312c928d19"]
security_group_id    = "sg-05570d67260604fcb"

execution_role_arn   = "arn:aws:iam::816069165502:role/ecsTaskExecutionRole"
task_role_arn        = "arn:aws:iam::816069165502:role/ecsTaskExecutionRole"

ecr_image_url        = "816069165502.dkr.ecr.us-east-1.amazonaws.com/pagamento-service:latest"

cognito_user_pool_id = "us-east-1_NS0kvTWfX"
cognito_client_id    = "2v1oesgaetn7r095qle6i19cvm"

api_base_url         = "http://ms-shared-alb-1023094345.us-east-1.elb.amazonaws.com"
node_env             = "production"

dynamo_table_name    = "Pagamentos"

mercadopago_access_token   = "TEST-7513763222088119-102723-066d60f2c69bc1f0a4f4d4163d2b448a-163051303"
mercadopago_public_key     = "TEST-5ae40bfd-d399-475d-914f-79a45924cf87"
mercadopago_notification_url = "https://de12-2804-7f0-bac1-d7d5-45d3-7b4a-dcb3-90f.ngrok-free.app/api/pagamento/notificar"
mercadopago_success_url      = "https://de12-2804-7f0-bac1-d7d5-45d3-7b4a-dcb3-90f.ngrok-free.app/success"
mercadopago_failure_url      = "https://de12-2804-7f0-bac1-d7d5-45d3-7b4a-dcb3-90f.ngrok-free.app/failure"
mercadopago_pending_url      = "https://de12-2804-7f0-bac1-d7d5-45d3-7b4a-dcb3-90f.ngrok-free.app/pending"

task_role_name = "ecsTaskExecutionRole"
account_id     = "816069165502"
