resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_cognito_policy" {
  name = "ecs-task-cognito-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:RespondToAuthChallenge",
          "cognito-idp:InitiateAuth"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_logs_alloy_policy" {
  name = "ecs-logs-grafana-alloy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "CloudWatchLogsAccess",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Resource = "arn:aws:logs:us-east-1:*:log-group:/ecs/grafana-alloy:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_sqs_policy" {
  name = "ecs-task-sqs-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_s3_upload_policy" {
  name = "ecs-task-s3-upload-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::fiap-video-bucket-20250706/videos/*"
      },
      {
        Effect = "Allow",
        Action = "s3:ListBucket",
        Resource = "arn:aws:s3:::fiap-video-bucket-20250706"
      }
    ]
  })
}

