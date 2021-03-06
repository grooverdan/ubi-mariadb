FROM registry.access.redhat.com/ubi8

RUN groupadd -r mysql && useradd -r -g mysql mysql
COPY MariaDB.repo /etc/yum.repos.d/

# missing pwgen, and libboost_program_options.so.1.66.0 hence centos hack
RUN dnf update && \
	dnf install -y MariaDB-backup socat wget tzdata xz && \
	wget http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/boost-program-options-1.66.0-10.el8.x86_64.rpm && \
	dnf localinstall -y *rpm && \
	rm *rpm && \
	dnf install -y MariaDB-server && \
	dnf clean all

RUN rm -rf /var/lib/mysql; \
	mkdir -p /var/lib/mysql /var/run/mysqld /etc/mysql/conf.d/ /etc/mysql/mariadb.conf.d/; \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
	chmod 777 /var/run/mysqld

COPY docker.cnf /etc/my.cnf.d/

VOLUME /var/lib/mysql

RUN wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64 && \
	chmod a+x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

COPY /docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
