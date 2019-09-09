#-----------------------|DOCUMENTATION|-----------------------#
# @descr: Custom dockerfile of a Microsoft SQL Server image.
# @fonts: https://docs.docker.com/engine/reference/builder/
#         https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash
#         https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-docker?view=sql-server-2017
#         https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-2017
#         https://hub.docker.com/_/microsoft-mssql-server
#         https://github.com/microsoft/sql-server-samples
#         https://www.handsonarchitect.com/2018/01/build-custom-sql-server-2017-linux.html
# @example:
#     
#-------------------------------------------------------------#

# Official images for Microsoft SQL Server on Linux for Docker Engine.
FROM mcr.microsoft.com/mssql/server:2017-latest AS build

# Sets the default working directory of the image.
ENV DEPLOYMENT_DIR=/home/app/mssql

# Sets the database connection variables.
ENV DB_MSSQL_USER=sa
ENV DB_MSSQL_PASSWORD=!demo54321
ENV DB_MSSQL_DATABASE=master
ENV DB_MSSQL_TZ=America/New_York
ENV DB_MSSQL_CLUSTER_MASTER=N
ENV DB_MSSQL_CLUSTER_WORKER=N
ENV DB_MSSQL_APPLY_DATABASE=N

# Sets default environment variables of the mssql image.
ENV MSSQL_PID=Developer 
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=$DB_MSSQL_PASSWORD
ENV TZ=$DB_MSSQL_TZ

# Sets the variable to inform Docker that the container
# listens on the specified network port.
EXPOSE 1433
EXPOSE 5022

# Sets the default working directory of the image for any
# RUN, CMD, ENTRYPOINT, COPY, and ADD statements that come
# with it in the Dockerfile.
WORKDIR $DEPLOYMENT_DIR

# Copies new files or directories from <src> and adds them to
# the filesystem of the container at the path <dest>.
COPY ./domain  $DEPLOYMENT_DIR/domain
COPY ./scripts $DEPLOYMENT_DIR/scripts
COPY ./setup   $DEPLOYMENT_DIR/setup

# Run the command to grant permissions for scripts to be executable.
RUN chmod +x ./setup/*.sh

# Run a command to allows you to configure a container that will run as an executable.
ENTRYPOINT ./setup/entrypoint.sh | tee -a ./shared/deployment-$(hostname).log

# The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
HEALTHCHECK --interval=11s --timeout=33s --retries=3 \
            CMD /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD -Q 'select 1'
