FROM ubuntu:20.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update -y && \
    apt-get install -y python3-pip mysql-client && \
    pip3 install --upgrade pip

# 1. Set the directory FIRST
WORKDIR /app

# 2. Copy everything (including the templates folder) into /app
COPY . /app

# 3. Install requirements
RUN pip3 install -r requirements.txt

EXPOSE 8080

ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]