
-- Enable an AlwaysOn_health event session.
-- You can optionally enable AlwaysOn availability groups 
-- extended events to help with root-cause diagnosis when 
-- you troubleshoot an availability group. Run the following 
-- command on each instance of SQL Server:

SET NOCOUNT ON;
GO

USE master;
GO

ALTER EVENT SESSION  AlwaysOn_health ON SERVER WITH (STARTUP_STATE=ON);
GO
