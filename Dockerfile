FROM openjdk:17-slim-bullseye AS build
RUN apt-get update && apt-get install -y maven
COPY src /usr/app/src
COPY pom.xml /usr/app
RUN mvn -f /usr/app/pom.xml clean package -Dmaven.test.skip=true

# Package stage
FROM openjdk:17-slim-bullseye
COPY --from=build /usr/app/target/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar

ARG MG_USER=wso2
ARG MG_USER_ID=10500
RUN mkdir /tmp/tomcat static
RUN chmod -R 777 /tmp
RUN chmod -R 777 /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar
# Ensure the 'root' group exists
RUN getent group root || addgroup -g 0 root

# Add a non-root user if it doesn't exist
RUN id -u $MG_USER || useradd -u $MG_USER_ID -g root -m -d /home/$MG_USER -s /bin/bash $MG_USER

# Set a non-root user
USER $MG_USER_ID

ENTRYPOINT ["java","-jar","/usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar"]
RUN echo `ls`
EXPOSE 8080

# BUILD WITH : docker build -t certifier/rest-app:<tag> .
# RUN WITH : docker run -d -p 8080:8080 certifier/rest-app:<tag>