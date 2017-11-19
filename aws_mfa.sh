#!/bin/bash -e

if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
	echo You must define AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_MFA_DEVICE prior to running this script.
	echo Checkout https://direnv.net/
	exit 1
fi

echo -n "MFA Code? "
read TOKEN

export JSON_RESPONSE=`aws sts get-session-token --serial-number $AWS_MFA_DEVICE --token-code $TOKEN`

export AWS_ACCESS_KEY_ID=`echo $JSON_RESPONSE | jq -r '.Credentials.AccessKeyId'`
export AWS_SECRET_ACCESS_KEY=`echo $JSON_RESPONSE | jq -r '.Credentials.SecretAccessKey'`
export AWS_SESSION_TOKEN=`echo $JSON_RESPONSE | jq -r '.Credentials.SessionToken'`


AWS_EXPIRATION=`echo $JSON_RESPONSE | jq -r '.Credentials.Expiration'`
echo You have been granted access until $AWS_EXPIRATION

unset TOKEN
unset JSON_RESPONSE

$SHELL --rcfile <(cat $HOME/.bashrc; echo 'export PS1="[AWS] \\h:\\w \\u$ "')
