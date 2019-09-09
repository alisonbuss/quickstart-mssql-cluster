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


# Create a certificate.
# The SQL Server service on Linux uses certificates to 
# authenticate communication between the mirroring endpoints.

# The following Transact-SQL script creates a master key and a 
# certificate. It then backs up the certificate and secures the 
# file with a private key. Update the script with strong passwords. 
# Connect to the primary SQL Server instance. 
# To create the certificate,run the following Transact-SQL script:

echo "Create a certificate for Master...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/certificate-master.sql;

cp /var/opt/mssql/data/dbm_certificate.cer /home/app/mssql/certificates/dbm_certificate.cer;
cp /var/opt/mssql/data/dbm_certificate.pvk /home/app/mssql/certificates/dbm_certificate.pvk;

chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*; 


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


# Create availability group with three synchronous replicas
# The following Transact-SQL scripts create an AG for high availability 
# named ag1. The script configures the AG replicas with SEEDING_MODE = AUTOMATIC. 
# This setting causes SQL Server to automatically create the database 
# on each secondary server. Update the following script for your environment. 
# Replace the <node1>, <node2>, or <node3> values with the names of the SQL Server 
# instances that host the replicas. Replace the <5022> with the port you set for 
# the data mirroring endpoint. To create the AG, run the following Transact-SQL 
# on the SQL Server instance that hosts the primary replica.

echo "Create AG with three synchronous replicas...";
/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/availability-group.sql;

echo "Finished configuring a Cluster Master.";

exit $?;
