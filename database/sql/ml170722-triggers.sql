-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luka Matovic
-- Create date: 12.07.2021
-- Description:	Delets all unaccepted offers for package
-- =============================================
CREATE TRIGGER [dbo].[TR_TransportOffer_clearOffers]
   ON  [dbo].[TransportOffer] 
   AFTER UPDATE
AS 
BEGIN
	if @@ROWCOUNT=0
		RETURN

	delete TransportOffer
	where idP=(select i.idP from inserted i) and accepted=0

END
GO
