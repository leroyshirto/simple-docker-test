FROM golang as supervisorgo
MAINTAINER brian.wilkinson@1and1.co.uk
WORKDIR /go/src/github.com/1and1internet/supervisorgo
RUN git clone https://github.com/1and1internet/supervisorgo.git . \
	&& go build -o release/supervisorgo \
	&& echo "supervisorgo successfully built"

FROM golang as configurability
MAINTAINER brian.wilkinson@1and1.co.uk
WORKDIR /go/src/github.com/1and1internet/configurability
RUN git clone https://github.com/1and1internet/configurability.git . \
	&& make main \
	&& echo "configurator successfully built"

FROM debian:9
MAINTAINER brian.wojtczak@1and1.co.uk
COPY files/ /
COPY --from=supervisorgo /go/src/github.com/1and1internet/supervisorgo/release/supervisorgo /usr/bin/supervisorgo
COPY --from=configurability /go/src/github.com/1and1internet/configurability/bin/configurator /usr/bin/configurator
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& update-alternatives --install /usr/bin/supervisord supervisord /usr/bin/supervisorgo 1 \
	&& rm /etc/apt/apt.conf.d/docker-no-languages \
	&& debconf-set-selections -v /etc/debconf-preseed.txt \
	&& apt-get update \
	&& apt-get upgrade \
	&& apt-get install --no-install-recommends apt-utils debconf-utils \
	&& apt-get install --no-install-recommends apt-transport-https ca-certificates \
	&& apt-get install --no-install-recommends locales gettext-base ssmtp procps \
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& chmod -R 777 /var/log /etc/ssmtp /etc/passwd /etc/group \
	&& chmod -R 755 /init /hooks \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& sed -i '/^root.*/d' /etc/shadow
ENV \
	LC_ALL=en_GB.UTF-8 \
	LANG=en_GB.UTF-8 \
	LANGUAGE=en_GB.UTF-8 \
	SMTP_USER="" \
	SMTP_PASS="" \
	SMTP_DOMAIN="" \
	SMTP_RELAYHOST="" \
    ULIMIT_CORE=0
ENTRYPOINT ["/bin/bash", "/init/entrypoint"]
CMD ["/init/supervisord"]
