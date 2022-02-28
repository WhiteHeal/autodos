FROM alpine/bombardier

RUN apk add --no-cache bash curl nmap

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["bash"]
CMD ["/entrypoint.sh"]