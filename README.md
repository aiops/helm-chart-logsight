# Logsight Helm Chart

[Logsight](https://logsight.ai) infuses deep learning and AI-powered analytics to enable continuous software delivery and proactive troubleshooting.

## Introduction

This chart bootstraps an instance of the latest Logsight version with PostgreSQL and Elasticsearch database.

## Compatibility

| Logsight Version | Kubernetes Version | Helm Chart Version  | Elasticsearch Version | Kibana Version|
| ---------------- | ------------------ | ------------------ | ------------------ | ------------------ |
| v1.0.0           | 1.23               | 3.0                | 7.16.2 | 7.16.2|

## Installing the chart

### Instaling using our single-node cluster

Elasticsearch requires TLS for authentication, so we need to create certificates and deploy them to the cluster:

```bash

/.generate-certs.sh ES_USERNAME= ES_PASSWORD= , UNDER CONSTRUCTION

```

To install the chart:

```bash
helm repo add logsight https://aiops.github.io/helm-chart-logsight/
helm repo update
kubectl create namespace logsight
helm upgrade --install -n logsight logsight logsight/logsight
```

The above command deploys Logsight on the Kubernetes cluster in the default configuration in the logsight namespace. The [configuration](#configuration) section lists the parameters that can be configured during installation.


### Installing using already deployed elasticsearch cluster

* Note: The cluster must have enabled `xpack.security:true` and `tls` since logsight works with authentication for different users.
  
```bash
helm repo add logsight https://aiops.github.io/helm-chart-logsight/
helm repo update
kubectl create namespace logsight
helm upgrade --install -n logsight -f <path_to_values.yaml> logsight logsight/logsight
```

# Local installation

Or you can clone the repo and install logsight locally using:
```bash
git clone https://github.com/aiops/helm-chart-logsight
cd helm-chart-logsight
```

```bash
helm install --namespace logsight logsight ./logsight
```

## How to use it

Take some time to read the Deploy on [Logsight on Kubernetes](AD DOCS LINK HERE) page.
Logsight deployment on Kubernetes has been tested with the recommendations and constraints documented there, and deployment has some limitations.

## Uninstalling the chart

To uninstall/delete the deployment:

```bash
$ helm list -A
NAME     NAMESPACE REVISION UPDATED             STATUS   CHART          APP VERSION
logsight logsight  1        2022-03-31 14:49:15 deployed logsight-0.1.0 v1.0.0
$ helm delete logsight -n logsight
$ kubectl delete pvc --namespace logsight --all
```

## Configuration

The following table lists the configurable parameters of the Logsight chart and their default values.

### Global

Logsight uses Elasticsearch for storing the results of the analyzed logs. It uses a single elasticsearch-node instance for storage. If you want to use your own elasticsarch cluster, please disable the elasticsearch dependancy by providing the `elasticsearch.enabled: false` parameter in your `values.yaml` file.


| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `logsight.elasticsearch.username` | Elasticsearch username. (The username has to match the one created when generating the certificates.) | `elastic` |
| `logsight.elasticsearch.password` | Elasticsearch password. (The password has to match the one created when generating the certificates.)  | `elasticsearchpassword` |
| `logsight.elasticsearch.hostname` | Hostname of the elasticsearch cluster. | `elasticsearch-master` |
| `logsight.elasticsearch.port` | Elasticsearch port for communication. | `9200` |
| `logsight.kibana.hostname` | Hotname of the kibana service. | `logsight-kibana` |
| `logsight.kibana.port` | Port of the kibana service.  | `5601` |


### Postgres

This helm chart uses Postgres database for storage. Below are the configurable params for the database. For more information about configurable parameters pleaser refer to the [README](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) of the chart.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `global.postgresql.auth.username` | Name for a custom user to create for the database. | `"logsight"` |
| `global.postgresql.auth.password` | Password for the custom user to create  | `logsight` |
| `global.postgresql.auth.database` | Name for a custom database to create | `logsight` |
| `postgres.persistence.size` | PVC Storage Request for PostgreSQL volume | `2Gi` |

### Elasticsearch

* It is important to verify that the JVM heap size in esJavaOpts and to set the CPU/Memory resources to something suitable for your cluster.
  
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `esJavaOpts` | [Java options](https://www.elastic.co/guide/en/elasticsearch/reference/current/jvm-options.html) for Elasticsearch. Override the default JVM options by adding custom options files . See [values.yaml](add link to values.yaml) for an example of the formatting. | `-Xmx2g -Xms2g` |

For more information about additional elasticsarch parameter please refer to the [readme](https://github.com/elastic/helm-charts/tree/main/elasticsearch) of the official helm chart.

