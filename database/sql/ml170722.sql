
CREATE TABLE [Admin]
( 
	[idU]                integer  NOT NULL 
)
go

CREATE TABLE [Approved]
( 
	[idP]                integer  NOT NULL ,
	[idU]                integer  NOT NULL ,
	[idA]                integer  IDENTITY  NOT NULL 
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
	[profit]             varchar(100)  NULL ,
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
	[idU]                integer  NULL ,
	[price]              decimal(10,3)  NULL ,
	[deliveryTime]       datetime  NULL 
)
go

CREATE TABLE [TransportOffer]
( 
	[percentage]         decimal(10,3)  NOT NULL 
	CONSTRAINT [MinPercentageRule_203229812]
		CHECK  ( percentage >= 0 ),
	[idP]                integer  NOT NULL ,
	[idU]                integer  NOT NULL 
)
go

CREATE TABLE [Vehicle]
( 
	[idV]                integer  IDENTITY  NOT NULL ,
	[type]               integer  NOT NULL 
	CONSTRAINT [VehicleTypeRule_1132913114]
		CHECK  ( type BETWEEN 0 AND 2 ),
	[consumption]        decimal(10,3)  NOT NULL ,
	[licencePlate]       varchar(100)  NULL 
)
go

ALTER TABLE [Admin]
	ADD CONSTRAINT [XPKAdmin] PRIMARY KEY  CLUSTERED ([idU] ASC)
go

ALTER TABLE [Approved]
	ADD CONSTRAINT [XPKApproved] PRIMARY KEY  CLUSTERED ([idA] ASC)
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

ALTER TABLE [Package]
	ADD CONSTRAINT [XPKPackage] PRIMARY KEY  CLUSTERED ([idP] ASC)
go

ALTER TABLE [TransportOffer]
	ADD CONSTRAINT [XPKTransportOffer] PRIMARY KEY  CLUSTERED ([idP] ASC,[idU] ASC)
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


ALTER TABLE [Approved]
	ADD CONSTRAINT [R_23] FOREIGN KEY ([idP],[idU]) REFERENCES [TransportOffer]([idP],[idU])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
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


ALTER TABLE [Package]
	ADD CONSTRAINT [R_19] FOREIGN KEY ([idU]) REFERENCES [Courier]([idU])
		ON DELETE SET NULL
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


