FROM golang as supervisorgo
MAINTAINER brian.wilkinson@1and1.co.uk
WORKDIR /go/src/github.com/1and1internet/supervisorgo
RUN git clone https://github.com/1and1internet/supervisorgo.git . \
	&& go build -o release/supervisorgo \
	&& echo "supervisorgo successfully built"

FROM debian:9
MAINTAINER brian.wojtczak@1and1.co.uk
COPY files/ /
COPY --from=supervisorgo /go/src/github.com/1and1internet/supervisorgo/release/supervisorgo /usr/bin/supervisorgo
RUN \
  chmod -R 777 /var/run