FROM hurricanelabs/pfring
MAINTAINER Martijn van Maurik <

ENV HOME /root

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get dist-upgrade -yqq && \
    apt-get install -yqq python2.7 libnetfilter-queue1 libnetfilter-queue-dev curl cron supervisor && \
    git clone git://phalanx.openinfosecfoundation.org/oisf.git /usr/src/oisf && \
    git clone https://github.com/ironbee/libhtp.git -b 0.5.x /usr/src/oisf/libhtp && \
    curl -Ls "http://downloads.sourceforge.net/project/oinkmaster/oinkmaster/2.0/oinkmaster-2.0.tar.gz" | tar zx -C /usr/src/oisf && \
    cp /usr/src/oinkmaster/oinkmaster.pl /usr/sbin/oinkmaster && \
    ./autogen.sh && \
    LIBS="-lrt -lnuma" ./configure \
        --enable-pfring \
        --prefix=/opt/suricata \
        --with-libpfring-includes=/opt/pf_ring/include \
        --with-libpfring-libraries=/opt/pf_ring/lib \
        --with-libpcap-includes=/opt/pf_ring/include \
        --with-libpcap-libraries=/opt/pf_ring/lib \
        --disable-gccmarch-native \
        --enable-nfqueue && \
    make && make install && ldconfig && make install-conf

# Add resources
ADD resources/oinkmaster/oinkmaster.conf /etc/oinkmaster.conf
ADD resources/bin /usr/local/bin

# Add /opt/suricata/bin to PATH
ENV PATH /opt/suricata/bin:$PATH

VOLUME /data

CMD ["/usr/local/bin/run"]
