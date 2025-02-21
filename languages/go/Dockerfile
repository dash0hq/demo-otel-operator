FROM golang:1.23.3 AS builder

WORKDIR /app

COPY go.mod go.sum ./

# Ensure all dependencies are correctly downloaded
RUN go mod tidy && go mod download

# Explicitly install missing dependencies
RUN go get github.com/prometheus/client_golang/prometheus/promhttp \
    && go get go.opentelemetry.io/contrib/instrumentation/runtime \
    && go get go.opentelemetry.io/otel/exporters/prometheus \
    && go get go.opentelemetry.io/otel/sdk/metric

COPY *.go ./

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o /hello

# Use a minimal base image for the final container
FROM alpine:latest
WORKDIR /
COPY --from=builder /hello /hello
EXPOSE 3000

CMD ["/hello"]