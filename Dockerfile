version: '3.8'
networks:
  jenkins-network:
    name: jenkins
volumes:
  data:
    name: jenkins-data
  certs:
    name: jenkins-docker-certs
services:
  dind:
    container_name: jenkins-docker
    image: docker:dind
    privileged: true
    restart: unless-stopped
    networks:
      jenkins-network:
        aliases:
          - docker
    volumes:
      - data:/var/jenkins_home
      - certs:/certs/client
    environment:
      - DOCKER_TLS_CERTDIR=/certs
    
  jenkins:
    container_name: jenkins-blueocean
    image: jenkinsci/blueocean
    restart: unless-stopped
    networks:
      - jenkins-network
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - data:/var/jenkins_home
      - certs:/certs/client:ro
    environment:
      - DOCKER_HOST=tcp://docker:2376
      - DOCKER_CERT_PATH=/certs/client
      - DOCKER_TLS_VERIFY=1FROM jenkins/jenkins:2.289.1-lts-jdk11
USER lntoan
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.24.6 docker-workflow:1.26"
