-- Adminer 4.8.1 MySQL 8.3.0 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `l_sales`;
CREATE TABLE `l_sales` (
  `L_SalesID` int NOT NULL AUTO_INCREMENT,
  `L_SalesDate` date DEFAULT NULL,
  `L_SalesNumber` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `L_SalesM_CustomerID` int NOT NULL DEFAULT '0',
  `L_SalesM_SalesPacketID` int NOT NULL DEFAULT '0',
  `L_SalesM_EmployeeID` int NOT NULL DEFAULT '0',
  `L_SalesDesc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `L_SalesStartDate` date DEFAULT NULL,
  `L_SalesDuration` double NOT NULL DEFAULT '0',
  `L_SalesEndDate` date DEFAULT NULL,
  `L_SalesPPN` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'N',
  `L_SalesPPNValue` double NOT NULL DEFAULT '0',
  `L_SalesTotal` double NOT NULL DEFAULT '0',
  `L_SalesM_TermID` int NOT NULL DEFAULT '0',
  `L_SalesAttachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `L_SalesP_ProjectID` int NOT NULL DEFAULT '0',
  `L_SalesIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  `L_SalesCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `L_SalesLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`L_SalesID`),
  KEY `L_SalesDate` (`L_SalesDate`),
  KEY `L_SalesNumber` (`L_SalesNumber`),
  KEY `L_SalesM_CustomerID` (`L_SalesM_CustomerID`),
  KEY `L_SalesM_EmployeeID` (`L_SalesM_EmployeeID`),
  KEY `L_SalesStartDate` (`L_SalesStartDate`),
  KEY `L_SalesDuration` (`L_SalesDuration`),
  KEY `L_SalesEndDate` (`L_SalesEndDate`),
  KEY `L_SalesTotal` (`L_SalesTotal`),
  KEY `L_SalesPPN` (`L_SalesPPN`),
  KEY `L_SalesPPNValue` (`L_SalesPPNValue`),
  KEY `L_SalesM_TermID` (`L_SalesM_TermID`),
  KEY `L_SalesIsActive` (`L_SalesIsActive`),
  KEY `L_SalesP_ProjectID` (`L_SalesP_ProjectID`),
  KEY `L_SalesM_SalesPacketID` (`L_SalesM_SalesPacketID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


DROP TABLE IF EXISTS `p_project`;
CREATE TABLE `p_project` (
  `P_ProjectID` int NOT NULL AUTO_INCREMENT,
  `P_ProjectNumber` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `P_ProjectDate` date DEFAULT NULL,
  `P_ProjectDuration` int NOT NULL DEFAULT '0',
  `P_ProjectM_CustomerID` int NOT NULL DEFAULT '0',
  `P_ProjectL_SalesID` int NOT NULL DEFAULT '0',
  `P_ProjectAddress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `P_ProjectM_CityID` int NOT NULL DEFAULT '0',
  `P_ProjectM_DistrictID` int NOT NULL DEFAULT '0',
  `P_ProjectTargetDate` date DEFAULT NULL,
  `P_ProjectProgress` double NOT NULL DEFAULT '0',
  `P_ProjectNote` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `P_ProjectM_EmployeeID` int NOT NULL DEFAULT '0',
  `P_ProjectM_TimelineID` int NOT NULL DEFAULT '0',
  `P_ProjectDone` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'N',
  `P_ProjectDoneDate` date DEFAULT NULL,
  `P_ProjectDelay` int NOT NULL DEFAULT '0',
  `P_ProjectMd5` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `P_ProjectIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  `P_ProjectCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `P_ProjectLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`P_ProjectID`),
  KEY `P_ProjectM_CityID` (`P_ProjectM_CityID`),
  KEY `P_ProjectM_DistrictID` (`P_ProjectM_DistrictID`),
  KEY `P_ProjectDate` (`P_ProjectDate`),
  KEY `P_ProjectM_CustomerID` (`P_ProjectM_CustomerID`),
  KEY `P_ProjectTargetDate` (`P_ProjectTargetDate`),
  KEY `P_ProjectS_StaffID` (`P_ProjectM_EmployeeID`),
  KEY `P_ProjectM_StatusID` (`P_ProjectM_TimelineID`),
  KEY `P_ProjectIsActive` (`P_ProjectIsActive`),
  KEY `P_ProjectDone` (`P_ProjectDone`),
  KEY `P_ProjectDoneDate` (`P_ProjectDoneDate`),
  KEY `P_ProjectL_SalesID` (`P_ProjectL_SalesID`),
  KEY `P_ProjectNumber` (`P_ProjectNumber`),
  KEY `P_ProjectDuration` (`P_ProjectDuration`),
  KEY `P_ProjectProgress` (`P_ProjectProgress`),
  KEY `P_ProjectDelay` (`P_ProjectDelay`),
  KEY `P_ProjectMd5` (`P_ProjectMd5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 2024-08-21 09:51:26