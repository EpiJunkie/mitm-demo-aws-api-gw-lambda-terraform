#!/usr/bin/env sh

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
# Purpose:                   Copy certs from default Let's Encrypt default folder
#                            to the local folder and creates a zip file from
#                            `lambda-function.py` for Terraform.

# Variables
################################################################################

domain="mitm-demo.justinholcomb.me"
homedir=~
letsencrypt_acme_folder="${homedir}/.acme.sh/$domain"
domain_public_cert="${letsencrypt_acme_folder}/${domain}.cer"
domain_private_cert="${letsencrypt_acme_folder}/${domain}.key"
domain_ca_cert="${letsencrypt_acme_folder}/ca.cer"

# Main
################################################################################

if [ -d "$letsencrypt_acme_folder" ]; then
  echo "Found Let's Encrypt acme.sh directory containing certs."
else
  echo "Could not find Let's Encrypt acme.sh directory '${letsencrypt_acme_folder}' containing certs."
  exit
fi

if [ -f "$domain_public_cert" ]; then
  echo "Found public certificate for ${domain}."
  cp -v "$domain_public_cert" example.crt
else
  echo "Could not find public certificate for ${domain} at '$domain_public_cert'."
  exit
fi

if [ -f "$domain_private_cert" ]; then
  echo "Found private certificate for ${domain}."
  cp -v "$domain_private_cert" example.key
else
  echo "Could not find private certificate for ${domain} at '$domain_private_cert'."
  exit
fi

if [ -f "$domain_ca_cert" ]; then
  echo "Found Let's Encrypt public CA certificate."
  cp -v "$domain_ca_cert" ca.crt
else
  echo "Could not find Let's Encrypt public CA certificate."
  exit
fi

echo "Creating Lambda zip file using lambda-function.py"
zip lambda.zip lambda-function.py

echo "Files created or copied for terraform."
