FROM ubuntu:20.04

RUN apt-get update && apt-get install -y iputils-ping curl nano certbot && rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod 755 kubectl && mv kubectl /usr/local/bin/

COPY ./wwwloader /wwwloader
RUN chmod u+x /wwwloader

COPY ./www /www

COPY ./start.sh /start
RUN chmod u+x /start

CMD ["/start"]