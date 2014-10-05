# Dockerfile for CentOS/RHEL v7.x - by mescanef | Based on tutum-docker-{mariadb,mysql}
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from centos:centos7
MAINTAINER mescanef <zone@mescanef.net>

# Env vars
ENV MARIADB_USER root
ENV VOLUME_HOME /var/lib/mysql
ENV CONF_FILE /etc/my.cnf.d/my.cnf
ENV REPLICATION_MASTER **False**
ENV REPLICATION_SLAVE **False**
ENV REPLICATION_USER replica
ENV REPLICATION_PASS replica

# upgrade...
RUN yum upgrade -y
# install packages...
RUN yum install -y mariadb-server mariadb && \
    rm -rf /var/lib/mysql/* 
# ..and install pwgen from epel repo
RUN rpm -Uvhf http://mirrors.kernel.org/fedora-epel/7/x86_64/e/epel-release-7-2.noarch.rpm && \
	yum install -y pwgen --enablerepo=epel

# Add MySQL configuration
ADD my.cnf ${CONF_FILE}

ADD run.sh /run.sh
RUN chmod 775 /*.sh

# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 3306
CMD ["/run.sh"]