CREATE TRIGGER tU_Admin ON Admin FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on Admin */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidU integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* dbUser  Admin on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00015196", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Admin"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_17", FK_COLUMNS="idU" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,dbUser
        WHERE
          /* %JoinFKPK(inserted,dbUser) */
          inserted.idU = dbUser.idU
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Admin because dbUser does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_Approved ON Approved FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on Approved */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* TransportOffer  Approved on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00017cdb", PARENT_OWNER="", PARENT_TABLE="TransportOffer"
    CHILD_OWNER="", CHILD_TABLE="Approved"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="idP""idU" */
    IF EXISTS (SELECT * FROM deleted,TransportOffer
      WHERE
        /* %JoinFKPK(deleted,TransportOffer," = "," AND") */
        deleted.idP = TransportOffer.idP AND
        deleted.idU = TransportOffer.idU AND
        NOT EXISTS (
          SELECT * FROM Approved
          WHERE
            /* %JoinFKPK(Approved,TransportOffer," = "," AND") */
            Approved.idP = TransportOffer.idP AND
            Approved.idU = TransportOffer.idU
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Approved because TransportOffer exists.'
      GOTO error
    END


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_Approved ON Approved FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on Approved */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidA integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* TransportOffer  Approved on child update no action */
  /* ERWIN_RELATION:CHECKSUM="0001b44b", PARENT_OWNER="", PARENT_TABLE="TransportOffer"
    CHILD_OWNER="", CHILD_TABLE="Approved"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="idP""idU" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idP) OR
    UPDATE(idU)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,TransportOffer
        WHERE
          /* %JoinFKPK(inserted,TransportOffer) */
          inserted.idP = TransportOffer.idP and
          inserted.idU = TransportOffer.idU
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    select @nullcnt = count(*) from inserted where
      inserted.idP IS NULL AND
      inserted.idU IS NULL
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Approved because TransportOffer does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_City ON City FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on City */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* City  District on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="0000d68f", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="District"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="idC" */
    DELETE District
      FROM District,deleted
      WHERE
        /*  %JoinFKPK(District,deleted," = "," AND") */
        District.idC = deleted.idC


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_City ON City FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on City */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidC integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* City  District on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="000119ff", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="District"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="idC" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idC)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,District
      WHERE
        /*  %JoinFKPK(District,deleted," = "," AND") */
        District.idC = deleted.idC
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update City because District exists.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_Courier ON Courier FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on Courier */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* Courier  TransportOffer on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="0001aca5", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="idU" */
    DELETE TransportOffer
      FROM TransportOffer,deleted
      WHERE
        /*  %JoinFKPK(TransportOffer,deleted," = "," AND") */
        TransportOffer.idU = deleted.idU

    /* erwin Builtin Trigger */
    /* Courier  Package on parent delete set null */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_19", FK_COLUMNS="idU" */
    UPDATE Package
      SET
        /* %SetFK(Package,NULL) */
        Package.idU = NULL
      FROM Package,deleted
      WHERE
        /* %JoinFKPK(Package,deleted," = "," AND") */
        Package.idU = deleted.idU


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_Courier ON Courier FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on Courier */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidU integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* Courier  TransportOffer on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="00046e2b", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="idU" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,TransportOffer
      WHERE
        /*  %JoinFKPK(TransportOffer,deleted," = "," AND") */
        TransportOffer.idU = deleted.idU
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Courier because TransportOffer exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* Courier  Package on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_19", FK_COLUMNS="idU" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Package
      WHERE
        /*  %JoinFKPK(Package,deleted," = "," AND") */
        Package.idU = deleted.idU
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Courier because Package exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* dbUser  Courier on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_18", FK_COLUMNS="idU" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,dbUser
        WHERE
          /* %JoinFKPK(inserted,dbUser) */
          inserted.idU = dbUser.idU
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Courier because dbUser does not exist.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* Vehicle  Courier on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Vehicle"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_4", FK_COLUMNS="idV" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idV)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Vehicle
        WHERE
          /* %JoinFKPK(inserted,Vehicle) */
          inserted.idV = Vehicle.idV
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Courier because Vehicle does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_dbUser ON dbUser FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on dbUser */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* dbUser  Courier on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="00017f6b", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_18", FK_COLUMNS="idU" */
    DELETE Courier
      FROM Courier,deleted
      WHERE
        /*  %JoinFKPK(Courier,deleted," = "," AND") */
        Courier.idU = deleted.idU

    /* erwin Builtin Trigger */
    /* dbUser  Admin on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Admin"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_17", FK_COLUMNS="idU" */
    DELETE Admin
      FROM Admin,deleted
      WHERE
        /*  %JoinFKPK(Admin,deleted," = "," AND") */
        Admin.idU = deleted.idU


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_dbUser ON dbUser FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on dbUser */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidU integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* dbUser  Courier on parent update cascade */
  /* ERWIN_RELATION:CHECKSUM="00028deb", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_18", FK_COLUMNS="idU" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    IF @numrows = 1
    BEGIN
      SELECT @insidU = inserted.idU
        FROM inserted
      UPDATE Courier
      SET
        /*  %JoinFKPK(Courier,@ins," = ",",") */
        Courier.idU = @insidU
      FROM Courier,inserted,deleted
      WHERE
        /*  %JoinFKPK(Courier,deleted," = "," AND") */
        Courier.idU = deleted.idU
    END
    ELSE
    BEGIN
      SELECT @errno = 30006,
             @errmsg = 'Cannot cascade dbUser update because more than one row has been affected.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* dbUser  Admin on parent update cascade */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="dbUser"
    CHILD_OWNER="", CHILD_TABLE="Admin"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_17", FK_COLUMNS="idU" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    IF @numrows = 1
    BEGIN
      SELECT @insidU = inserted.idU
        FROM inserted
      UPDATE Admin
      SET
        /*  %JoinFKPK(Admin,@ins," = ",",") */
        Admin.idU = @insidU
      FROM Admin,inserted,deleted
      WHERE
        /*  %JoinFKPK(Admin,deleted," = "," AND") */
        Admin.idU = deleted.idU
    END
    ELSE
    BEGIN
      SELECT @errno = 30006,
             @errmsg = 'Cannot cascade dbUser update because more than one row has been affected.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_District ON District FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on District */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* District  Package on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="0001e946", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_14", FK_COLUMNS="idSrc" */
    IF EXISTS (
      SELECT * FROM deleted,Package
      WHERE
        /*  %JoinFKPK(Package,deleted," = "," AND") */
        Package.idSrc = deleted.idD
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete District because Package exists.'
      GOTO error
    END

    /* erwin Builtin Trigger */
    /* District  Package on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_13", FK_COLUMNS="idDest" */
    IF EXISTS (
      SELECT * FROM deleted,Package
      WHERE
        /*  %JoinFKPK(Package,deleted," = "," AND") */
        Package.idDest = deleted.idD
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete District because Package exists.'
      GOTO error
    END


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_District ON District FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on District */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidD integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* District  Package on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0003408f", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_14", FK_COLUMNS="idSrc" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idD)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Package
      WHERE
        /*  %JoinFKPK(Package,deleted," = "," AND") */
        Package.idSrc = deleted.idD
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update District because Package exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* District  Package on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_13", FK_COLUMNS="idDest" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idD)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Package
      WHERE
        /*  %JoinFKPK(Package,deleted," = "," AND") */
        Package.idDest = deleted.idD
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update District because Package exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* City  District on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="City"
    CHILD_OWNER="", CHILD_TABLE="District"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_12", FK_COLUMNS="idC" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idC)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,City
        WHERE
          /* %JoinFKPK(inserted,City) */
          inserted.idC = City.idC
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update District because City does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_Package ON Package FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on Package */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* Package  TransportOffer on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="0002fe7b", PARENT_OWNER="", PARENT_TABLE="Package"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_21", FK_COLUMNS="idP" */
    DELETE TransportOffer
      FROM TransportOffer,deleted
      WHERE
        /*  %JoinFKPK(TransportOffer,deleted," = "," AND") */
        TransportOffer.idP = deleted.idP

    /* erwin Builtin Trigger */
    /* District  Package on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_14", FK_COLUMNS="idSrc" */
    IF EXISTS (SELECT * FROM deleted,District
      WHERE
        /* %JoinFKPK(deleted,District," = "," AND") */
        deleted.idSrc = District.idD AND
        NOT EXISTS (
          SELECT * FROM Package
          WHERE
            /* %JoinFKPK(Package,District," = "," AND") */
            Package.idSrc = District.idD
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Package because District exists.'
      GOTO error
    END

    /* erwin Builtin Trigger */
    /* District  Package on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_13", FK_COLUMNS="idDest" */
    IF EXISTS (SELECT * FROM deleted,District
      WHERE
        /* %JoinFKPK(deleted,District," = "," AND") */
        deleted.idDest = District.idD AND
        NOT EXISTS (
          SELECT * FROM Package
          WHERE
            /* %JoinFKPK(Package,District," = "," AND") */
            Package.idDest = District.idD
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last Package because District exists.'
      GOTO error
    END


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_Package ON Package FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on Package */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidP integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* Package  TransportOffer on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0004f913", PARENT_OWNER="", PARENT_TABLE="Package"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_21", FK_COLUMNS="idP" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idP)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,TransportOffer
      WHERE
        /*  %JoinFKPK(TransportOffer,deleted," = "," AND") */
        TransportOffer.idP = deleted.idP
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Package because TransportOffer exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* Courier  Package on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_19", FK_COLUMNS="idU" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Courier
        WHERE
          /* %JoinFKPK(inserted,Courier) */
          inserted.idU = Courier.idU
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    select @nullcnt = count(*) from inserted where
      inserted.idU IS NULL
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Package because Courier does not exist.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* District  Package on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_14", FK_COLUMNS="idSrc" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idSrc)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,District
        WHERE
          /* %JoinFKPK(inserted,District) */
          inserted.idSrc = District.idD
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Package because District does not exist.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* District  Package on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="District"
    CHILD_OWNER="", CHILD_TABLE="Package"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_13", FK_COLUMNS="idDest" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idDest)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,District
        WHERE
          /* %JoinFKPK(inserted,District) */
          inserted.idDest = District.idD
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update Package because District does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_TransportOffer ON TransportOffer FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on TransportOffer */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* TransportOffer  Approved on parent delete no action */
    /* ERWIN_RELATION:CHECKSUM="00036618", PARENT_OWNER="", PARENT_TABLE="TransportOffer"
    CHILD_OWNER="", CHILD_TABLE="Approved"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="idP""idU" */
    IF EXISTS (
      SELECT * FROM deleted,Approved
      WHERE
        /*  %JoinFKPK(Approved,deleted," = "," AND") */
        Approved.idP = deleted.idP AND
        Approved.idU = deleted.idU
    )
    BEGIN
      SELECT @errno  = 30001,
             @errmsg = 'Cannot delete TransportOffer because Approved exists.'
      GOTO error
    END

    /* erwin Builtin Trigger */
    /* Courier  TransportOffer on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="idU" */
    IF EXISTS (SELECT * FROM deleted,Courier
      WHERE
        /* %JoinFKPK(deleted,Courier," = "," AND") */
        deleted.idU = Courier.idU AND
        NOT EXISTS (
          SELECT * FROM TransportOffer
          WHERE
            /* %JoinFKPK(TransportOffer,Courier," = "," AND") */
            TransportOffer.idU = Courier.idU
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last TransportOffer because Courier exists.'
      GOTO error
    END

    /* erwin Builtin Trigger */
    /* Package  TransportOffer on child delete no action */
    /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Package"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_21", FK_COLUMNS="idP" */
    IF EXISTS (SELECT * FROM deleted,Package
      WHERE
        /* %JoinFKPK(deleted,Package," = "," AND") */
        deleted.idP = Package.idP AND
        NOT EXISTS (
          SELECT * FROM TransportOffer
          WHERE
            /* %JoinFKPK(TransportOffer,Package," = "," AND") */
            TransportOffer.idP = Package.idP
        )
    )
    BEGIN
      SELECT @errno  = 30010,
             @errmsg = 'Cannot delete last TransportOffer because Package exists.'
      GOTO error
    END


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_TransportOffer ON TransportOffer FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on TransportOffer */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidP integer, 
           @insidU integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* TransportOffer  Approved on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="0003b718", PARENT_OWNER="", PARENT_TABLE="TransportOffer"
    CHILD_OWNER="", CHILD_TABLE="Approved"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_23", FK_COLUMNS="idP""idU" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idP) OR
    UPDATE(idU)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Approved
      WHERE
        /*  %JoinFKPK(Approved,deleted," = "," AND") */
        Approved.idP = deleted.idP AND
        Approved.idU = deleted.idU
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update TransportOffer because Approved exists.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* Courier  TransportOffer on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Courier"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_22", FK_COLUMNS="idU" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idU)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Courier
        WHERE
          /* %JoinFKPK(inserted,Courier) */
          inserted.idU = Courier.idU
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update TransportOffer because Courier does not exist.'
      GOTO error
    END
  END

  /* erwin Builtin Trigger */
  /* Package  TransportOffer on child update no action */
  /* ERWIN_RELATION:CHECKSUM="00000000", PARENT_OWNER="", PARENT_TABLE="Package"
    CHILD_OWNER="", CHILD_TABLE="TransportOffer"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_21", FK_COLUMNS="idP" */
  IF
    /* %ChildFK(" OR",UPDATE) */
    UPDATE(idP)
  BEGIN
    SELECT @nullcnt = 0
    SELECT @validcnt = count(*)
      FROM inserted,Package
        WHERE
          /* %JoinFKPK(inserted,Package) */
          inserted.idP = Package.idP
    /* %NotnullFK(inserted," IS NULL","select @nullcnt = count(*) from inserted where"," AND") */
    
    IF @validcnt + @nullcnt != @numrows
    BEGIN
      SELECT @errno  = 30007,
             @errmsg = 'Cannot update TransportOffer because Package does not exist.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go




CREATE TRIGGER tD_Vehicle ON Vehicle FOR DELETE AS
/* erwin Builtin Trigger */
/* DELETE trigger on Vehicle */
BEGIN
  DECLARE  @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)
    /* erwin Builtin Trigger */
    /* Vehicle  Courier on parent delete cascade */
    /* ERWIN_RELATION:CHECKSUM="0000d367", PARENT_OWNER="", PARENT_TABLE="Vehicle"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_4", FK_COLUMNS="idV" */
    DELETE Courier
      FROM Courier,deleted
      WHERE
        /*  %JoinFKPK(Courier,deleted," = "," AND") */
        Courier.idV = deleted.idV


    /* erwin Builtin Trigger */
    RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


CREATE TRIGGER tU_Vehicle ON Vehicle FOR UPDATE AS
/* erwin Builtin Trigger */
/* UPDATE trigger on Vehicle */
BEGIN
  DECLARE  @numrows int,
           @nullcnt int,
           @validcnt int,
           @insidV integer,
           @errno   int,
           @severity int,
           @state    int,
           @errmsg  varchar(255)

  SELECT @numrows = @@rowcount
  /* erwin Builtin Trigger */
  /* Vehicle  Courier on parent update no action */
  /* ERWIN_RELATION:CHECKSUM="000112a3", PARENT_OWNER="", PARENT_TABLE="Vehicle"
    CHILD_OWNER="", CHILD_TABLE="Courier"
    P2C_VERB_PHRASE="", C2P_VERB_PHRASE="", 
    FK_CONSTRAINT="R_4", FK_COLUMNS="idV" */
  IF
    /* %ParentPK(" OR",UPDATE) */
    UPDATE(idV)
  BEGIN
    IF EXISTS (
      SELECT * FROM deleted,Courier
      WHERE
        /*  %JoinFKPK(Courier,deleted," = "," AND") */
        Courier.idV = deleted.idV
    )
    BEGIN
      SELECT @errno  = 30005,
             @errmsg = 'Cannot update Vehicle because Courier exists.'
      GOTO error
    END
  END


  /* erwin Builtin Trigger */
  RETURN
error:
   RAISERROR (@errmsg, -- Message text.
              @severity, -- Severity (0~25).
              @state) -- State (0~255).
    rollback transaction
END

go


