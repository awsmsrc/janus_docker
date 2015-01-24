FROM     ubuntu:14.04
MAINTAINER Luke Roberts "luke@sqwiggle.com"

### build tools ###
RUN apt-get update && apt-get install -y build-essential autoconf automake

### Janus ###
RUN apt-get update && apt-get install -y git-core mercurial subversion build-essential autoconf automake libmicrohttpd-dev libjansson-dev libnice-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libini-config-dev libcollection-dev pkg-config gengetopt libtool wget
RUN cd /root && git clone https://github.com/alanxz/rabbitmq-c && cd rabbitmq-c && git submodule update --init
RUN cd /root/rabbitmq-c && autoreconf -i && ./configure --prefix=/usr --libdir=/usr/lib64 && make && make install
# ADD deps/libssl1.0.0_1.0.1f-1ubuntu6_amd64.deb /root/libssl1.0.0_1.0.1f-1ubuntu6_amd64.deb
# ADD deps/libssl-dev_1.0.1f-1ubuntu6_amd64.deb /root/libssl-dev_1.0.1f-1ubuntu6_amd64.deb
# ADD deps/openssl_1.0.1f-1ubuntu9_amd64.deb /root/openssl_1.0.1f-1ubuntu9_amd64.deb
# RUN cd /root && dpkg -i libssl* openssl* && rm libssl* openssl*
RUN cd /root && svn co http://sctp-refimpl.googlecode.com/svn/trunk/KERN/usrsctp usrsctp && cd usrsctp && ./bootstrap && ./configure --prefix=/usr && make && make install
RUN cd /root && wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz && tar xfv opus-1.1.tar.gz && cd opus-1.1 && ./configure --prefix=/usr && make && make install
# ADD deps/janus-gateway /root/janus-gateway
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && git checkout master
RUN cd /root/janus-gateway && ./autogen.sh && ./configure --prefix=/opt/janus --disable-websockets --disable-docs && make && make install
RUN ln -s /usr/lib64/librabbitmq.so.1 /usr/lib
# ADD deps/janus /opt/janus/etc/janus
# ADD deps/start_janus.sh /root/janus-gateway/start_janus.sh

### SSH ###
# RUN apt-get update && apt-get install -y openssh-server
# RUN mkdir /var/run/sshd

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

# ADD deps/start-container /root/start-container
# ENTRYPOINT /root/start-container
#
RUN mv /opt/janus/etc/janus/janus.cfg.sample /opt/janus/etc/janus/janus.cfg
RUN mv /opt/janus/etc/janus/janus.plugin.videoroom.cfg.sample /opt/janus/etc/janus/janus.plugin.videoroom.cfg

CMD /opt/janus/bin/janus --config /opt/janus/etc/janus/janus.cfg --configs-folder=/opt/janus/etc/janus --port=8088 --secure-port=8188 --no-websockets --admin-port=7088 --debug-level=4
