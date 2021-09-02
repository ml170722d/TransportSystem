USE TransportSystem
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matovic
-- Create date: 11-07-2021
-- Description:	Emptys out whole database
-- =============================================
CREATE PROCEDURE sp_emptyDB
AS
BEGIN
	
	EXEC sp_MSforeachtable 'DISABLE TRIGGER ALL ON ?'
	EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
	EXEC sp_MSforeachtable 'DELETE FROM ?'
	EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
	EXEC sp_MSforeachtable 'ENABLE TRIGGER ALL ON ?'

END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matoivc
-- Create date: 11.07.2021
-- Description:	Create new Courier
-- =============================================
CREATE PROCEDURE sp_newCourier 
	-- Add the parameters for the stored procedure here
	@username varchar(100) = '', 
	@licencePlate varchar(100) = ''
AS
BEGIN
	
	declare @cnt int;

	set @cnt = (select COUNT(*)
				from Courier c
				where c.idV=(select v.idV from Vehicle v where v.licencePlate=@licencePlate)
					and c.status is not null);

	declare @res int = -1;
	if @cnt=0
	begin
		INSERT INTO [dbo].[Courier]
           ([idV], [status], [profit], [idU], [deliveredPackages])
		VALUES
           ((select idV from Vehicle where licencePlate=@licencePlate),0,0,
			(select idU from dbUser where username=@username), 0);

		set @res = @@ROWCOUNT;
		if @@ERROR<>0
		begin
			RETURN -2;
		end
	end

	RETURN @res;
END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matoivc
-- Create date: 11.07.2021
-- Description:	Create new Courier
-- =============================================
CREATE PROCEDURE sp_newCourierRequest 
	-- Add the parameters for the stored procedure here
	@username varchar(100) = '', 
	@licencePlate varchar(100) = ''
AS
BEGIN
	
	declare @cnt int;

	set @cnt = (select COUNT(*)
				from Courier c
				where c.idV=(select v.idV from Vehicle v where v.licencePlate=@licencePlate)
					and c.status is not null);

	declare @res int = -1;
	if @cnt=0
	begin
		INSERT INTO [dbo].[Courier]
           ([idV], [status], [profit], [idU], [deliveredPackages])
		VALUES
           ((select idV from Vehicle where licencePlate=@licencePlate),null,null,
			(select idU from dbUser where username=@username), null);

		set @res = @@ROWCOUNT;
		if @@ERROR<>0
		begin
			RETURN -2;
		end
	end

	RETURN @res;
END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matoivc
-- Create date: 11.07.2021
-- Description:	Updates TransferOffer and Package tables
-- =============================================
CREATE PROCEDURE sp_acceptOffer 
	-- Add the parameters for the stored procedure here
	@id int
AS
BEGIN
	
	update Package 
	set status=1, courier=(select idU from TransportOffer where idTO=@id)
	where idP=(select idP from TransportOffer where idTO=@id);
	
	declare @ret int=@@ROWCOUNT;
	if @ret=0
		RETURN -1;
	
	print @ret

	update TransportOffer set accepted=1 where idTO=@id;
	if @@ROWCOUNT=0
		RETURN -2;

	print @ret
	
	insert into Drive (idP, idU)
	values ((select p.idP from Package p 
			where p.idP=(select idP from TransportOffer where idTO=@id)),
			(select c.idU from Courier c 
			where c.idU=(select idU from TransportOffer where idTO=@id)));
	if @@ROWCOUNT=0
		RETURN -3;

	print @ret
	RETURN @ret;
END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matovic
-- Create date: 12.07.2021
-- Description:	Gets id of next package to be deliverd in drive
-- =============================================
CREATE PROCEDURE sp_getNextPackageID 
	-- Add the parameters for the stored procedure here
	@username varchar(100)
AS
BEGIN
	
	declare @id int;

	select @id = MIN(p.idP)
	from Package p join dbUser u on (p.courier=u.idU)
	where username=@username and status=2 

	if @id is null
		RETURN -1;

	update Package
	set status=3, deliveryTime=GETDATE()
	where idP=@id

	RETURN @id;

END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matovic
-- Create date: 12.07.2021
-- Description:	Gets id of next package to be deliverd in drive
-- =============================================
CREATE PROCEDURE sp_updateCourier
	-- Add the parameters for the stored procedure here
	@username varchar(100),
	@idP int,
	@fuelPrice int
AS
BEGIN
	
	declare @consumprion decimal(10,3), @idU int;
	declare @sum decimal(10,3), @cnt int;

	select @consumprion=v.consumption, @idU=c.idU
	from Vehicle v join Courier c on (v.idV=c.idV) join dbUser u on (c.idU=u.idU)
	where u.username=@username;

	select @sum=SUM(p.price), @cnt=COUNT(p.idP)
	from Drive d join dbUser u on (d.idU=u.idu) join Package p on (p.idP=d.idP)
	where u.idU=@idU and p.status=3

	declare @dist decimal(10,3);
	--exec sp_distance @idP, @dist out;
	exec @dist = sp_distance @idP;

	update Courier
	set profit=@sum - @consumprion*@dist*@fuelPrice,
		deliveredPackages=@cnt
	where idU=@idU;

	RETURN @@ROWCOUNT;
END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matovic
-- Create date: 12.07.2021
-- Description:	Get distance from source to destination for package
-- =============================================
CREATE PROCEDURE sp_distance
	-- Add the parameters for the stored procedure here
	@idP int
AS
BEGIN
	declare @profit decimal(10,3), @dist decimal(10,3);

	declare @x1 int, @y1 int;
	declare @x2 int, @y2 int;
	declare @tmp1 decimal(10,3), @tmp2 decimal(10,3);
	select @x1=ds.X, @y1=ds.Y, @x2=dd.X, @y2=dd.Y
	from Package p join District ds on (p.idSrc=ds.idD) join District dd on (p.idDest=dd.idD) 
	where p.idP=@idP

	set @tmp1 = POWER(@x1-@x2,2);
	print '-----'
	print @tmp1
	set @tmp2 = POWER(@y1-@y2,2);
	print @tmp2
	print '-----'

	set @dist = SQRT(@tmp1+@tmp2);

	RETURN @dist;
END
GO
