ALTER DATABASE TransportSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
USE MASTER
GO
DROP DATABASE IF EXISTS TransportSystem
GO
CREATE DATABASE TransportSystem
GO

USE TransportSystem
go

DROP TABLE IF EXISTS [Admin]
go

DROP TABLE IF EXISTS [TransportOffer]
go

DROP TABLE IF EXISTS [Drive]
go

DROP TABLE IF EXISTS [Package]
go

DROP TABLE IF EXISTS [Courier]
go

DROP TABLE IF EXISTS [dbUser]
go

DROP TABLE IF EXISTS [Vehicle]
go

DROP TABLE IF EXISTS [District]
go

DROP TABLE IF EXISTS [City]
go

CREATE TABLE [Admin]
( 
	[idU]                integer  NOT NULL 
)
go

CREATE TABLE [City]
( 
	[idC]                integer  IDENTITY  NOT NULL ,
	[name]               varchar(100)  NOT NULL ,
	[postalCode]         varchar(100)  NOT NULL 
)
go

CREATE TABLE [Courier]
( 
	[idV]                integer  NOT NULL ,
	[status]             integer  NULL 
	CONSTRAINT [CourierStatusRule_450020305]
		CHECK  ( status BETWEEN 0 AND 1 ),
	[profit]             decimal(10,3)  NULL ,
	[idU]                integer  NOT NULL ,
	[deliveredPackages]  integer  NULL 
)
go

CREATE TABLE [dbUser]
( 
	[idU]                integer  IDENTITY  NOT NULL ,
	[username]           varchar(100)  NOT NULL ,
	[firstname]          varchar(100)  NOT NULL ,
	[lastname]           varchar(100)  NOT NULL ,
	[password]           varchar(100)  NOT NULL ,
	[sentPackages]       integer  NULL 
	CONSTRAINT [UserSentPackRule_967727906]
		CHECK  ( sentPackages >= 0 )
)
go

CREATE TABLE [District]
( 
	[idD]                integer  IDENTITY  NOT NULL ,
	[name]               varchar(100)  NOT NULL ,
	[X]                  integer  NOT NULL ,
	[Y]                  integer  NOT NULL ,
	[idC]                integer  NOT NULL 
)
go

CREATE TABLE [Drive]
( 
	[idDr]               integer  IDENTITY  NOT NULL ,
	[idP]                integer  NOT NULL ,
	[idU]                integer  NOT NULL 
)
go

CREATE TABLE [Package]
( 
	[idP]                integer  IDENTITY  NOT NULL ,
	[weight]             decimal(10,3)  NOT NULL ,
	[type]               integer  NOT NULL 
	CONSTRAINT [PackageTypeRule_1082183884]
		CHECK  ( type BETWEEN 0 AND 2 ),
	[idDest]             integer  NOT NULL ,
	[idSrc]              integer  NOT NULL ,
	[status]             integer  NOT NULL 
	CONSTRAINT [PackageStatusRule_1173931480]
		CHECK  ( status BETWEEN 0 AND 3 ),
	[courier]            integer  NULL ,
	[price]              decimal(10,3)  NULL ,
	[deliveryTime]       datetime  NULL ,
	[sender]             integer  NOT NULL 
)
go

CREATE TABLE [TransportOffer]
( 
	[percentage]         decimal(10,3)  NOT NULL 
	CONSTRAINT [MinPercentageRule_203229812]
		CHECK  ( percentage >= 0 ),
	[idP]                integer  NOT NULL ,
	[idU]                integer  NOT NULL ,
	[idTO]               integer  IDENTITY  NOT NULL ,
	[accepted]           integer  NOT NULL 
)
go

CREATE TABLE [Vehicle]
( 
	[idV]                integer  IDENTITY  NOT NULL ,
	[type]               integer  NOT NULL 
	CONSTRAINT [VehicleTypeRule_1132913114]
		CHECK  ( type BETWEEN 0 AND 2 ),
	[consumption]        decimal(10,3)  NOT NULL ,
	[licencePlate]       varchar(100)  NOT NULL 
)
go

ALTER TABLE [Admin]
	ADD CONSTRAINT [XPKAdmin] PRIMARY KEY  CLUSTERED ([idU] ASC)
go

ALTER TABLE [City]
	ADD CONSTRAINT [XPKCity] PRIMARY KEY  CLUSTERED ([idC] ASC)
