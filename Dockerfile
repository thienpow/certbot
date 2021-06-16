FROM thienpow/wwwloader:latest

RUN apk update && apk --no-cache add curl certbot

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod 755 kubectl && mv kubectl /usr/local/bin/

COPY ./www /www

COPY ./start.sh /start
RUN chmod u+x /start

CMD ["/start"]