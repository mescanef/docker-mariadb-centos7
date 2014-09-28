#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MariaDB service startup"
    sleep 5
    mysql -u$MARIADB_USER -h127.0.0.1 -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Creating MariaDB root user with ${_word} password"

mysql -u$MARIADB_USER -e "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASS';"
mysql -u$MARIADB_USER -e "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_USER'@'%' WITH GRANT OPTION;"
    
echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MariaDB Server using:"
echo ""
echo "    mysql -u$MARIADB_USER -p$MARIADB_PASS -h<host> -P<port>"
echo ""
echo "========================================================================"
