package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/runtime"
	"go.opentelemetry.io/otel/exporters/prometheus"
	"go.opentelemetry.io/otel/sdk/metric"
)

type Response struct {
	Message  string `json:"message"`
	Language string `json:"language"`
}

func main() {
	setupMeter()

	http.Handle("/metrics", promhttp.Handler())
	http.HandleFunc("/", sayHello)
	log.Fatal(http.ListenAndServe(":3000", nil))
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(
		Response{
			Message:  "Hello, KubeCon!",
			Language: "Go",
		},
	)
}

func setupMeter() {
	// Initialize the Prometheus exporter
	exporter, err := prometheus.New()
	if err != nil {
		log.Fatalf("failed to initialize Prometheus exporter: %v", err)
	}

	// Create a MeterProvider with the exporter
	meterProvider := metric.NewMeterProvider(metric.WithReader(exporter))
	defer func() {
		if err := meterProvider.Shutdown(context.Background()); err != nil {
			log.Fatalf("failed to shut down MeterProvider: %v", err)
		}
	}()

	// Start collecting runtime metrics
	if err := runtime.Start(runtime.WithMeterProvider(meterProvider)); err != nil {
		log.Fatalf("failed to start runtime instrumentation: %v", err)
	}
}
