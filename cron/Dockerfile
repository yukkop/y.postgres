FROM alpine:latest

RUN apk add --no-cache cronie postgresql-client

ADD crontab /etc/crontabs/root
ADD backup.sh /root
ADD .env /root
RUN chmod +x /root/backup.sh

CMD ["crond", "-f", "-s"]
