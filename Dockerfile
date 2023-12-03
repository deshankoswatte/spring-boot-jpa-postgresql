FROM eclipse-temurin:17-jdk-jammy AS build
RUN apt-get update && apt-get install -y maven
COPY src /usr/app/src
COPY pom.xml /usr/app
RUN mvn -f /usr/app/pom.xml clean package -Dmaven.test.skip=true

# Package stage
FROM eclipse-temurin:17-jre-jammy
COPY --from=build /usr/app/target/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar

ARG MG_USER=wso2
ARG MG_USER_ID=10500
RUN mkdir /tmp/tomcat static
RUN chmod -R 777 /tmp
RUN chmod -R 777 /usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar
RUN addgroup --system --gid 1001 ${MG_USER}
RUN adduser --system --uid ${MG_USER_ID} ${MG_USER}
# Set a non-root user
USER ${MG_USER_ID}

ENTRYPOINT ["java","-jar","/usr/app/choreotest/spring-boot-jpa-postgresql-0.0.1-SNAPSHOT.jar"]
RUN echo `ls`
EXPOSE 8080

# BUILD WITH : docker build -t certifier/rest-app:<tag> .
# RUN WITH : docker run -d -p 8080:8080 certifier/rest-app:<tag>