go

ALTER TABLE [City]
	ADD CONSTRAINT [XAK1City] UNIQUE ([name]  ASC)
go

ALTER TABLE [City]
	ADD CONSTRAINT [XAK2City] UNIQUE ([postalCode]  ASC)
go

ALTER TABLE [Courier]
	ADD CONSTRAINT [XPKCourier] PRIMARY KEY  CLUSTERED ([idU] ASC)
go

ALTER TABLE [dbUser]
	ADD CONSTRAINT [XPKdbUser] PRIMARY KEY  CLUSTERED ([idU] ASC)
go

ALTER TABLE [dbUser]
	ADD CONSTRAINT [XAK1dbUser] UNIQUE ([username]  ASC)
go

ALTER TABLE [District]
	ADD CONSTRAINT [XPKDistrict] PRIMARY KEY  CLUSTERED ([idD] ASC)
go

ALTER TABLE [District]
	ADD CONSTRAINT [XAK2District] UNIQUE ([X]  ASC,[Y]  ASC)
go

ALTER TABLE [Drive]
	ADD CONSTRAINT [XPKDrive] PRIMARY KEY  CLUSTERED ([idDr] ASC)
go

ALTER TABLE [Drive]
	ADD CONSTRAINT [XAK1Drive] UNIQUE ([idP]  ASC)
go

ALTER TABLE [Package]
	ADD CONSTRAINT [XPKPackage] PRIMARY KEY  CLUSTERED ([idP] ASC)
go

ALTER TABLE [TransportOffer]
	ADD CONSTRAINT [XPKTransportOffer] PRIMARY KEY  CLUSTERED ([idTO] ASC)
go

ALTER TABLE [TransportOffer]
	ADD CONSTRAINT [XAK1TransportOffer] UNIQUE ([idU]  ASC,[idP]  ASC)
go

ALTER TABLE [Vehicle]
	ADD CONSTRAINT [XPKVehicle] PRIMARY KEY  CLUSTERED ([idV] ASC)
go

ALTER TABLE [Vehicle]
	ADD CONSTRAINT [XAK1Vehicle] UNIQUE ([licencePlate]  ASC)
go


ALTER TABLE [Admin]
	ADD CONSTRAINT [R_17] FOREIGN KEY ([idU]) REFERENCES [dbUser]([idU])
		ON DELETE CASCADE
		ON UPDATE CASCADE
go


ALTER TABLE [Courier]
	ADD CONSTRAINT [R_4] FOREIGN KEY ([idV]) REFERENCES [Vehicle]([idV])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go

ALTER TABLE [Courier]
	ADD CONSTRAINT [R_18] FOREIGN KEY ([idU]) REFERENCES [dbUser]([idU])
		ON DELETE CASCADE
		ON UPDATE CASCADE
go


ALTER TABLE [District]
	ADD CONSTRAINT [R_12] FOREIGN KEY ([idC]) REFERENCES [City]([idC])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go


ALTER TABLE [Drive]
	ADD CONSTRAINT [R_29] FOREIGN KEY ([idP]) REFERENCES [Package]([idP])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go

ALTER TABLE [Drive]
	ADD CONSTRAINT [R_30] FOREIGN KEY ([idU]) REFERENCES [Courier]([idU])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go


ALTER TABLE [Package]
	ADD CONSTRAINT [R_19] FOREIGN KEY ([courier]) REFERENCES [Courier]([idU])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE [Package]
	ADD CONSTRAINT [R_14] FOREIGN KEY ([idSrc]) REFERENCES [District]([idD])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE [Package]
	ADD CONSTRAINT [R_13] FOREIGN KEY ([idDest]) REFERENCES [District]([idD])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go

ALTER TABLE [Package]
	ADD CONSTRAINT [R_28] FOREIGN KEY ([sender]) REFERENCES [dbUser]([idU])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
go


ALTER TABLE [TransportOffer]
	ADD CONSTRAINT [R_22] FOREIGN KEY ([idU]) REFERENCES [Courier]([idU])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go

ALTER TABLE [TransportOffer]
	ADD CONSTRAINT [R_21] FOREIGN KEY ([idP]) REFERENCES [Package]([idP])
		ON DELETE CASCADE
		ON UPDATE NO ACTION
go
