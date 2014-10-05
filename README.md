docker-mariadb-centos7
====================

A dockerfile with few shell scripts to run a MariaDB database server in Centos 7.x based container.


Usage
-----

To create the image `docker-mariadb-centos7/mariadb`, execute the following command on the docker-mariadb-centos7 folder:

        docker build -t docker-mariadb-centos7/mariadb .

To run the image and bind to port 3306:

        docker run -d -p 3306:3306 docker-mariadb-centos7/mariadb

The first time that you run your container, a new user `root` with all privileges 
will be created in MariaDB with a random password. To get the password, check the logs
of the container by running:

        docker logs <CONTAINER_ID>

You will see an output like the following:

        ========================================================================
        You can now connect to this MariaDB Server using:

            mysql -uroot -p<password> -h<host> -P<port>
        ========================================================================


Setting a specific password for the root account
-------------------------------------------------

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MARIADB_PASS` to your specific password when running the container:

        docker run -d -p 3306:3306 -e MARIADB_PASS="mypass" docker-mariadb-centos7/mariadb

