
# Quickstart of a SQL Server cluster with Docker Compose.

#### Translation for: **[English](https://github.com/alisonbuss/quickstart-mssql/blob/master/README_LANG_EN.md)**.

#### Project Status: *(Development)*.

https://www.sqlshack.com/configure-sql-server-2017-linux-mssql-conf-available-tools/

...


docker exec -it container-db "bash"


docker exec -it container-mssql-node01 "bash"


volume-remove-mssql01:
	@docker volume rm -f quickstart-mssql_vol_data_mssql01;

volume-remove-mssql02:
	@docker volume rm -f quickstart-mssql_vol_data_mssql02;

volume-remove-mssql03:
	@docker volume rm -f quickstart-mssql_vol_data_mssql03;

volume-remove-mssql-single:
	@docker volume rm -f quickstart-mssql_vol_data_mssql_single;

...

Dockerfile.single
Dockerfile.cluster



https://opensource.com/article/18/8/what-how-makefile



https://docs.microsoft.com/pt-br/sql/linux/sql-server-linux-availability-group-configure-ha?view=sql-server-2017
https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-configure-ha?view=sql-server-2017 

MASTER

1)
script-certificate-master.sql

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Master_Key_Password>';
CREATE CERTIFICATE dbm_certificate WITH SUBJECT = 'dbm';
BACKUP CERTIFICATE dbm_certificate
   TO FILE = '/var/opt/mssql/data/dbm_certificate.cer'
   WITH PRIVATE KEY (
           FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
           ENCRYPTION BY PASSWORD = 'Private_Key_Password'
       );

$ cp dbm_certificate.cer   /home/app/mssql/certificates/dbm_certificate.cer;
$ cp dbm_certificate.pvk  /home/app/mssql/certificates/dbm_certificate.pvk;

$ chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*; 

2)
script-endpoint.sql

CREATE ENDPOINT [Hadr_endpoint]
    AS TCP (LISTENER_IP = (0.0.0.0), LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
        ROLE = ALL,
        AUTHENTICATION = CERTIFICATE dbm_certificate,
        ENCRYPTION = REQUIRED ALGORITHM AES
        );
ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;

3)
script-availability-group.sql  

CREATE AVAILABILITY GROUP [ag1]
    WITH (CLUSTER_TYPE = NONE)
    FOR REPLICA ON
    N'mssql-node01'
        WITH (
        ENDPOINT_URL = N'tcp://mssql-node01:5022',
        AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
            SEEDING_MODE = AUTOMATIC,
            FAILOVER_MODE = MANUAL,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
            ),
    N'mssql-node02'
        WITH (
        ENDPOINT_URL = N'tcp://mssql-node02:5022',
        AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
            SEEDING_MODE = AUTOMATIC,
            FAILOVER_MODE = MANUAL,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
            ),
    N'mssql-node03'
        WITH (
        ENDPOINT_URL = N'tcp://mssql-node03:5022',
        AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
            SEEDING_MODE = AUTOMATIC,
            FAILOVER_MODE = MANUAL,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
            )

ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;




SECONDARY

1)
$ cp /home/app/mssql/certificates/dbm_certificate.cer   /var/opt/mssql/data/dbm_certificate.cer;
$ cp /home/app/mssql/certificates/dbm_certificate.pvk  /var/opt/mssql/data/dbm_certificate.pvk;

$ chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*;   

script-certificate-secondary.sql

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Secondary_Key_Password';
CREATE CERTIFICATE dbm_certificate
    FROM FILE = '/var/opt/mssql/data/dbm_certificate.cer'
    WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
    DECRYPTION BY PASSWORD = 'Private_Key_Password'
            );

2)
script-endpoint.sql

CREATE ENDPOINT [Hadr_endpoint]
    AS TCP (LISTENER_IP = (0.0.0.0), LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
        ROLE = ALL,
        AUTHENTICATION = CERTIFICATE dbm_certificate,
        ENCRYPTION = REQUIRED ALGORITHM AES
        );
ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;

https://docs.microsoft.com/pt-br/sql/linux/sql-server-linux-availability-group-configure-ha?view=sql-server-2017#join-secondary-replicas-to-the-ag




