﻿USE [DormitoryManagement]
GO

-- Tạo view tỉnh
CREATE OR ALTER VIEW [V_PROVINCE] AS
	SELECT 
		P.PROVINCE_ID,
		CASE
			WHEN P.PROVINCE_TYPE = 'C' THEN CONCAT(N'Thành phố ', P.PROVINCE_NAME)
			ELSE CONCAT(N'Tỉnh ', P.PROVINCE_NAME)
		END AS PROVINCE_NAME ,
		P.PROVINCE_TYPE
	FROM [dbo].[PROVINCE] AS P
GO

-- Tạo view huyện
CREATE OR ALTER VIEW [V_DISTRICT] AS
	SELECT 
		D.DISTRICT_ID,
		CASE
			WHEN D.DISTRICT_TYPE = 'C' THEN CONCAT(N'Thành phố ', D.DISTRICT_NAME)
			WHEN D.DISTRICT_TYPE = 'D' THEN CONCAT(N'Quận ', D.DISTRICT_NAME)
			WHEN D.DISTRICT_TYPE = 'T' THEN CONCAT(N'Thị xã ', D.DISTRICT_NAME)
			ELSE CONCAT(N'Huyện ', D.DISTRICT_NAME)
		END AS DISTRICT_NAME,
		D.PROVINCE_ID,
		D.DISTRICT_TYPE
	FROM [dbo].[DISTRICT] AS D
GO

-- Tạo view xã, phường
CREATE OR ALTER VIEW [V_COMMUNE] AS
	SELECT 
		C.COMMUNE_ID,
		CASE
			WHEN C.COMMUNE_TYPE = 'T' THEN CONCAT(N'Thị trấn ', C.COMMUNE_NAME)
			WHEN C.COMMUNE_TYPE = 'W' THEN CONCAT(N'Phường ', C.COMMUNE_NAME)
			ELSE CONCAT(N'Xã ', C.COMMUNE_NAME)
		END AS COMMUNE_NAME,
		C.COMMUNE_TYPE,
		C.PRIORITY,
		C.DISTRICT_ID
	FROM [dbo].[COMMUNE] AS C
GO

-- Tạo view địa chỉ
CREATE OR ALTER VIEW [V_ADDRESS] AS
	SELECT A.ADDRESS_ID, A.STREET, P.PROVINCE_NAME, D.DISTRICT_NAME, C.COMMUNE_NAME
	FROM [dbo].[ADDRESS] AS A
		INNER JOIN [dbo].[V_PROVINCE] AS P ON P.PROVINCE_ID = A.PROVINCE_ID
		INNER JOIN [dbo].[V_DISTRICT] AS D ON D.DISTRICT_ID = A.DISTRICT_ID
		INNER JOIN [dbo].[V_COMMUNE] AS C ON C.COMMUNE_ID = A.COMMNUNE_ID
GO
-- Tạo view địa chỉ general
CREATE OR ALTER VIEW [V_ADDRESSGENERAL] AS
	SELECT A.ADDRESS_ID, A.STREET, P.PROVINCE_NAME, D.DISTRICT_NAME, C.COMMUNE_NAME
	FROM [dbo].[ADDRESS] AS A
		INNER JOIN [dbo].[PROVINCE] AS P ON P.PROVINCE_ID = A.PROVINCE_ID
		INNER JOIN [dbo].[DISTRICT] AS D ON D.DISTRICT_ID = A.DISTRICT_ID
		INNER JOIN [dbo].[COMMUNE] AS C ON C.COMMUNE_ID = A.COMMNUNE_ID
GO
-- Tạo view nhân viên
CREATE OR ALTER VIEW [V_EMPLOYEE] AS
	SELECT 
		U.[USER_ID], 
		U.LAST_NAME, 
		U.FIRST_NAME, 
		CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS [FULL_NAME],
		U.DOB,
		U.GENDER,
		U.SSN,

		A.STREET,
		A.PROVINCE_NAME,
		A.DISTRICT_NAME,
		A.COMMUNE_NAME,

		U.PHONE_NUMBER_1,
		U.PHONE_NUMBER_2,
		U.EMAIL,

		E.[START_DATE],
		E.SALARY

	FROM [dbo].[USER] AS U 
		INNER JOIN [dbo].[V_ADDRESSGENERAL] AS A ON A.ADDRESS_ID = U.ADDRESS_ID
		INNER JOIN [dbo].[EMPLOYEE] AS E ON E.[USER_ID] = U.[USER_ID]
GO

-- Tạo view sinh viên
CREATE OR ALTER VIEW [V_STUDENT] AS
	SELECT 
		U.[USER_ID], 
		U.LAST_NAME, 
		U.FIRST_NAME, 
		CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS [FULL_NAME],
		U.DOB,
		U.GENDER,
		U.SSN,

		A.STREET,
		A.PROVINCE_NAME,
		A.DISTRICT_NAME,
		A.COMMUNE_NAME,

		U.PHONE_NUMBER_1,
		U.PHONE_NUMBER_2,
		U.EMAIL,

		S.STUDENT_ID,
		C.COLLEGE_NAME,
		S.FACULTY,
		S.MAJORS

	FROM [dbo].[USER] AS U 
		INNER JOIN [dbo].[V_ADDRESSGENERAL] AS A ON A.ADDRESS_ID = U.ADDRESS_ID
		INNER JOIN [dbo].[STUDENT] AS S ON S.[USER_ID] = U.[USER_ID]
		INNER JOIN [dbo].[COLLEGE] AS C ON C.COLLEGE_ID = S.COLLEGE_ID
