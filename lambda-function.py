#!/usr/bin/env python3

# Copyright (c) 2018, Justin D Holcomb (justin@justinholcomb.me) All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Script Info
################################################################################
# Version:                   0.0.1
# Purpose:                   MITM demo using AWS API Gateway using this Lambda
#                            code.

# Modules
################################################################################

import json

from botocore.vendored import requests

# Main
################################################################################

def lambda_handler(event, context):
    print(json.dumps(event))
    print("################")

    # GeoIP API
    url = "http://ip-api.com"

    # Make MITM request (from the Lambda environment's IP)
    req = requests.request(event['httpMethod'], f"{url}{event['path']}")
    # Make MITM request (as the original request's IP)
    #originating_ip = event['headers']['X-Forwarded-For']
    #req = requests.request(event['httpMethod'], f"{url}{event['path']}/{originating_ip}")

    # Create a new object to store modified headers.
    client_reply_headers = {}

    # Iterate through all the header dictionary.
    for header_key, header_value in req.headers.items():

        # Add headers to new oject if they are not the 'date' or 'content-length' keys.
        if header_key not in ["date", "content-length"]:
            client_reply_headers[header_key] = header_value

    # Attempt to load MITM response as a JSON object, set as string otherwise.
    try:
        client_reply_body = req.json()
    except:
        client_reply_body = req.text

    # Set a variable with the response type.
    req_response_type = type(client_reply_body)

    # This will append to the 'org' key from the response.
    if req_response_type is dict:
        client_reply_body['org'] += " ThisHasBeenManipulatedDict"
        client_reply_body = json.dumps(client_reply_body)

    # This will replace every occurance of "Amazon.com" with a manipulation message.
    if req_response_type is str:
        client_reply_body = client_reply_body.replace("Amazon.com", "Amazon.com ThisHasBeenManipulatedStr")

    # Dictionary to return to original request to Amazon API Gateway endpoint.
    client_reply_all = {"isBase64Encoded": False, "statusCode": req.status_code, "headers": client_reply_headers, "body": client_reply_body}

    return client_reply_all
