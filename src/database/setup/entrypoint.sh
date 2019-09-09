#!/bin/bash
set -euxo pipefail;

readonly SETUP_PATH="$PWD/setup";

echo "Starting the Initial Container Settings...";
bash "${SETUP_PATH}/setup-init.sh";

if [ $DB_MSSQL_CLUSTER_MASTER = 'Y' ]; then
    echo "Starting Master Cluster Configuration for SQL Server...";
    bash "${SETUP_PATH}/setup-cluster-master.sh";
fi

if [ $DB_MSSQL_CLUSTER_MASTER = 'Y' ] && [ $DB_MSSQL_APPLY_DATABASE = 'Y' ]; then
    echo "Starting Configuring Database in SQL Server...";
    bash "${SETUP_PATH}/setup-database.sh";
fi

if [ $DB_MSSQL_CLUSTER_WORKER = 'Y' ]; then
    echo "Starting Worker Cluster Configuration for SQL Server...";
    bash "${SETUP_PATH}/setup-cluster-worker.sh";
fi

exit $?;
