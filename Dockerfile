FROM golang:1.14-alpine AS easy-novnc-build
WORKDIR /src
RUN go mod init build  \
    && git clone http://192.168.3.190:8088/cxd/easy-novnc.git \
    && cd easy-novnc \
    && go build -o /bin/easy-novnc

FROM ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive 
COPY sources.list /etc/apt/
RUN apt-get update  \
    && apt-get install -y --no-install-recommends openbox tint2 xdg-utils lxterminal hsetroot tigervnc-standalone-server supervisor \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* 
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY supervisord.conf /etc/
COPY menu.xml /etc/xdg/openbox/
RUN echo 'hsetroot -solid "#123456" &' >> /etc/xdg/openbox/autostart
EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/supervisord"]
