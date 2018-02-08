USE [TestTelemetry]
GO
/****** Object:  Table [dbo].[MasterDiskData]    Script Date: 2/8/2018 9:11:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterDiskData](
	[SubscriptionId] [nvarchar](240) NULL,
	[LabUId] [nvarchar](240) NULL,
	[LabName] [nvarchar](240) NULL,
	[LabResourceId] [nvarchar](240) NULL,
	[ResourceGroupName] [nvarchar](240) NULL,
	[ResourceId] [nvarchar](240) NULL,
	[ResourceUId] [nvarchar](240) NULL,
	[Name] [nvarchar](240) NULL,
	[CreatedTime] [nvarchar](240) NULL,
	[DeletedDate] [nvarchar](240) NULL,
	[ResourceStatus] [nvarchar](240) NULL,
	[DiskBlobName] [nvarchar](240) NULL,
	[DiskSizeGB] [nvarchar](240) NULL,
	[DiskType] [nvarchar](240) NULL,
	[LeasedByVmId] [nvarchar](240) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[MasterDisks]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MasterDisks] AS
Select *, REPLACE(ResourceUId,'"','') AS VMUID, TRY_CAST(REPLACE(CreatedTime,'"','') AS datetime ) AS CreatedDateTime, TRY_CAST(REPLACE(DeletedDate,'"','') AS datetime )  AS DeletedDateTime FROM MasterDiskData
GO
/****** Object:  Table [dbo].[MasterVMData]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterVMData](
	[SubscriptionId] [nvarchar](240) NULL,
	[LabUId] [nvarchar](240) NULL,
	[LabName] [nvarchar](240) NULL,
	[LabResourceId] [nvarchar](240) NULL,
	[ResourceGroupName] [nvarchar](240) NULL,
	[ResourceId] [nvarchar](240) NULL,
	[ResourceUId] [nvarchar](240) NULL,
	[Name] [nvarchar](240) NULL,
	[CreatedTime] [nvarchar](240) NULL,
	[DeletedDate] [nvarchar](240) NULL,
	[ResourceOwner] [nvarchar](240) NULL,
	[PricingTier] [nvarchar](240) NULL,
	[ResourceStatus] [nvarchar](240) NULL,
	[ComputeResourceId] [nvarchar](240) NULL,
	[Claimable] [nvarchar](240) NULL,
	[EnvironmentId] [nvarchar](240) NULL,
	[ExpirationDate] [nvarchar](240) NULL,
	[GalleryImageReferenceVersion] [nvarchar](240) NULL,
	[GalleryImageReferenceOffer] [nvarchar](240) NULL,
	[GalleryImageReferencePublisher] [nvarchar](240) NULL,
	[GalleryImageReferenceSku] [nvarchar](240) NULL,
	[GalleryImageReferenceOsType] [nvarchar](240) NULL,
	[CustomImageId] [nvarchar](240) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[supportDistinctCreates]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[supportDistinctCreates] AS
SELECT [ResourceUId], MIN(CreatedTime) AS CreatedDT
  FROM [dbo].[MasterVMData]
  GROUP BY ResourceUID
GO
/****** Object:  View [dbo].[supportDistinctDeletes]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[supportDistinctDeletes] AS
SELECT [ResourceUId], MAX(DeletedDate) AS DeletedDT
  FROM [dbo].[MasterVMData]
  WHERE DeletedDate <> ''
  GROUP BY ResourceUId
GO
/****** Object:  View [dbo].[MasterVMs]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create view [dbo].[MasterVMs] as
SELECT T1.[SubscriptionId]
      ,T1.[LabUId]
      ,T1.[LabName]
      ,T1.[LabResourceId]
      ,T1.[ResourceGroupName]
      ,T1.[ResourceId]
      ,REPLACE(T1.[ResourceUId],'"','') AS ResourceUId
      ,T1.[Name]
      ,TRY_CAST(REPLACE(VCreate.[CreatedDT],'"','') AS datetime ) AS CreatedDateTime
      ,TRY_CAST(REPLACE(VDelete.[DeletedDT],'"','') AS datetime ) AS DeletedDateTime
      ,T1.[ResourceOwner]
      ,T1.[PricingTier]
      ,T1.[ResourceStatus]
      ,T1.[ComputeResourceId]
      ,T1.[Claimable]
      ,T1.[EnvironmentId]
      ,TRY_CAST(REPLACE(T1.[ExpirationDate],'"','') AS datetime )  AS ExpirationDateTime
      ,T1.[GalleryImageReferenceVersion]
      ,T1.[GalleryImageReferenceOffer]
      ,T1.[GalleryImageReferencePublisher]
      ,T1.[GalleryImageReferenceSku]
      ,T1.[GalleryImageReferenceOsType]
      ,T1.[CustomImageId]
	  ,IIF (T1.[CustomImageId] <> '',SUBSTRING(T1.[CustomImageId],(CHARINDEX('customimages',T1.[CustomImageId]) + 13),((LEN(T1.[CustomImageId]) - (CHARINDEX('customimages',T1.[CustomImageId]) + 12)))),T1.[GalleryImageReferenceOsType] + ' ' + T1.[GalleryImageReferencePublisher] + ' ' + T1.[GalleryImageReferenceSku] ) AS FriendlyImage
  FROM [dbo].[MasterVMData] T1, [dbo].[supportDistinctDeletes] VDelete, [dbo].[supportDistinctCreates] VCreate
  WHERE T1.ResourceUId = VDelete.ResourceUId AND T1.DeletedDate = VDelete.DeletedDT AND T1.ResourceUId = VCreate.ResourceUId

 Union
 /* Select all Creates w/o deletes */
  SELECT T1.[SubscriptionId]
      ,T1.[LabUId]
      ,T1.[LabName]
      ,T1.[LabResourceId]
      ,T1.[ResourceGroupName]
      ,T1.[ResourceId]
      ,REPLACE(T1.[ResourceUId],'"','') AS ResourceUId
      ,T1.[Name]
      ,TRY_CAST(REPLACE(T1.[CreatedTime],'"','') AS datetime ) AS CreatedDateTime
      ,TRY_CAST(REPLACE(T1.[DeletedDate],'"','') AS datetime ) AS DeletedDateTime
      ,T1.[ResourceOwner]
      ,T1.[PricingTier]
      ,T1.[ResourceStatus]
      ,T1.[ComputeResourceId]
      ,T1.[Claimable]
      ,T1.[EnvironmentId]
      ,TRY_CAST(REPLACE(T1.[ExpirationDate],'"','') AS datetime )  AS ExpirationDateTime
      ,T1.[GalleryImageReferenceVersion]
      ,T1.[GalleryImageReferenceOffer]
      ,T1.[GalleryImageReferencePublisher]
      ,T1.[GalleryImageReferenceSku]
      ,T1.[GalleryImageReferenceOsType]
      ,T1.[CustomImageId]
	  ,IIF (T1.[CustomImageId] <> '',SUBSTRING(T1.[CustomImageId],(CHARINDEX('customimages',T1.[CustomImageId]) + 13),((LEN(T1.[CustomImageId]) - (CHARINDEX('customimages',T1.[CustomImageId]) + 12)))),T1.[GalleryImageReferenceOsType] + ' ' + T1.[GalleryImageReferencePublisher] + ' ' + T1.[GalleryImageReferenceSku] ) AS FriendlyImage
  FROM [dbo].[MasterVMData] T1
  WHERE T1.DeletedDate = '' and T1.ResourceUId not in (Select ResourceUId from supportDistinctDeletes)
GO
/****** Object:  View [dbo].[supportDistinctAvailable]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[supportDistinctAvailable] AS
SELECT * 
  FROM [dbo].[supportDistinctCreates]
  WHERE [dbo].[supportDistinctCreates].[ResourceUId] NOT IN (Select [ResourceUId] from [dbo].[supportDistinctDeletes])
GO
/****** Object:  View [dbo].[LinkedDisk]    Script Date: 2/8/2018 9:11:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LinkedDisk] AS
Select Disks.*, VMs.ResourceOwner, VMs.ResourceUId AS VMResourceUId from [dbo].[MasterDisks] Disks, [dbo].[MasterVMs] VMs
Where Disks.[LeasedByVMId] = VMs.[ResourceId] AND VMs.[ResourceUId] IN (Select ResourceUId FROM [dbo].[supportDistinctAvailable])
GO
