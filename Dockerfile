FROM maven:3.6.0-jdk-11-slim AS build
COPY src /usr/app/src
COPY pom.xml /usr/app
RUN mvn -f /usr/app/pom.xml clean package -Dmaven.test.skip=true

# Package stage
FROM adoptopenjdk/openjdk11:jdk-11.0.16.1_1-alpine
COPY --from=build /usr/app/target/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar

ARG MG_USER=wso2
ARG MG_USER_ID=10500
RUN mkdir /tmp/tomcat static
RUN chmod -R 777 /tmp
RUN chmod -R 777 /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar
RUN adduser -S -u ${MG_USER_ID} ${MG_USER} -G root
USER 10500

ENTRYPOINT ["java","-jar","/usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar"]
RUN echo `ls`
EXPOSE 8080

# BUILD WITH : docker build -t certifier/rest-app:<tag> .
# RUN WITH : docker run -d -p 8080:8080 certifier/rest-app:<tag>