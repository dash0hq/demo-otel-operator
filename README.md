![This tutorial is courtesy of Dash0](./images/dash0-logo.png)

# Unlocking Kubernetes Observability with the OpenTelemetry Operator

This repository contains all the configuration and source code for a demonstration of the OpenTelemetry Operator in a local `kind` Kubernetes cluster.

## Setting up a multi-node kind cluster

First we spin up a cluster: 
```sh
kind create cluster --name=otel --config kind/multi-node.yaml
```

## Installation

A prerequisite for using the OpenTelemetry Operator is having cert manager installed. Further we need to deploy the OpenTelemetry Operator, also using Helm. A mandatory value that needs to be specified is the collectorImage repository. Furthermore, it is recommended to define the namespace where the operator will be deployed (and automatically create the namespace if it does not exist). Inspect the `Makefile` for more details.

```sh
make install-prereqs
```

## Install an OpenTelemetry Collector

We will export all the telemetry signals collected to Dash0.com. If you don't have a Dash0 organization created, sign-up for free [here](https://www.dash0.com/sign-up). Grab your Auth token (Click your Avatar > Settings > Auth Tokens), and export it in your terminal and create a Kubernetes secret:

```sh
export DASH0_AUTH_TOKEN="YOUR TOKEN"
kubectl create secret generic dash0-secrets --from-literal=dash0-authorization-token=${DASH0_AUTH_TOKEN} --namespace opentelemetry
```

Next, we can install our OpenTelemetry Collectors using this convinience command:

```sh
make collector
```

You should now have the following `Running` in the `opentelemetry` namespace:
```sh
kubectl get pods -n opentelemetry
NAME                                            READY   STATUS    RESTARTS   AGE
opentelemetry-operator-7b88b4c6bb-xh84j         2/2     Running   0          86s
otel-central-collector-0                        1/1     Running   0          39s
otel-central-targetallocator-6f567b8587-9wkjz   1/1     Running   0          39s
otel-collector-7bt5f                            1/1     Running   0          49s
otel-collector-gpmnv                            1/1     Running   0          49s
```

Note: In this example, the central collector we use for central collection of telemetry is deployed in `mode: daemonset`. It seems there's a connection issue locally using kind between the target allocator and the collector in mode deployment and daemonet. 

## Setup automatic instrumentation
Deploy the `Instrumentation` resource to allow for automatic instrumentation:

```sh
make instrumentation
```

## Deploy some applications

Last thing is to deploy our workloads. Check out the different language implementation in the `languages` directory or apply directly:
```sh
make deploy-k8s
```
The command will build each of the applications as a docker image, load it into kind, and deploy the kubernetes manifests.

## Clean-up

```sh
make delete
```
