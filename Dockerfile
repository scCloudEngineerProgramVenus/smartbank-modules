FROM openjdk:8-jdk-alpine
EXPOSE 8080
ARG JAR_FILE=target/smart-bank-api.jar
COPY ${JAR_FILE} application.jar
ENTRYPOINT ["java", "-jar", "application.jar"]