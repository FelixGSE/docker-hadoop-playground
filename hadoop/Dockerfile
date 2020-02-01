FROM debian:stretch

ARG HADOOP_VERSION
ENV DEBIAN_FRONTEND=noninteractive \
	HADOOP_VERSION=2.9.2 \
	HADOOP_HOME=/opt/hadoop \
	HADOOP_CONF_DIR=/etc/hadoop \
	HADOOP_RUNTIME_HOME=/var/hadoop \
	HADOOP_LOG_DIR=/var/hadoop/logs \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

ENV PATH=$HADOOP_HOME/bin:$PATH

RUN apt-get update \
&&  apt-get upgrade -qqy \
&&  apt-get install -qqy --no-install-recommends \
	ca-certificates \
	gnupg \
	openjdk-8-jdk \
	wait-for-it \
	wget \
&&  apt-get autoremove --purge -yqq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    	   /tmp/*

# Get and set up hadoop
RUN wget https://dist.apache.org/repos/dist/release/hadoop/common/KEYS \
&&  wget https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
&&	wget https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc \
&&	gpg --import KEYS \
&&	gpg --verify hadoop-$HADOOP_VERSION.tar.gz.asc \
&&  tar -xzf hadoop-$HADOOP_VERSION.tar.gz \
&&	mv hadoop-$HADOOP_VERSION $HADOOP_HOME \
&&  rm hadoop-$HADOOP_VERSION.tar.gz \
	   hadoop-$HADOOP_VERSION.tar.gz.asc \
	   KEYS \
&& 	ln -s $HADOOP_HOME/etc/hadoop $HADOOP_CONF_DIR \
&&	mkdir -p $HADOOP_LOG_DIR \
			 $HADOOP_RUNTIME_HOME/yarn/userlogs \
&& 	adduser --system \
			--group \
			--no-create-home \
			--home $HADOOP_RUNTIME_HOME \
			--shell /usr/sbin/nologin \
			--disabled-password \
			hadoop \
&&  chown -R hadoop:hadoop $HADOOP_RUNTIME_HOME \
						   $HADOOP_CONF_DIR 
	
USER hadoop

WORKDIR $HADOOP_RUNTIME_HOME

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["invalid"]
