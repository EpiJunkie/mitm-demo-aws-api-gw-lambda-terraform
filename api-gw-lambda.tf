
resource "aws_lambda_function" "mitm_function" {
  function_name = "APIGatewayManipulation"
  filename = "lambda.zip"
  source_code_hash = "${base64sha256(file("lambda.zip"))}"
  handler = "lambda-function.lambda_handler"
  runtime = "python3.6"
  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.mitm_function.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.demo_deploy.execution_arn}/*/*"
}
