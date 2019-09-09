
SET NOCOUNT ON;
GO

USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Secondary_Key_Password';
CREATE CERTIFICATE dbm_certificate
    FROM FILE = '/var/opt/mssql/data/dbm_certificate.cer'
    WITH PRIVATE KEY (
        FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
        DECRYPTION BY PASSWORD = 'Private_Key_Password'
    );
GO
