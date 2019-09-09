#!/bin/bash
set -euxo pipefail;

# Enable AlwaysOn availability groups and restart mssql-server.
# Enable AlwaysOn availability groups on each node that hosts a 
# SQL Server instance. Then restart mssql-server. 
# Run the following script:

echo "Enable AlwaysOn availability groups...";
/opt/mssql/bin/mssql-conf set hadr.hadrenabled 1;

echo "Restart the mssql-server.service...";
systemctl restart mssql-server.service &

echo "Starting the SQL Server Service...";
/opt/mssql/bin/sqlservr &

echo "Please wait while SQL Server warms up...";
sleep 13s;

echo "Initializing cluster after 13 seconds of wait...";


# Enable an AlwaysOn_health event session:
# You can optionally enable AlwaysOn availability groups extended 
# events to help with root-cause diagnosis when you troubleshoot 
# an availability group. Run the following command on each 
# instance of SQL Server:

echo "Enable an AlwaysOn_health event session...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/enable-availability-group-events.sql;

cp /home/app/mssql/certificates/dbm_certificate.cer /var/opt/mssql/data/dbm_certificate.cer;
cp /home/app/mssql/certificates/dbm_certificate.pvk /var/opt/mssql/data/dbm_certificate.pvk;

chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*; 


# Create the certificate on secondary servers.
# The following Transact-SQL script creates a master key and a certificate 
# from the backup that you created on the primary SQL Server replica. 
# Update the script with strong passwords. 
# The decryption password is the same password that you used to create 
# the .pvk file in a previous step. To create the certificate,
# run the following script on all secondary servers:

echo "Create the certificate on all secondary servers...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/certificate-secondary.sql;


# Create the database mirroring endpoints on all replicas

# Database mirroring endpoints use the Transmission Control Protocol (TCP) 
# to send and receive messages between the server instances that participate 
# in database mirroring sessions or host availability replicas. 
# The database mirroring endpoint listens on a unique TCP port number.

# The following Transact-SQL script creates a listening endpoint named 
# Hadr_endpoint for the availability group. It starts the endpoint and 
# gives connection permission to the certificate that you created. 
# Before you run the script, replace the values between **< ... >**. 
# Optionally you can include an IP address LISTENER_IP = (0.0.0.0). 
# The listener IP address must be an IPv4 address. You can also use 0.0.0.0.

# Update the following Transact-SQL script for your environment on all 
# SQL Server instances:

echo "Create the database mirroring endpoints...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/endpoint.sql;


# Join node to availability group
# The last part is to join each secondary node to the availability group by 
# Executing the following command:

echo "Join node to availability group...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/join-availability-group.sql;






# TESTE

/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -Q "SELECT * FROM sys.databases WHERE name = 'quickstart'; GO" \
                            -Q "SELECT DB_NAME(database_id) AS 'database', synchronization_state_desc FROM sys.dm_hadr_database_replica_states;" \
                            | tee -a ./shared/db-test-$(hostname).log;




# docker exec -it ctn-mssql-node01 "bash"
#sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD -Q "SELECT * FROM sys.databases WHERE name = 'quickstart';"











echo "Finished configuring a Cluster Worker.";

exit $?;
