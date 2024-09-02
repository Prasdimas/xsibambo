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


DROP PROCEDURE `sp_sales_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_sales_save` (IN `id` int, IN `hdata` text, IN `uid` int)
BEGIN

DECLARE sales_id INTEGER;
DECLARE sales_date DATE;
DECLARE sales_number VARCHAR(25);
DECLARE sales_desc TEXT;
DECLARE sales_customer INTEGER;
DECLARE sales_start_date DATE;
DECLARE sales_duration INTEGER;
DECLARE sales_end_date DATE;
DECLARE sales_total DOUBLE;
DECLARE sales_attachment VARCHAR(255);
DECLARE sales_employee INTEGER;
DECLARE sales_term INTEGER;
DECLARE sales_packet INTEGER;
DECLARE sales_PPN VARCHAR(1);
DECLARE sales_PPNValue INTEGER;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
GET DIAGNOSTICS CONDITION 1
@p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
SELECT "ERR" as status, @p1 as data  , @p2 as message, @tb as table_name;
ROLLBACK;
END;

DECLARE EXIT HANDLER FOR SQLWARNING
BEGIN
GET DIAGNOSTICS CONDITION 1
@p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
SELECT "ERR" as status, @p1 as data  , @p2 as message, @tb as table_name;
ROLLBACK;
END;

START TRANSACTION;

SET sales_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_date"));
SET sales_packet = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_packet"));
SET sales_number = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.date"));
SET sales_desc = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_desc"));
SET sales_customer = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.customer_id"));
SET sales_start_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_startdate"));
SET sales_duration = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_duration"));
SET sales_end_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_enddate"));
SET sales_total = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_total"));
SET sales_attachment = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_attachment"));
SET sales_employee = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_id"));
SET sales_term = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.term_id"));
SET sales_PPN = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_PPN"));
SET sales_PPNValue = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.sales_PPNValue"));

IF id = 0 THEN

    SET sales_number = (SELECT fn_numbering('SALES'));

    INSERT INTO l_sales(
        L_SalesDate, 
        L_SalesNumber, 
        L_SalesDesc, 
        L_SalesM_CustomerID,
        L_SalesStartDate,
        L_SalesDuration,
        L_SalesEndDate,
        L_SalesTotal,
        L_SalesAttachment,
        L_SalesM_EmployeeID,
        L_SalesM_TermID,
        L_SalesPPN,        
        L_SalesPPNValue,
	L_SalesM_SalesPacketID
    ) SELECT sales_date, sales_number, sales_desc, sales_customer, sales_start_date,
        sales_duration, sales_end_date, sales_total, sales_attachment, sales_employee, sales_term,sales_PPN,sales_PPNValue, sales_packet;

    SET id = (SELECT LAST_INSERT_ID());

ELSE

    UPDATE l_sales
    SET L_SalesDate = sales_date, L_SalesDesc = sales_desc, L_SalesStartDate = sales_start_date, 
        L_SalesDuration = sales_duration, L_SalesEndDate = sales_end_date, L_SalesTotal = sales_total,
        L_SalesAttachment = sales_attachment, L_SalesM_EmployeeID = sales_employee, L_SalesM_TermID = sales_term,
		L_SalesM_SalesPacketID = sales_packet,L_SalesPPN = sales_PPN, L_SalesPPNValue = sales_PPNValue
    WHERE L_SalesID = id;

    SET sales_number = (SELECT L_SalesNumber FROM l_sales WHERE L_SalesID = id);

END IF;

SELECT "OK" as status, JSON_OBJECT("sales_id", id, "sales_number", sales_number) as data;
COMMIT;

END;;
DELIMITER ;