https://linuxhint.com/bash_loop_list_strings/



### References:

https://docs.microsoft.com/pt-br/sql/linux/sql-server-linux-availability-group-configure-ha?view=sql-server-2017

https://medium.com/@yani/two-way-link-with-docker-compose-8e774887be41

A ARTE DE ESCOLHER NOMES PARA SERVIDORES
https://blog.welrbraga.eti.br/?p=1163

Procedimentos de Padronização de Nomes
https://fabiozibiani.wordpress.com/2011/11/15/procedimentos-de-padronizacao-de-nomes/


https://medium.com/@yani/two-way-link-with-docker-compose-8e774887be41

https://pt.stackoverflow.com/questions/243881/docker-compose-link

http://blog.code4hire.com/2018/06/define-named-volume-with-host-mount-in-the-docker-compose-file/

https://sandro-keil.de/blog/docker-compose-with-named-volumes-and-multiple-networks/

https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-overview?view=sql-server-2017
https://itnext.io/docker-101-fundamentals-the-dockerfile-b33b59d0f14b

https://www.sqlshack.com/configure-sql-server-2017-linux-mssql-conf-available-tools/

https://github.com/enriquecatala/sqlserver-docker-alwayson
https://medium.com/@2hamed/replicating-postgres-inside-docker-the-how-to-3244dc2305be
https://github.com/syndbg/postgres-docker-cluster/blob/master/docker-compose.yml

https://www.virtual-dba.com/what-is-alwayson/
http://marti.com.br/ms-sql-server-no-docker/

http://marti.com.br/ms-sql-server-no-docker/


https://medium.com/ekode/azure-data-studio-e-sql-server-profiler-monitorando-seu-banco-de-dados-199bcb3bd1c1
https://medium.com/@wendreof/como-gerenciar-sql-server-no-linux-52cd49a7978a

https://www.mundodocker.com.br/o-que-e-dockerfile/
http://stack.desenvolvedor.expert/appendix/docker/rede.html
https://runnable.com/docker/docker-compose-networking

https://linuxhint.com/docker_volumes_docker_compose/


https://tecadmin.net/tutorial/docker/docker-compose/

https://devblog.xero.com/getting-started-with-running-unit-tests-in-net-core-with-xunit-and-docker-e92915e4075c
https://www.colinsalmcorner.com/post/net-core-multi-stage-dockerfile-with-test-and-code-coverage-in-azure-pipelines
https://gunnarpeipman.com/aspnet/code-coverage/
https://dzone.com/articles/code-coverage-reports-for-aspnet-core
https://medium.com/swlh/generating-code-coverage-reports-in-dotnet-core-bb0c8cca66
https://dev.to/deinsoftware/net-core-unit-test-and-code-coverage-with-visual-studio-code-37bp

https://github.com/Frank-Geisler/SQL-Server-Sample-Docker-Container/blob/master/mssql-server-linux-adventureworksdw2017/Dockerfile

https://github.com/mcmoe/mssqldocker/blob/master/Dockerfile

https://runnable.com/docker/docker-compose-networking



https://marketplace.visualstudio.com/items?itemName=mtxr.sqltools

https://marketplace.visualstudio.com/items?itemName=alexcvzz.vscode-sqlite

https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql


https://marketplace.visualstudio.com/items?itemName=formulahendry.dotnet-test-explorer

https://marketplace.visualstudio.com/items?itemName=p1c2u.docker-compose



http://stack.desenvolvedor.expert/appendix/docker/rede.html

https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

https://www.mundodocker.com.br/o-que-e-dockerfile/

https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/


https://menakamadushanka.wordpress.com/2017/12/15/how-to-deploy-a-mysql-cluster-from-scratch-with-docker/
https://medium.com/@ahmedamedy/mysql-clustering-with-docker-611dc28b8db7


### License

[<img width="190" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/logo-open-source-550x200px.png">](https://opensource.org/licenses)
[<img width="166" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/icon-license-mit-500px.png">](https://github.com/alisonbuss/quickstart-mssql/blob/master/LICENSE)
