FROM hadoop-playground:2.9.2

USER root

ARG HIVE_VERSION
ENV HIVE_VERSION=2.3.6 \
 	HIVE_HOME=/opt/hive \
 	HIVE_RUNTIME_HOME=/var/hive

ENV PATH=$HIVE_HOME/bin:$PATH

RUN apt-get update \
&&  apt-get install -qqy --no-install-recommends \
	libpostgresql-jdbc-java \
&&  apt-get autoremove --purge -yqq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    	   /tmp/*

# Get and set up Hive
RUN wget https://www.apache.org/dist/hive/KEYS \
&&	wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz \
&&	wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz.asc \
&&	gpg --import KEYS \
&&	gpg --verify apache-hive-$HIVE_VERSION-bin.tar.gz.asc \
&& 	tar -xzf apache-hive-$HIVE_VERSION-bin.tar.gz \
&&  mv apache-hive-$HIVE_VERSION-bin $HIVE_HOME \
&&  rm KEYS \
	   apache-hive-$HIVE_VERSION-bin.tar.gz \
	   apache-hive-$HIVE_VERSION-bin.tar.gz.asc

# Link postgres driver
RUN ln -s /usr/share/java/postgresql-jdbc4.jar $HIVE_HOME/lib/postgresql-jdbc4.jar

# Get and set up Tez
ARG TEZ_VERSION
ENV TEZ_VERSION=0.9.2 \
	TEZ_HOME=/opt/tez 

ENV TEZ_CONF_DIR=$TEZ_HOME/conf \
	TEZ_JARS=$TEZ_HOME/*:$TEZ_HOME/lib/* \
	PATH=$TEZ_HOME/bin:$PATH

ENV HADOOP_CLASSPATH=$TEZ_CONF_DIR:$TEZ_JARS:$HADOOP_CLASSPATH

# Get and set up Tez
RUN wget https://www.apache.org/dist/tez/KEYS \
&&	wget https://www.apache.org/dist/tez/$TEZ_VERSION/apache-tez-$TEZ_VERSION-bin.tar.gz \
&&	wget https://www.apache.org/dist/tez/$TEZ_VERSION/apache-tez-$TEZ_VERSION-bin.tar.gz.asc \
&&	gpg --import KEYS \
&&	gpg --verify apache-tez-$TEZ_VERSION-bin.tar.gz.asc \
&&  tar -xzf apache-tez-$TEZ_VERSION-bin.tar.gz \
&&  mv apache-tez-$TEZ_VERSION-bin $TEZ_HOME \
&&  rm  KEYS \
		apache-tez-$TEZ_VERSION-bin.tar.gz \
		apache-tez-$TEZ_VERSION-bin.tar.gz.asc 

RUN mkdir -p $HIVE_RUNTIME_HOME
RUN adduser --system \
			--group \
			--no-create-home \
			--home $HIVE_RUNTIME_HOME \
			--shell /usr/sbin/nologin \
			--disabled-password \
			hive \
&&  chown -R hive:hive $HIVE_RUNTIME_HOME \
					   $HIVE_CONF_DIR \
&&  usermod -a -G hadoop hive

USER hive

WORKDIR $HIVE_RUNTIME_HOME

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["invalid"]
