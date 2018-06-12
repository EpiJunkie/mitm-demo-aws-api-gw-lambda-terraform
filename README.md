# mitm-demo-aws-api-gw-lambda-terraform

This is a 'hello world'-like demonstration to manipulate (API) requests/responses utilizing AWS [API Gateway](https://aws.amazon.com/api-gateway/) with [Lambda](https://aws.amazon.com/lambda/) running Python 3.6 and deployed via [Terraform](https://www.terraform.io/).

## Prerequisites

### Local

* [Terraform](https://www.terraform.io/)

  * OSX: brew install terraform

* [`direnv`](https://github.com/direnv/direnv)

  * OSX: brew install direnv

### Other

* AWS account

* [Route 53](https://aws.amazon.com/route53/) registered and configured domain

* X.509 certificates for the domain. [Let's Encrypt](https://letsencrypt.org/) is recommended.

## Setup

First there needs to be X.509 certificates placed in this project's directory. There is a provided script (`prebuild.sh`) that copies Let's Encrypt certificates from the default `~/.acme.sh/` location to the default filename locations after modifying the "domain" variable within the script.

Then a zip file needs to be created with the Lambda function code. This can be done on OSX by running `zip lambda.zip lambda-function.py`.

Then move `.envrc.default` to `.envrc` and edit the `.envrc` file to include the AWS credentials.

Then move `variables.tf.default` to `variables.tf` and edit the `variables.tf` file to fit your environment. At a minimum `route53_zoneid` and `route53_domain` need to be changed. If your certificate names are different from `example.key`/`example.crt`/`ca.crt`, they need to be changed here.

At this point, running `terraform init` will download the AWS [provider](https://www.terraform.io/docs/providers/) package and otherwise initialize terraform locally.

## Deploy

`terraform apply` and type 'yes' when prompted if you are sure you want to continue.

After about 120 seconds the infrastructure will be setup and you will be able to make API calls against the [invoke URL](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html). The [CloudFront endpoints](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-edge-optimized-custom-domain-name.html) can take up to 40 minutes to setup. As an alternative to the CloudFront A records, you can (temporarily) setup a CNAME to hit the invoke URL domain while CloudFront sets up. An example is provided in `api-gw-dns.tf`, comment out the A record portion and uncomment the CNAME record portion and run `terraform apply` again.

## Delete

`terraform destroy` and type 'yes' when prompted if you are sure you want to continue. About 60 seconds later, everything has been deleted except for any logs that may have been generated in CloudWatch.

## Example

See [my blog post here](http://justinholcomb.me/blog/2018/06/12/aws-api-gateway-lambda-route53-terraform-mitm-demo.html).
