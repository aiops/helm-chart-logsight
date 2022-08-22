#!/bin/bash
# Usage: STACK_VERSION=7.5.2 DNS_NAME=elasticsearch NAMESPACE=default ./create-elastic-certificates.sh

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

STACK_VERSION=7.16.2
DNS_NAME=elasticsearch

# ELASTICSEARCH
docker rm -f elastic-helm-charts-certs || true
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12 || true
password=$([ ! -z "$ELASTIC_PASSWORD" ] && echo $ELASTIC_PASSWORD || echo $(docker run --rm docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c20")) && \
docker run --name elastic-helm-charts-certs --env DNS_NAME -i -w /app \
        docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION \
        /bin/sh -c " \
                elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && \
                elasticsearch-certutil cert --name $DNS_NAME --dns $DNS_NAME --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12" && \
docker cp elastic-helm-charts-certs:/app/elastic-certificates.p12 ./ && \
docker rm -f elastic-helm-charts-certs && \
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem && \
kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 && \
kubectl create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem && \
kubectl create secret generic elastic-credentials  --from-literal=password=elasticsearchpassword --from-literal=username=elastic  &&
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12