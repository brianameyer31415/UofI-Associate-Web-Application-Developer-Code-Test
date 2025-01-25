-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: sequences, indices, triggers. Do not use it as a backup.

CREATE TABLE [dbo].[departments] (
    [department_id] int,
    [department_name] varchar(50)
);


INSERT INTO [dbo].[departments] ([department_id],[department_name]) VALUES (1,'Web Services');
INSERT INTO [dbo].[departments] ([department_id],[department_name]) VALUES (2,'IT Services');
INSERT INTO [dbo].[departments] ([department_id],[department_name]) VALUES (3,'Networking');