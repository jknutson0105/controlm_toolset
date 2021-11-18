#!/bin/bash

# MIT License
# Copyright (c) 2021 Daniel Companeetz, BMC Software, Inc.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# SPDX-License-Identifier: MIT
# For information on SDPX, https://spdx.org/licenses/MIT.html

# script to send SMS messages as a shout to a script destination
#Instructions and comments
#    See message formatting on the accompanying job definition
#Invoke from job Notification Actions
#    Set appropriate shout destination on the CCM or ctmsys
#This is a shell script that uses AT&T Developer API services.
#    Uses an account registered to dcompane with limitations.
#        Cannot send to non-AT&T phones
#        SMS charges may apply
#    Uses curl to submit requests.
#    Docs: https://developer.att.com/sms/docs
#
#OPTIONS
#    Parameters are passed per standard Control-M processes.
#    See job for details
#
#DEFAULTS
#   TO BE DOCUMENTED
#
# FUTURE WORK
#   None planned


#Used in dco_sndsmsATT shout destination, which is used in job DCO_TestSMSmsg
outdir=`dirname $0`
echo $@ >> $outdir/outfile.txt
 set -x
APP_KEY="6sutwhoisumbt0cszds8361n9kdm8sj4olsnl"
APP_SECRET="veggyqkgqv55mlhq0jj3adr3sxatqa75fbu5w"

# Set up the scopes for requesting API access.
API_SCOPES="SMS"

# Fully qualified domain name for the API Gateway.
FQDN="https://api.att.com"

# Authentication parameter.

LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

token=`curl "${FQDN}/oauth/v4/token" \
    --insecure \
    --header "Accept: application/json" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data "client_id=${APP_KEY}&client_secret=${APP_SECRET}&grant_type=client_credentials&scope=${API_SCOPES}"`


OAUTH_ACCESS_TOKEN=`jq -r .access_token <<<$token`

echo "Token obtained: $OAUTH_ACCESS_TOKEN"

# Enter telephone number to which the SMS message will be sent.
# For example: TEL="tel:+1234567890"
#TEL="tel:+15104243921"
TEL=`echo $2|awk -F "==" '{print $1}'|sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
TEL="tel:+1$TEL"
#echo "addr: $TEL"  >> $outdir/outfile.txt

# SMS message text body.
SMS_MSG_TEXT=`echo $2|awk -F "==" '{print $2}'|sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
SMS_MSG_TEXT="$SMS_MSG_TEXT"
#echo "msg: $SMS_MSG_TEXT"  >> $outdir/outfile.txt

#    --verbose  \
#    --trace-ascii  \
# Send the Send SMS method request to the API Gateway.
curl "${FQDN}/sms/v3/messaging/outbox" \
    --header "Accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${OAUTH_ACCESS_TOKEN}" \
    --data "{\"outboundSMSRequest\":{\"address\":\"${TEL}\",\"message\":\"${SMS_MSG_TEXT}\"}}" \
    --request POST
#    --request POST >> $outdir/outfile.txt 2>&1
