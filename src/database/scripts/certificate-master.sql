
SET NOCOUNT ON;
GO

USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Master_Key_Password';
CREATE CERTIFICATE dbm_certificate WITH SUBJECT = 'dbm';
BACKUP CERTIFICATE dbm_certificate
    TO FILE = '/var/opt/mssql/data/dbm_certificate.cer'
    WITH PRIVATE KEY (
        FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
        ENCRYPTION BY PASSWORD = 'Private_Key_Password'
    );
GO
