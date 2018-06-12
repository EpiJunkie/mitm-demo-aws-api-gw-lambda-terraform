
resource "aws_iam_role" "lambda_exec" {
  name = "mitm_demo_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-assume-role.json}"
}

data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_logs" {
  name        = "mitm_cloudwatch_policy"
  description = "Gives MITM demo Lambda the ability to create LogGroups and LogStreams."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
    role       = "${aws_iam_role.lambda_exec.name}"
    policy_arn = "${aws_iam_policy.lambda_cloudwatch_logs.arn}"
}
