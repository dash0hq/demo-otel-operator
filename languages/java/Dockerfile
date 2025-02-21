# Stage 1: Build the application
FROM gradle:7.6-jdk17 AS builder
WORKDIR /app
COPY . .
RUN ./gradlew clean build

# Stage 2: Package the application
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/build/libs/hello-v1.jar app.jar
EXPOSE 3000
ENTRYPOINT ["java", "-jar", "app.jar"]