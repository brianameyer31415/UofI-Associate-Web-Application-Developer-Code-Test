-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: sequences, indices, triggers. Do not use it as a backup.

CREATE TABLE [dbo].[employees] (
    [employee_id] int,
    [first_name] varchar(50),
    [last_name] varchar(50),
    [department_id] int
);


INSERT INTO [dbo].[employees] ([employee_id],[first_name],[last_name],[department_id]) VALUES (1,'Brian','Meyer',1);
INSERT INTO [dbo].[employees] ([employee_id],[first_name],[last_name],[department_id]) VALUES (2,'Jeremy','Bird',1);
INSERT INTO [dbo].[employees] ([employee_id],[first_name],[last_name],[department_id]) VALUES (3,'Joe','Smith',2),(4,'Alex','Rogers',2),(5,'Julian','Smith',3),(6,'Ginger','Meyer',3),(7,'Hannah','Mazze',1),(8,'Mike ','Coles',1),(9,'Genny','Goodman',2),(10,'Kerri','Jones-Treece',2),(11,'Mark','Korte',3),(12,'Ricky','Borders',3);