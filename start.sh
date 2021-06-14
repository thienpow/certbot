#!/bin/bash
VALUE=`kubectl get secret letsencrypt-tls-certs -o 'go-template={{index .data "tls.key"}}' | base64 -d`
if [ -z "$VALUE" ]
then
  echo "NO EXISTING secret letsencrypt-tls-certs, request for new SSL Certificates"
  certbot certonly --non-interactive --agree-tos --cert-name $CERT_NAME --email $CERT_EMAIL --standalone --expand $CERTBOT_PARAMS
else
  echo "FOUND EXISTING secret letsencrypt-tls-certs.  Wait for next"
fi

if [ -z "$GOT_NEW" ]
then 
  echo "NO GOT_NEW env found."
else
  echo "GOT_NEW env found."
  certbot certonly --non-interactive --agree-tos --cert-name $CERT_NAME --email $CERT_EMAIL --standalone --expand $CERTBOT_PARAMS
fi

/wwwloader &

i=1
while [ "$i" -ne 0 ]
do
  echo "UPDATING secret letsencrypt-tls-certs."
  if [ -e /etc/letsencrypt/live/"$CERT_NAME"/fullchain.pem ]
  then
      echo "pem files found!"
      kubectl create secret tls letsencrypt-tls-certs --cert=/etc/letsencrypt/live/"$CERT_NAME"/fullchain.pem --key=/etc/letsencrypt/live/"$CERT_NAME"/privkey.pem  --dry-run=client -o yaml | kubectl apply -f -
  else
      echo "pem files NOT Found!  Attempting to request for new cert!"
      certbot certonly --non-interactive --agree-tos --cert-name $CERT_NAME --email $CERT_EMAIL --standalone --expand $CERTBOT_PARAMS
  fi
  
  sleep 43200
  echo "Checking if renew is needed. [certbot -q renew]"
  certbot -q renew
done