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

# Exposed ENV
ENV MARIADB_USER root
ENV VOLUME_HOME /var/lib/mysql
ENV CONF_FILE /etc/mysql/conf.d/my.cnf

ENV REPLICATION_MASTER **False**
ENV REPLICATION_SLAVE **False**
ENV REPLICATION_USER replica
ENV REPLICATION_PASS replica

# Install packages
RUN yum install -y mariadb-server mariadb pwgen && \
    rm -rf /var/lib/mysql/* 

# Add MySQL configuration
ADD my.cnf /etc/mysql/conf.d/my.cnf

ADD run.sh /run.sh
ADD setup.sh /setup.sh
RUN chmod 775 /*.sh

# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

RUN /setup.sh

EXPOSE 3306
CMD ["/run.sh"]


