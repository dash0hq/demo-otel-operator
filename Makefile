VERSION ?= v1
CLUSTER_NAME ?=otel
LANGUAGE ?=none

cluster:
	kind create cluster --name=$(CLUSTER_NAME) --config ./kind/multi-node.yaml

install-prereqs:
	helm repo add jetstack https://charts.jetstack.io --force-update
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
	helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator --set manager.extraArgs="{--enable-go-instrumentation}" --set "manager.collectorImage.repository=otel/opentelemetry-collector-k8s" --namespace opentelemetry --create-namespace
	# Apply Prometheus-operator CRDs
	kubectl create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/heads/main/charts/kube-prometheus-stack/charts/crds/crds/crd-servicemonitors.yaml
	kubectl create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/heads/main/charts/kube-prometheus-stack/charts/crds/crds/crd-scrapeconfigs.yaml
	kubectl create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/heads/main/charts/kube-prometheus-stack/charts/crds/crds/crd-podmonitors.yaml
	kubectl create -f https://raw.githubusercontent.com/prometheus-community/helm-charts/refs/heads/main/charts/kube-prometheus-stack/charts/crds/crds/crd-probes.yaml

collector:
	kubectl apply -f ./otel-collector/rbac-daemonset.yaml
	kubectl apply -f ./otel-collector/rbac-central.yaml
	kubectl apply -f ./otel-collector/rbac-target-allocator.yaml
	kubectl apply -f ./otel-collector/otel-collector-daemonset.yaml
	kubectl apply -f ./otel-collector/otel-collector-central.yaml

docker:
	docker build -f ./languages/javascript/Dockerfile -t hello-node:$(VERSION) ./languages/javascript
	docker build -f ./languages/go/Dockerfile -t hello-go:$(VERSION) ./languages/go
	docker build -f ./languages/java/Dockerfile -t hello-java:$(VERSION) ./languages/java
	docker build -f ./languages/dotnet/Dockerfile -t hello-dotnet:$(VERSION) ./languages/dotnet
	docker build -f ./languages/python/Dockerfile -t hello-python:$(VERSION) ./languages/python

kind-load: docker
	kind load docker-image --name $(CLUSTER_NAME) hello-node:$(VERSION)
	kind load docker-image --name $(CLUSTER_NAME) hello-go:$(VERSION)
	kind load docker-image --name $(CLUSTER_NAME) hello-java:$(VERSION)
	kind load docker-image --name $(CLUSTER_NAME) hello-dotnet:$(VERSION)
	kind load docker-image --name $(CLUSTER_NAME) hello-python:$(VERSION)

deploy-k8s: kind-load
	kubectl apply -f ./languages/go/manifests/
	kubectl apply -f ./languages/javascript/manifests/
	kubectl apply -f ./languages/java/manifests/
	kubectl apply -f ./languages/dotnet/manifests/
	kubectl apply -f ./languages/python/manifests/

restart-k8s:
	kubectl delete -f ./languages/$(LANGUAGE)/manifests/
	kubectl apply -f ./languages/$(LANGUAGE)/manifests/

delete:
	kind delete cluster --name=$(CLUSTER_NAME)

instrumentation:
	kubectl apply -f ./instrumentations/instrumentation.yaml