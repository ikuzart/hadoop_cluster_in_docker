FROM centos:latest

USER root

RUN yum clean all;
RUN rpm --rebuilddb;
RUN yum install -y wget which tar sudo openssh-server openssh-clients rsync java-1.8.0-openjdk java-1.8.0-openjdk-devel
RUN yum update -y libselinux


RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN ssh-keygen -A

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk
ENV PATH $PATH:$JAVA_HOME/bin

RUN wget -O hadoop.tar.gz https://www-eu.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
RUN tar -xzf hadoop.tar.gz -C /usr/local/ && rm hadoop.tar.gz
RUN ln -s /usr/local/hadoop-3.1.2 /usr/local/hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

ADD hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

RUN mkdir -p /mnt/filer1/dfs/ha-name-dir-shared
RUN echo export HDFS_NAMENODE_USER="root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo export HDFS_DATANODE_USER="root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo export HDFS_SECONDARYNAMENODE_USER="root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo export YARN_RESOURCEMANAGER_USER="root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo export YARN_NODEMANAGER_USER="root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

ADD core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

RUN echo "Port 2122" >> /etc/ssh/sshd_config

CMD ["/bin/bash"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 22 2122
