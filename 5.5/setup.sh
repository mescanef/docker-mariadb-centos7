#!/bin/bash

StartMySQL()
{
    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MariaDB service startup"
        sleep 5
        mysql -uroot -h127.0.0.1 -e "status" > /dev/null 2>&1
        RET=$?
    done
}

SetupRootUser()
{
	# create root user with appropriate password
    echo "=> Creating MariaDB root user with ${_word} password"
	mysql -uroot -e "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASS';"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' WITH GRANT OPTION;"    
	echo "=> Done!"
	echo "========================================================================"
	echo "You can now connect to this MariaDB Server using:"
	echo ""
	echo "    mysql -u$MARIADB_USER -p$MARIADB_PASS -h<host> -P<port>"
	echo ""
	echo "========================================================================"
    # Remove test DB and anonymous access 
    mysql -uroot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -uroot -e "DROP DATABASE test;"
    mysql -uroot -e "DELETE FROM mysql.user WHERE password='';"     
}

if [ ${REPLICATION_MASTER} == "**False**" ]; then
    unset REPLICATION_MASTER
fi
	
if [ ${REPLICATION_SLAVE} == "**False**" ]; then
    unset REPLICATION_SLAVE
fi

if [[ ! -d $VOLUME_HOME/mysql ]]; then
	# Store password in the ENV var for later usage
    MARIADB_PASS=${MARIADB_PASS:-$(pwgen -s 12 1)}
    _word=$( [ ${MARIADB_PASS} ] && echo "preset" || echo "random" )
    # 
    echo "=> An empty or uninitialized MariaDB volume is detected in $VOLUME_HOME"
    echo "=> Installing MariaDB ..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql/ --basedir=/usr > /dev/null 2>&1
    echo "=> Done!"  
	# Set MySQL REPLICATION - MASTER
	if [ -n "${REPLICATION_MASTER}" ]; then 
    	echo "=> Configuring MySQL replicaiton as master ..."
    	if [ ! -f /repliation_configured ]; then
        	RAND="$(date +%s | rev | cut -c 1-2)$(echo ${RANDOM})"
        	echo "=> Writting configuration file '${CONF_FILE}' with server-id=${RAND}"
        	sed -i "s/^#server-id.*/server-id = ${RAND}/" ${CONF_FILE}
        	sed -i "s/^#log-bin.*/log-bin = mysql-bin/" ${CONF_FILE}
        	echo "=> Starting MySQL ..."
        	StartMySQL
        	echo "=> Creating a log user ${REPLICATION_USER}:${REPLICATION_PASS}"
        	mysql -uroot -e "CREATE USER '${REPLICATION_USER}'@'%' IDENTIFIED BY '${REPLICATION_PASS}'"
        	mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO '${REPLICATION_USER}'@'%'"
        	echo "=> Done!"
            SetupRootUser
        	mysqladmin -uroot shutdown
        	touch /repliation_configured
    	else
       	 	echo "=> MySQL replication master already configured, skip"
    	fi	
	# Set MySQL REPLICATION - SLAVE
	elif [ -n "${REPLICATION_SLAVE}" ]; then 
    	echo "=> Configuring MySQL replicaiton as slave ..."
    	if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ] && [ -n "${MYSQL_PORT_3306_TCP_PORT}" ]; then
        	if [ ! -f /repliation_configured ]; then
            	RAND="$(date +%s | rev | cut -c 1-2)$(echo ${RANDOM})"
            	echo "=> Writting configuration file '${CONF_FILE}' with server-id=${RAND}"
            	sed -i "s/^#server-id.*/server-id = ${RAND}/" ${CONF_FILE}
            	sed -i "s/^#log-bin.*/log-bin = mysql-bin/" ${CONF_FILE}
            	echo "=> Starting MySQL ..."
            	StartMySQL
            	echo "=> Setting master connection info on slave"
            	mysql -uroot -e "CHANGE MASTER TO MASTER_HOST='${MYSQL_PORT_3306_TCP_ADDR}',MASTER_USER='${MYSQL_ENV_REPLICATION_USER}',MASTER_PASSWORD='${MYSQL_ENV_REPLICATION_PASS}',MASTER_PORT=${MYSQL_PORT_3306_TCP_PORT}, MASTER_CONNECT_RETRY=30"
            	echo "=> Done!"
            	SetupRootUser
				mysqladmin -uroot shutdown
            	touch /repliation_configured
       		else
            	echo "=> MySQL replicaiton slave already configured, skip"
        	fi
    	else 
        	echo "=> Cannot configure slave, please link it to another MySQL container with alias as 'mysql'"
        	exit 1
    	fi
	else
        StartMySQL
		SetupRootUser
	fi    
    # Shutdown this DB instance
    mysqladmin -uroot shutdown
else
    echo "=> Using an existing volume of MariaDB"
fi