GO

-- Tạo view sinh viên general
CREATE OR ALTER VIEW [V_STUDENTGENERAL] AS
	SELECT 
		U.[USER_ID],  
		CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS [FULL_NAME],
		U.DOB,
		U.GENDER,
		U.SSN,


		U.PHONE_NUMBER_1,
		U.EMAIL,

		S.STUDENT_ID,
		C.COLLEGE_NAME

	FROM [dbo].[USER] AS U 
		INNER JOIN [dbo].[V_ADDRESS] AS A ON A.ADDRESS_ID = U.ADDRESS_ID
		INNER JOIN [dbo].[STUDENT] AS S ON S.[USER_ID] = U.[USER_ID]
		INNER JOIN [dbo].[COLLEGE] AS C ON C.COLLEGE_ID = S.COLLEGE_ID
GO

-- Tạo view room regestration
CREATE OR ALTER VIEW [V_ROOM_REGISTRATION] AS
	SELECT 
		RR.ROOM_REGISTRATION_ID AS [Id],
		
		S.SECTOR_NAME AS [Building],
		R.ROOM_ID AS [Room],
		STU.STUDENT_ID AS [Student Id],
		STU.FULL_NAME AS [Student Name],

		E.USER_ID AS [Employee Id],
		E.FULL_NAME AS [Employee Name],

		RR.START_DATE AS [Start date],
		RR.DURATION AS [Duration],
		RR.STATUS AS [STATUS]
		
	FROM [dbo].[ROOM_REGISTRATION] AS RR
		INNER JOIN [dbo].[SECTOR] AS S ON S.SECTOR_ID = RR.SECTOR_ID
		INNER JOIN [dbo].[ROOM] AS R ON R.ROOM_ID = RR.ROOM_ID
		INNER JOIN (
			SELECT U.SSN, S.STUDENT_ID, CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS FULL_NAME
			FROM [dbo].[STUDENT] AS S 
				INNER JOIN [dbo].[USER] AS U ON U.[USER_ID] = S.[USER_ID]
 		) AS STU ON STU.SSN = RR.SSN
		INNER JOIN (
			SELECT E.[USER_ID], CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS FULL_NAME
			FROM [dbo].[EMPLOYEE] AS E 
				INNER JOIN [dbo].[USER] AS U ON U.[USER_ID] = E.[USER_ID]
		) AS E ON E.USER_ID = RR.EMPLOYEE_ID
GO

-- View bill
CREATE OR ALTER VIEW [V_BILL] AS
	SELECT
		B.BILL_ID AS [Bill Id],
		B.CREATE_TIME AS [Create time],
		B.EMPLOYEE_ID AS [Employee Id],
		CONCAT(U.LAST_NAME, ' ', U.FIRST_NAME) AS [Employee name],
		SEC.SECTOR_NAME AS [Sector],
		R.ROOM_ID AS [Room],
		B.[MONTH] AS [Month],
		B.[YEAR] AS [Year],
		B.TOTAL AS [Total],
		B.[STATUS] AS [Status]
	FROM [dbo].[BILL] AS B
		INNER JOIN [dbo].[SECTOR] AS SEC ON SEC.SECTOR_ID = B.SECTOR_ID
		INNER JOIN [dbo].[USER] AS U ON U.USER_ID = B.EMPLOYEE_ID
		INNER JOIN dbo.ROOM AS R ON R.ROOM_ID = B.ROOM_ID
GO

-- View Service Unit
CREATE OR ALTER VIEW [V_SERVICE_UNIT] AS
	SELECT dbo.SERVICE.SERVICE_ID, dbo.SERVICE.SERVICE_NAME, dbo.SERVICE.PRICE_PER_UNIT, dbo.UNIT.UNIT_NAME, dbo.SERVICE.STATUS
	FROM     dbo.SERVICE INNER JOIN
					dbo.UNIT ON dbo.UNIT.UNIT_ID = dbo.SERVICE.UNIT_ID
GO
--
CREATE OR ALTER VIEW V_GetRoomSectorType
AS
	SELECT dbo.ROOM.ROOM_ID, dbo.SECTOR.SECTOR_NAME, dbo.ROOM_TYPE.ROOM_TYPE_ID, dbo.ROOM_TYPE.ROOM_TYPE_NAME, dbo.ROOM_TYPE.PRICE, dbo.ROOM_TYPE.AREA, dbo.ROOM_TYPE.CAPACITY
	FROM dbo.ROOM INNER JOIN dbo.SECTOR ON SECTOR.SECTOR_ID = ROOM.SECTOR_ID INNER JOIN dbo.ROOM_TYPE ON ROOM_TYPE.ROOM_TYPE_ID = ROOM.ROOM_TYPE_ID
GO
