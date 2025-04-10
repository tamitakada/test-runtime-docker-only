# Pull base Ubuntu image
FROM ubuntu:20.04

# Install sofware properties common
RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
# Install Java17
  apt-get update && \
  apt-get install -y openjdk-17-jdk && \
# Install git
  apt-get install -y git && \
  git --version && \
# Install python
  apt-get update && \
  apt-get install -y python3 python3-dev python3-pip python3-venv && \
  rm -rf /var/lib/apt/lists/* && \
# Install misc
  apt-get update && \
  apt-get install -y sudo && \
  apt-get install -y bash && \
  apt-get install -y vim && \
  apt-get install -y wget

# Use openJDK17 as default
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64/

# Set up user
RUN useradd -ms /bin/bash -c "cachetester" cachetester && echo "cachetester:docker" | chpasswd && adduser cachetester sudo
USER cachetester

WORKDIR /home/cachetester/

# Install Maven 3.8.3 locally for user
RUN \
  wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.8.3/apache-maven-3.8.3-bin.tar.gz && \
  tar -xzf apache-maven-3.8.3-bin.tar.gz && mv apache-maven-3.8.3/ apache-maven/ && \
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64/' >> ~/.bashrc && \
  echo 'export M2_HOME=${HOME}/apache-maven' >> ~/.bashrc && \
  echo 'export MAVEN_HOME=${HOME}/apache-maven' >> ~/.bashrc && \
  echo 'export PATH=${M2_HOME}/bin:${PATH}' >> ~/.bashrc && \
  echo "alias python=python3" >> ~/.bashrc
  
USER root

RUN mkdir results
RUN mkdir results/no-change-no-cache
RUN mkdir results/no-change-cache
RUN mkdir results/single-change-no-cache
RUN mkdir results/single-change-cache

COPY fake_changes.py .
COPY cache_experiment.sh .
RUN chmod +x cache_experiment.sh && ./cache_experiment.sh
