variable "task_role_name" {
  type = string
}

variable "account_id" {
  type = string
}

resource "aws_iam_role_policy" "pagamento_dynamo_write" {
  name = "pagamento-dynamo-write"
  role = var.task_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:${var.account_id}:table/${var.dynamo_table_name}"
      }
    ]
  })
}