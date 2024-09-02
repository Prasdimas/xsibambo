-- Adminer 4.8.1 MySQL 8.3.0 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DELIMITER ;;

DROP FUNCTION IF EXISTS `fn_numbering`;;
CREATE FUNCTION `fn_numbering`(`type` char(30)) RETURNS varchar(25) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
begin	declare number varchar(50);

   declare prefix varchar(50);

   declare prefix_date  varchar(50);

   declare sufix varchar(50);

   declare counter int;

   declare dgt int;

   declare rst varchar(5);

   declare udt datetime;





   select S_NumberingPrefix, S_NumberingPrefixDate, S_NumberingSufix, S_NumberingCounter, S_NumberingDigit, S_NumberingReset, 

   S_NumberingLastUpdated	

   into prefix, prefix_date, sufix, counter, dgt, rst, udt	

   from s_numbering	where S_NumberingType = type	for update;



   if rst = 'D' then

      if date_format(udt, '%Y-%m-%d') <> date_format(now(), '%Y-%m-%d') then

	 set counter = 1;

      end if;

   elseif rst = 'M' then

      if date_format(udt, '%Y-%m') <> date_format(now(), '%Y-%m') then

	 set counter = 1;

      end if;

   elseif rst = 'Y' then

      if date_format(udt, '%Y') <> date_format(now(), '%Y') then

	 set counter = 1;

      end if;

   end if;



   set number = '';



   

        if prefix is not null and prefix <> '' then

            set number = trim(prefix);

        end if;

        if prefix_date is not null and prefix_date <> '' then

            set number = concat(trim(number),date_format(now(),prefix_date));

        end if;



        if sufix is not null and sufix <> '' then

            set number = concat(trim(number),trim(sufix));

        end if;

    



    if type = "DO"

        OR type = "SO"

        OR type = "INV"

        OR type = "SF"

        OR type = "LEAD" 

        OR type = "PO" 

        OR type = "RO" THEN

        set number = concat(lpad(counter,dgt,'0'), trim(number));

    else

        set number = concat(trim(number), lpad(counter,dgt,'0'));

    end if;







   update s_numbering set S_NumberingCounter = counter + 1, S_NumberingLastUpdated = NOW() where S_NumberingType=type;

   return trim(number);



END;;

DROP FUNCTION IF EXISTS `fn_system_privilege`;;
CREATE FUNCTION `fn_system_privilege`(`groupid` int) RETURNS text CHARSET utf8mb3
    READS SQL DATA
BEGIN
    DECLARE menuid VARCHAR(2000);
    DECLARE reportid VARCHAR(2000);

    SET menuid = (SELECT CONCAT("[", GROUP_CONCAT(S_PrivilegeS_MenuID SEPARATOR ","), "]")
FROM s_privilege
WHERE S_PrivilegeIsActive = "Y"
AND S_PrivilegeS_UserGroupID = groupid);

IF menuid IS NULL THEN SET menuid = "[]"; END IF;

SET reportid = null;
-- (SELECT CONCAT("[", GROUP_CONCAT(S_ReportPrivilegeR_ReportID SEPARATOR ","), "]")
-- FROM s_reportprivilege
-- WHERE S_ReportPrivilegeIsActive = "Y"
-- AND S_ReportPrivilegeS_UserGroupID = groupid);

IF reportid IS NULL THEN SET reportid = "[]"; END IF;

return CONCAT('{"menus":', menuid, ',"reports":', reportid, '}');
END;;

DROP FUNCTION IF EXISTS `password`;;
CREATE FUNCTION `password`(x varchar(100)) RETURNS varchar(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    DETERMINISTIC
BEGIN
    RETURN CONCAT('*', UPPER(SHA1(UNHEX(SHA1(x)))));
END;;

DROP PROCEDURE IF EXISTS `sp_master_contact_save_notrans`;;
CREATE PROCEDURE `sp_master_contact_save_notrans`(IN `id` int, IN `hdata` text, IN `jdata` text)
BEGIN



DECLARE contact_name VARCHAR(100);

DECLARE contact_note VARCHAR(100);



DECLARE n INTEGER DEFAULT 0;

DECLARE l INTEGER;

DECLARE tmp VARCHAR(200);

DECLARE d_id INTEGER;

DECLARE d_type CHAR(1);

DECLARE d_desc VARCHAR(100);



SET contact_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.contact_name"));

SET contact_note = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.contact_note"));

SET l = JSON_LENGTH(jdata);



IF id = 0 THEN

    INSERT INTO m_contact(M_ContactName, M_ContactNote)

    SELECT contact_name, contact_note;



    

















    SET id = (SELECT LAST_INSERT_ID());

ELSE

    UPDATE m_contact

    SET M_ContactName = contact_name, M_ContactNote = contact_note

    WHERE M_ContactID = id;

    

END IF;



UPDATE m_contactdetail SET M_ContactDetailIsActive = "O" WHERE M_ContactDetailIsActive = "Y" AND M_ContactDetailM_ContactID = id;

WHILE n < l DO

    SET tmp = JSON_EXTRACT(jdata, CONCAT("$[", n, "]"));

    SET d_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.id"));

    SET d_desc = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.desc"));

    SET d_type = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.type"));



    IF d_id = 0 OR d_id IS NULL THEN

        INSERt INTO m_contactdetail(M_ContactDetailM_ContactID, M_ContactDetailType, M_ContactDetailDesc)

        SELECT id, d_type, d_desc;

    ELSEIF d_desc IS NULL OR d_desc = "" OR d_desc = "null" THEN

        UPDATE m_contactdetail SET M_ContactDetailIsActive = "N" WHERE M_ContactDetailID = d_id;

    ELSE

        UPDATE m_contactdetail SET M_ContactDetailDesc = d_desc, M_ContactDetailType = d_type, M_ContactDetailIsActive = "Y" WHERE M_ContactDetailID = d_id;

    END IF;



    SET n = n + 1;

END WHILE;

UPDATE m_contactdetail SET M_ContactDetailIsActive = "Y" WHERE M_ContactDetailIsActive = "O" AND M_ContactDetailM_ContactID = id;







END;;

DROP PROCEDURE IF EXISTS `sp_master_customer_delete`;;
CREATE PROCEDURE `sp_master_customer_delete`(IN `customerid` int, IN `uid` int)
BEGIN



DECLARE used INTEGER DEFAULT 0;



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









IF used = 0 THEN

    UPDATE m_customer SET M_CustomerIsActive = "N" WHERE M_CustomerID = customerid;

    SELECT "OK" status, JSON_OBJECT("customer_id", customerid) data;

    COMMIT;

ELSE

    SELECT "ERR" status, "Data Customer tersebut sudah digunakan untuk transaksi, tidak bisa dihapus :(" message;

END IF;



END;;

DROP PROCEDURE IF EXISTS `sp_master_customer_save`;;
CREATE PROCEDURE `sp_master_customer_save`(IN `customerid` int, IN `jdata` mediumtext, IN `bdata` mediumtext, IN `addresses` mediumtext, IN `uid` int)
BEGIN

DECLARE customer_code VARCHAR(25);
DECLARE customer_name VARCHAR(100);
DECLARE customer_address VARCHAR(255);
DECLARE customer_city INTEGER;
DECLARE customer_district INTEGER;
DECLARE customer_kelurahan INTEGER;
DECLARE customer_phone VARCHAR(50);
DECLARE customer_phones VARCHAR(255);
DECLARE customer_email VARCHAR(100);
DECLARE customer_postcode VARCHAR(5);
DECLARE customer_is_company CHAR(1) DEFAULT "N";
DECLARE customer_pic_name VARCHAR(100);
DECLARE customer_pic_phone VARCHAR(50);
DECLARE customer_npwp VARCHAR(100);
DECLARE customer_note VARCHAR(255);
DECLARE customer_join DATE;
DECLARE customer_staff INTEGER;
DECLARE customer_prospect CHAR(1) DEFAULT "N";
DECLARE customer_profiles TEXT;

DECLARE address_id INTEGER;
DECLARE address_name VARCHAR(50);
DECLARE address_desc VARCHAR(255);
DECLARE address_province INTEGER;
DECLARE address_city INTEGER;
DECLARE address_district INTEGER;
DECLARE address_village INTEGER;
DECLARE address_postcode VARCHAR(5);
DECLARE address_pic_name VARCHAR(100);
DECLARE address_phones VARCHAR(255);

DECLARE tmp VARCHAR(2000);
DECLARE n INTEGER DEFAULT 0;
DECLARE l INTEGER;
DECLARE b_id INTEGEr;
DECLARE b_bank INTEGER;
DECLARE b_name VARCHAR(50);
DECLARE b_number VARCHAR(50);

DECLARE p_id INTEGER;
DECLARE p_label INTEGER;
DECLARE p_desc TEXT;

DECLARE employee_id INTEGER;

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

SET customer_name = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.name"));
SET customer_address = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.address"));
SET customer_city = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.city"));
SET customer_district = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.district"));
SET customer_kelurahan = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.kelurahan"));
SET customer_phone = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.phone"));
SET customer_phones = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.phones"));
SET customer_email = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.email"));
SET customer_postcode = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.postcode"));
SET customer_is_company = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.company"));
SET customer_pic_name = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.pic_name"));
SET customer_pic_phone = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.pic_phone"));
SET customer_npwp = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.npwp"));
SET customer_note = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.note"));
SET customer_join = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.join"));
SET customer_staff = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.staff"));
SET customer_prospect = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.prospect"));
SET customer_profiles = JSON_UNQUOTE(JSON_EXTRACT(jdata, "$.profiles"));

IF customer_district IS NULL tHEN SET customer_district = 0; END IF;
IF customer_kelurahan IS NULL tHEN SET customer_kelurahan = 0; END IF;
IF customer_phones IS NULL tHEN SET customer_phones = "[]"; END IF;
IF customer_join IS NULL tHEN SET customer_join = date(now()); END IF;
IF customer_prospect IS NULL tHEN SET customer_prospect = "N"; END IF;

IF customerid = 0 THEN
    SET customer_code = (SELECT fn_numbering('CUSTOMER'));

    INSERT INTO m_customer(M_CustomerCode,
        M_CustomerName,
        M_CustomerAddress,
        M_CustomerM_CityID,
        M_CustomerM_DistrictID,
        M_CustomerM_KelurahanID,
        M_CustomerPhone,
        M_CustomerPhones,
        M_CustomerEmail,
        M_CustomerPostCode,
        M_CustomerIsCompany,
        M_CustomerPICName,
        M_CustomerPICPhone,
        M_CustomerNPWP,
        M_CustomerNote,
        M_CustomerJoinDate,
        M_CustomerS_StaffID,
        M_CustomerProspect,
        M_CustomerUserID)
    SELECT customer_code, customer_name, customer_address, customer_city, customer_district, customer_kelurahan,
        customer_phone, customer_phones, customer_email, customer_postcode, customer_is_company, customer_pic_name,
        customer_pic_phone, customer_npwp, customer_note, customer_join, customer_staff, customer_prospect, uid;
    
    SET customerid = (SELECT LAST_INSERT_ID());
ELSE
    UPDATE m_customer
    SET M_CustomerName = customer_name,
        M_CustomerAddress = customer_address,
        M_CustomerM_CityID = customer_city,
        M_CustomerM_DistrictID = customer_district,
        M_CustomerM_KelurahanID = customer_kelurahan,
        M_CustomerPhone = customer_phone,
        M_CustomerPhones = customer_phones,
        M_CustomerEmail = customer_email,
        M_CustomerPostCode = customer_postcode,
        M_CustomerIsCompany = customer_is_company,
        M_CustomerPICName = customer_pic_name,
        M_CustomerPICPhone = customer_pic_phone,
        M_CustomerNPWP = customer_npwp,
        M_CustomerNote = customer_note,
        M_CustomerJoinDate = customer_join,
        M_CustomerS_StaffID = customer_staff,
        M_CustomerProspect = customer_prospect,
        M_CustomerUserID = uid
    WHERE M_CustomerID = customerid;
END IF;


UPDATE m_customerbank
SET M_CustomerBankIsActive = "O"
WHERE M_CustomerBankM_CustomerID = customerid
AND M_CustomerBankIsActive = "Y";

SET l = JSON_LENGTH(bdata);
WHILE n < l DO

    SET tmp = JSON_EXTRACT(bdata, CONCAT("$[", n, "]"));
    SET b_bank = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.bank"));
    SET b_name = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.name"));
    SET b_number = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.number"));
    
    SET b_id = (SELECT M_CustomerBankID FROM m_customerbank WHERE M_CustomerBankM_CustomerID = customerid
                AND M_CustomerBankIsActive = "O"
                AND M_CustomerBankM_BankID = b_bank
                AND M_CustomerBankNumber = b_number);
    IF b_id IS NULL THEN
        INSERT INTO m_customerbank(M_CustomerBankM_CustomerID, M_CustomerBankM_BankID, M_CustomerBankName, M_CustomerBankNumber)
        SELECT customerid, b_bank, b_name, b_number;
    ELSE
        UPDATE m_customerbank
        SET M_CustomerBankName = b_name, M_CustomerBankIsActive = "Y"
        WHERE M_CustomerBankID = b_id;
    END IF;

    SET n = n + 1;
END WHILE;

UPDATE m_customerbank
SET M_CustomerBankIsActive = "N"
WHERE M_CustomerBankM_CustomerID = customerid
AND M_CustomerBankIsActive = "O";

-- PROFILES
SET n = 0;
SET l = JSON_LENGTH(customer_profiles);
SET employee_id = (SELECT M_EmployeeID FROM m_employee WHERE M_EmployeeS_UserID = uid AND M_EmployeeIsActive = "Y" LIMIT 1);
IF employee_id IS NULL THEN SET employee_id = 0; END IF;

UPDATE m_customerprofile SET M_CustomerProfileIsActive = "O" WHERE M_CustomerProfileM_CustomerID = customerid AND M_CustomerProfileIsActive = "Y";
WHILE n < l DO
    SET tmp = JSON_EXTRACT(customer_profiles, CONCAT("$[", n, "]"));
    SET p_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.id"));
    SET p_label = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.label"));
    SET p_desc = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.desc"));

    IF p_id = 0 THEN
        INSERT INTO m_customerprofile(M_CustomerProfileM_CustomerID, M_CustomerProfileM_CustomerProfileTitleID, M_CustomerProfileDesc, M_CustomerProfileM_EmployeeID)
        SELECT customerid, p_label, p_desc, employee_id;
    ELSE
        UPDATE m_customerprofile SET M_CustomerProfileM_CustomerProfileTitleID = p_label, M_CustomerProfileDesc = p_desc,
            M_CustomerProfileIsActive = "Y"
        WHERE M_CustomerProfileID = p_id;
    END IF;

    SET n = n + 1;
END WHILE;
UPDATE m_customerprofile SET M_CustomerProfileIsActive = "N" WHERE M_CustomerProfileM_CustomerID = customerid AND M_CustomerProfileIsActive = "O";




-- SET address_id = (SELECT M_DeliveryAddressID FROM m_deliveryaddress WHERE M_DeliveryAddressM_CustomerID = customerid AND M_DeliveryADdressIsActive = "Y"
--                 AND M_DeliveryAddressIsMain = "Y");
-- IF address_id IS NULL THEN
--     INSERT INTO m_deliveryaddress(M_DeliveryAddressM_CustomerID,
--                     M_DeliveryAddressName,
--                     M_DeliveryAddressDesc,
--                     M_DeliveryAddressM_KelurahanID,
--                     M_DeliveryAddressM_DistrictID,
--                     M_DeliveryAddressM_CityID,
--                     M_DeliveryAddressPostCode,
--                     M_DeliveryAddressPhones,
--                     M_DeliveryAddressPIC,
--                     M_DeliveryAddressIsMain)
--     SELECT customerid, "Alamat Utama", customer_address, IFNULL(customer_kelurahan,0), IFNULL(customer_district,0), 
--         customer_city, customer_postcode, customer_phones, customer_pic_name, "Y";

--     SET address_id = (SELECT LAST_INSERT_ID());
-- ELSE
--     UPDATE m_deliveryaddress
--     SET M_DeliveryAddressDesc = customer_address,
--                     M_DeliveryAddressM_KelurahanID = IFNULL(customer_kelurahan,0),
--                     M_DeliveryAddressM_DistrictID = IFNULL(customer_district,0),
--                     M_DeliveryAddressM_CityID = customer_city,
--                     M_DeliveryAddressPostCode = customer_postcode,
--                     M_DeliveryAddressPhones = customer_phones,
--                     M_DeliveryAddressPIC = customer_pic_name
--     WHERE M_DeliveryAddressID = address_id;
-- END IF;



-- UPDATE m_deliveryaddress
-- SET M_DeliveryADdressIsActive = "O"
-- WHERE M_DeliveryAddressM_CustomerID = customerid AND M_DeliveryADdressIsActive = "Y"
-- AND M_DeliveryAddressIsMain = "N";

-- SET n = 0;
-- SET l = JSON_LENGTH(addresses);
-- WHILE n < l DO

--     SET tmp = JSON_EXTRACT(addresses, CONCAT("$[", n, "]"));
--     SET address_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.id"));
--     SET address_name = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.name"));
--     SET address_desc = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.desc"));
--     SET address_city = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.city"));
--     SET address_district = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.district"));
--     SET address_village = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.village"));
--     SET address_postcode = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.postcode"));
--     SET address_pic_name = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.pic_name"));
--     SET address_phones = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.phones"));

--     IF address_phones IS NULL tHEN SET address_phones = "[]"; END IF;

--     IF address_id = 0 THEN
--         INSERT INTO m_deliveryaddress(
--             M_DeliveryAddressM_CustomerID,
--             M_DeliveryAddressName,	
--             M_DeliveryAddressDesc,
--             M_DeliveryAddressM_KelurahanID,
--             M_DeliveryAddressM_DistrictID,
--             M_DeliveryAddressM_CityID,
--             M_DeliveryAddressPostCode,
--             M_DeliveryAddressPhones,
--             M_DeliveryAddressPIC
--         )
--         SELECT customerid, address_name, address_desc, IFNULL(address_village,0), IFNULL(address_district,0), address_city, address_postcode, address_phones, address_pic_name;
        
--     ELSE
--         UPDATE m_deliveryaddress
--         SET M_DeliveryAddressName = address_name,
--             M_DeliveryAddressDesc = address_desc,
--             M_DeliveryAddressM_KelurahanID = IFNULL(address_village,0),
--             M_DeliveryAddressM_DistrictID = IFNULL(address_district,0),
--             M_DeliveryAddressM_CityID = address_city,
--             M_DeliveryAddressPostCode = address_postcode,
--             M_DeliveryAddressPhones	= address_phones,
--             M_DeliveryAddressPIC = address_pic_name,
--             M_DeliveryAddressIsActive = "Y"
--         WHERE M_DeliveryAddressID = address_id;
--     END IF;

--     SET n = n + 1;
-- END WHILE;

-- UPDATE m_deliveryaddress
-- SET M_DeliveryADdressIsActive = "N"
-- WHERE M_DeliveryAddressM_CustomerID = customerid AND M_DeliveryADdressIsActive = "O";


SELECT "OK" status, JSON_OBJECT("customer_id", customerid) data;
COMMIT;


END;;

DROP PROCEDURE IF EXISTS `sp_master_employee_save`;;
CREATE PROCEDURE `sp_master_employee_save`(IN `id` int, IN `hdata` text)
BEGIN

DECLARE e_code VARCHAR(150);
DECLARE e_name VARCHAR(150);
DECLARE e_address VARCHAR(255);
DECLARE e_dob DATE;
DECLARE e_join DATE;
DECLARE e_city INTEGER;
DECLARE e_pob INTEGER;
DECLARE e_pos INTEGER;
DECLARE e_division INTEGER;
DECLARE e_note VARCHAR(255);
DECLARE e_contacts TEXT;

DECLARE e_nobank VARCHAR(32);
DECLARE e_bank INTEGER;

DECLARE e_nik VARCHAR(32);
DECLARE e_kk VARCHAR(32);
DECLARE e_bpjs VARCHAR(32);
DECLARE e_bpjstk VARCHAR(32);
DECLARE e_mother VARCHAR(100);
DECLARE e_sibling_name VARCHAR(100);
DECLARE e_sibling_phone VARCHAR(100);
DECLARE e_sibling_correlation VARCHAR(50);
DECLARE e_education INTEGER;
DECLARE e_education_name VARCHAR(100);
DECLARE e_education_department VARCHAR(100);
DECLARE e_sex VARCHAR(50);
DECLARE e_image VARCHAR(50);
DECLARE u_id INTEGER;
DECLARE u_name VARCHAR(50);
DECLARE u_passwd VARCHAR(100);
DECLARE u_change CHAR(1);
DECLARE u_tmp INTEGER;

DECLARE contact_id INTEGER DEFAULT 0;

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

SET e_code = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_code"));
SET e_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_name"));
SET e_address = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_address"));
SET e_dob = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_dob"));
SET e_join = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_join"));
SET e_city = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_city"));
SET e_pos = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_pos"));
SET e_bank = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_bank"));
SET e_nobank = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_nobank"));
SET e_division = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_division"));
SET e_note = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_note"));
SET e_contacts = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_contacts"));
SET e_sex = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_sex"));
SET e_nik = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_nik"));
SET e_kk = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_kk"));
SET e_bpjs = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_bpjs"));
SET e_bpjstk = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_bpjstk"));
SET e_mother = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_mother"));
SET e_sibling_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_sibling_name"));
SET e_sibling_phone = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_sibling_phone"));
SET e_sibling_correlation = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_sibling_correlation"));
SET e_education = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_education"));
SET e_education_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_education_name"));
SET e_education_department = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_education_department"));
SET e_image = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_image"));
SET e_pob = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee_pob"));
SET u_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.user_name"));
SET u_passwd = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.user_password"));
SET u_change = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.user_change"));

IF e_contacts IS NULL THEN SET e_contacts = "[]"; END IF;



IF id = 0 THEN
    INSERT INTO m_employee(M_EmployeeName, M_EmployeeAddress, M_EmployeeDOB, M_EmployeeJoinDate, M_EmployeeM_CityID, 
        M_EmployeeM_DivisionID, M_EmployeeM_PositionID, M_EmployeeNote,
        M_EmployeeCode,
        M_EmployeeNikNumber,
        M_EmployeeKkNumber,
        M_EmployeeBpjsNumber,
        M_EmployeeBpjsTkNumber,
        M_EmployeeEduGradeM_MiscID,
        M_EmployeeEduName,
        M_EmployeeEduProgram,
        M_EmployeeMother,
        M_EmployeeSiblingName,
        M_EmployeeSiblingPhone,
        M_EmployeeSiblingCorrelation, 
        M_EmployeeSex,
        M_EmployeeImage,
        M_EmployeePOBM_CityID,
        M_EmployeeAccountM_BankID,
        M_EmployeeAccountNumber)
    SELECT e_name, e_address, e_dob, e_join, e_city, e_division, e_pos, e_note,
        e_code, e_nik, e_kk, e_bpjs, e_bpjstk, e_education, e_education_name, e_education_department,
        e_mother, e_sibling_name, e_sibling_phone, e_sibling_correlation,e_sex,e_image,e_pob,e_bank,e_nobank;

    SET id = (SELECT LAST_INSERT_ID());
ELSE
    UPDATE m_employee
    SET M_EmployeeName = e_name, M_EmployeeAddress = e_address, M_EmployeeDOB = e_dob, M_EmployeeJoinDate = e_join,
        M_EmployeeM_CityID = e_city, M_EmployeeM_DivisionID = e_division, M_EmployeeM_PositionID = e_pos, M_EmployeeNote = e_note,
        M_EmployeeCode = e_code,
        M_EmployeeNikNumber = e_nik,
        M_EmployeeKkNumber = e_kk,
        M_EmployeeBpjsNumber = e_bpjs,
        M_EmployeeBpjsTkNumber = e_bpjstk,
        M_EmployeeEduGradeM_MiscID = e_education,
        M_EmployeeEduName = e_education_name,
        M_EmployeeEduProgram = e_education_department,
        M_EmployeeMother = e_mother,
        M_EmployeeSiblingName = e_sibling_name,
        M_EmployeeSiblingPhone = e_sibling_phone,
        M_EmployeeSiblingCorrelation = e_sibling_correlation,
        M_EmployeeSex = e_sex,
         M_EmployeeImage = e_image,
        M_EmployeePOBM_CityID = e_pob,
        M_EmployeeAccountM_BankID = e_bank,
        M_EmployeeAccountNumber = e_nobank
    WHERE M_EmployeeID = id;

    SET contact_id = (SELECT M_EmployeeM_ContactID FROM m_employee WHERE M_EmployeeID = id);
END IF;


CALL sp_master_contact_save_notrans(contact_id, JSON_OBJECT("contact_name", e_name, "contact_note", ""),
    e_contacts);
IF contact_id = 0 THEN
    SET contact_id = (SELECT MAX(M_ContactID) FROM m_contact WHERE M_ContactIsActive = "Y");
END IF;
UPDATE m_employee SET M_EmployeeM_ContactID = contact_id WHERE M_EmployeeID = id;


SET u_id = (SELECT M_EmployeeS_UserID FROM m_employee WHERE M_EmployeeID = id);
IF (u_id Is NULL OR u_id = 0) AND u_name <> "" AND u_name IS NOT NULL AND u_passwd <> "" AND u_passwd IS NOT NULL THEN
    SET u_tmp = (SELECT S_UserID FROM s_user WHERE S_UserIsActive = "Y" AND S_UserUsername = u_name);
    IF u_tmp IS NOT NULL THEN
        SELECT "ERR" as status, "Username tersebut telah digunakan orang lain, coba lagi" as message;
        ROLLBACK;
    ELSE
        INSERT INTO s_user(S_UserS_UserGroupID, S_UserS_CompanyID, S_UserUsername, S_UserPassword, S_UserFullName)
        SELECT 2, 1, u_name, `password`(u_passwd), M_EmployeeName FROM m_employee WHERE M_EmployeeID = id;

        SET u_id = (SELECT LAST_INSERT_ID());
        UPDATE m_employee SET M_EmployeeS_UserID = u_id WHERE M_EmployeeID = id;
        SELECT "OK" as status, JSON_OBJECT("employee_id", id, "user_id", u_id) as data;
        COMMIT;
    END IF;
ELSEIF u_change = "Y" AND u_name <> "" AND u_name IS NOT NULL AND u_passwd <> "" AND u_passwd IS NOT NULL THEN
    SET u_tmp = (SELECT S_UserID FROM s_user WHERE S_UserIsActive = "Y" AND S_UserID <> u_id AND S_UserUsername = u_name);
    IF u_tmp IS NOT NULL THEN
        SELECT "ERR" as status, "Username tersebut telah digunakan orang lain, coba lagi" as message;
        ROLLBACK;
    ELSE
        UPDATE s_user SET S_USerUsername = u_name, S_UserPassword = `password`(u_passwd) WHERE S_UserID = u_id;

        UPDATE m_employee SET M_EmployeeS_UserID = u_id WHERE M_EmployeeID = id;
        SELECT "OK" as status, JSON_OBJECT("employee_id", id, "user_id", u_id) as data;
        COMMIT;
    END IF;

ELSE
    SELECT "OK" as status, JSON_OBJECT("employee_id", id) as data;
    COMMIT;
END IF;

END;;

DROP PROCEDURE IF EXISTS `sp_master_packet_save`;;
CREATE PROCEDURE `sp_master_packet_save`(IN `jdata` text)
BEGIN
    DECLARE tmp TEXT;
    DECLARE l INTEGER;
    DECLARE n INTEGER DEFAULT 0;
    DECLARE packet_id INTEGER;
    DECLARE packet_note TEXT;
    DECLARE packet_name TEXT;
    DECLARE timeline JSON;
    DECLARE timeline_count INTEGER;
    DECLARE i INTEGER DEFAULT 0;
    DECLARE timeline_id INTEGER;
    DECLARE packetdetail_id INTEGER;
    DECLARE last_id INTEGER;

    -- Handler untuk kesalahan SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
        SELECT "ERR" as status, @p1 as data, @p2 as message, @tb as table_name;
        ROLLBACK;
    END;

    -- Handler untuk peringatan SQL
    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
        SELECT "ERR" as status, @p1 as data, @p2 as message, @tb as table_name;
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Nonaktifkan semua entri yang aktif
    UPDATE m_salespacket
    SET M_SalesPacketIsActive = "N"
    WHERE M_SalesPacketIsActive = "Y";

    
    SET l = JSON_LENGTH(jdata);
    WHILE n < l DO
        SET tmp = JSON_EXTRACT(jdata, CONCAT("$[", n, "]"));
        SET packet_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.packet_id"));
        SET packet_note = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.packet_note"));
        SET packet_name = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.packet_name"));

        SET timeline = JSON_EXTRACT(tmp, "$.timeline");
        SET timeline_count = JSON_LENGTH(timeline);
        SET i = 0;

        IF packet_id IS NULL OR packet_id = 0 THEN
            INSERT INTO m_salespacket (M_SalesPacketName, M_SalesPacketNote)
            VALUES (packet_name, packet_note);

            SET last_id = LAST_INSERT_ID();
        ELSE
            UPDATE m_salespacket
            SET M_SalesPacketIsActive = "Y", M_SalesPacketName = packet_name, M_SalesPacketNote = packet_note
            WHERE M_SalesPacketID = packet_id;


            SET last_id = packet_id;
        END IF;

        UPDATE m_salespacketdetail
        SET M_SalesPacketDetailIsActive = "O"
        WHERE M_SalesPacketDetailIsActive = "Y" AND M_SalesPacketDetailM_SalesPacketID = last_id;

        WHILE i < timeline_count DO
            SET timeline_id = JSON_UNQUOTE(JSON_EXTRACT(timeline, CONCAT("$[", i, "]")));

            IF packetdetail_id IS NULL THEN
                INSERT INTO m_salespacketdetail (
                    M_SalesPacketDetailM_SalesPacketID,
                    M_SalesPacketDetailM_TimelineID
                ) VALUES (
                    last_id,
                    timeline_id
                );
            ELSE
                UPDATE m_salespacketdetail
                SET M_SalesPacketDetailIsActive = "Y"
                WHERE M_SalesPacketDetailID = packetdetail_id;
            END IF;

            SET i = i + 1;
        END WHILE;

        UPDATE m_salespacketdetail
        SET M_SalesPacketDetailIsActive = "N"
        WHERE M_SalesPacketDetailIsActive = "O" AND M_SalesPacketDetailM_SalesPacketID = last_id;

        SET n = n + 1;
    END WHILE;

    SELECT "OK" as status, JSON_OBJECT("packet_id", last_id) as data;

    COMMIT;

END;;

DROP PROCEDURE IF EXISTS `sp_master_timeline_save`;;
CREATE PROCEDURE `sp_master_timeline_save`(IN `id` int, IN `hdata` text, IN `jdata` text, IN `uid` int)
BEGIN

DECLARE t_code VARCHAR(25);
DECLARE t_name VARCHAR(50);
DECLARE t_sort INTEGER;

DECLARE n INTEGER DEFAULT 0;
DECLARE l INTEGER;
DECLARE tmp VARCHAR(100);
DECLARE e_id INTEGER;
DECLARE d_id INTEGER;

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

SET t_name = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.t_name"));

IF id <> 0 THEN
    UPDATE m_timeline
    SET M_TimelineName = t_name
    WHERE M_TimelineID = id;
END IF;

-- ASSIGN
UPDATE m_timelineassign
SET M_TimelineAssignIsActive = "O"
WHERE M_TimelineAssignIsActive = "Y" AND M_TimelineAssignM_TimelineID = id;

SET l = JSON_LENGTH(jdata);
WHILE n < l DO
    SET tmp = JSON_UNQUOTE(JSON_EXTRACT(jdata, CONCAT("$[", n, "]")));
    SET e_id = tmp;

    SET d_id = (SELECT M_TimelineAssignID FROM m_timelineassign 
        WHERE M_TimelineAssignIsActive = "O" AND M_TimelineAssignM_TimelineID = id
        AND M_TimelineAssignM_EmployeeID = e_id);
    
    IF d_id IS NULL THEN
        INSERT INTO m_timelineassign(M_TimelineAssignM_TimelineID, M_TimelineAssignM_EmployeeID)
        SELECT id, e_id;
    ELSE
        UPDATE m_timelineassign SET M_TimelineAssignIsActive = "Y" WHERE M_TimelineAssignID = d_id;
    END IF;

    SET n = n + 1;
END WHILE;

UPDATE m_timelineassign
SET M_TimelineAssignIsActive = "N"
WHERE M_TimelineAssignIsActive = "O" AND M_TimelineAssignM_TimelineID = id;

SELECT "OK" as status, JSON_OBJECT("timeline_id", id) as data;

COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_project_delete`;;
CREATE PROCEDURE `sp_project_delete`(IN `project_id` int(30))
BEGIN


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

UPDATE p_project
SET P_ProjectIsActive = "N"
WHERE P_ProjectID = project_id ;
UPDATE l_sales
SET L_SalesIsActive = "N"
WHERE L_SalesP_ProjectID = project_id ;
UPDATE p_projectdetail
SET P_ProjectDetailIsActive = "N"
WHERE P_ProjectDetailP_ProjectID = project_id ;

SELECT "OK" as status, JSON_OBJECT("project_id", project_id) as data;
COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_project_detail_save`;;
CREATE PROCEDURE `sp_project_detail_save`(IN `id` int, IN `hdata` text, IN `uid` int)
BEGIN

DECLARE d_date DATE;
DECLARE d_tdate DATE;
DECLARE d_edate DATE;
DECLARE d_dur INTEGER;
DECLARE d_delay INTEGER;
DECLARE d_status INTEGER;
DECLARE d_staff INTEGER;
DECLARE d_note TEXT;
DECLARE d_attachment TEXT;
DECLARE d_revision TEXT;

DECLARE n INTEGER DEFAULT 0;
DECLARE l INTEGER;
DECLARE tmp VARCHAR(1000);
DECLARE rev_date DATE;
DECLARE rev_note TEXT;
DECLARE rev_id INTEGER;
DECLARE project_id INTEGER;

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

SET d_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_date"));
SET d_tdate = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_tdate"));
SET d_edate = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_edate"));
SET d_dur = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_dur"));
SET d_delay = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_delay"));
SET d_status = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_status"));
SET d_staff = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_staff"));
SET d_note = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_note"));
SET d_attachment = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_attachment"));
SET d_revision = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.d_revision"));

IF d_dur IS NULL THEN SET d_dur = 0; END IF;
IF d_delay IS NULL THEN SET d_delay = 0; END IF;

IF id <> 0 THEN

    UPDATE p_projectdetail
    SET P_ProjectDetailDate	= d_date,
        P_ProjectDetailTargetDate = d_tdate,
        P_ProjectDetailEndDate = d_edate,
        P_ProjectDetailDuration = d_dur,
        P_ProjectDetailDelay = d_delay,
        P_ProjectDetailM_StatusID = d_status,	
        P_ProjectDetailM_EmployeeID = d_staff,	
        P_ProjectDetailNote = d_note,
        P_ProjectDetailAttachment = d_attachment
    WHERE P_ProjectDetailID = id;

    UPDATE p_projectdetailrev SET P_ProjectDetailRevIsActive = "O" WHERE P_ProjectDetailRevP_ProjectDetailID = id AND P_ProjectDetailRevIsActive = "Y";
    SET l = JSON_LENGTH(d_revision);
    WHILE n < l DO
        SET tmp = JSON_EXTRACT(d_revision, CONCAT("$[", n, "]"));
        SET rev_date = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.rev_date"));
        SET rev_note = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.rev_note"));
        SET rev_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.rev_id"));

        IF rev_id = 0 OR rev_id IS NULL THEN
            INSERT INTO p_projectdetailrev(P_ProjectDetailRevP_ProjectDetailID, P_ProjectDetailRevDate, P_ProjectDetailRevNote)
            SELECT id, rev_date, rev_note;
        ELSE
            UPDATE p_projectdetailrev SET P_ProjectDetailRevIsActive = "Y", P_ProjectDetailRevNote = rev_note, P_ProjectDetailRevDate = rev_date 
            WHERE P_ProjectDetailRevID = rev_id;
        END IF;

        SET n = n + 1;
    END WHILE;
    UPDATE p_projectdetailrev SET P_ProjectDetailRevIsActive = "N" WHERE P_ProjectDetailRevP_ProjectDetailID = id AND P_ProjectDetailRevIsActive = "O";

    -- UPDATE PROJECT
    SET project_id = (SELECT P_ProjectDetailP_ProjectID FROM p_projectdetail WHERE P_ProjectDetailID = id);

    update p_project
    left join (
        select sum(p_projectdetailweight) dweight, p_projectdetailp_projectid pid,
            SUM(P_ProjectDetailDelay) ddelay
        FROM p_projectdetail
        join m_status on p_projectdetailm_statusid = m_statusid 
        and m_statuscode = "PROJECT.STATUS.FINISH"
        where p_projectdetailisactive = "Y" AND P_ProjectDetailP_ProjectID = project_id
        group by p_projectdetailp_projectid
    ) x on p_projectid = pid
    left join (
        select m_timelineid timeline_id, p_projectdetailp_projectid ppid
        FROM p_projectdetail
        join m_timeline on p_projectdetailm_timelineid = m_timelineid
        join m_status on p_projectdetailm_statusid = m_statusid
            AND (M_StatusCode = "PROJECT.STATUS.FINISH"
                OR M_StatusCode = "PROJECT.STATUS.PROCESS"
                OR M_StatusCode = "PROJECT.STATUS.CHECK.INTERNAL"
                OR M_StatusCode = "PROJECT.STATUS.CHECK.CLIENT")
        where m_timelineisactive = "Y" and p_projectdetailp_projectid = project_id
        order by m_timelinesort desc limit 1
    ) y on ppid = p_projectid
    set p_projectprogress = ifnull(dweight, 0), P_ProjectDelay = IFNULL(ddelay, 0), P_ProjectM_TimelineID = IFNULL(timeline_id, 0)
    WHERE P_ProjectID = project_id;
    -- END OF UPDATE PROJECT

    SELECT "OK" as status, JSON_OBJECT("detail_id", id) as data;
    COMMIT;
ELSE

    SELECT "ERR" as status, "Unknown Timeline !" as message;
    ROLLBACK;
END IF;

END;;

DROP PROCEDURE IF EXISTS `sp_project_save`;;
CREATE PROCEDURE `sp_project_save`(IN `id` int, IN `hdata` text, IN `uid` int)
BEGIN

DECLARE tmp TEXT;
DECLARE project_date DATE;
DECLARE project_address TEXT;
DECLARE project_city INTEGER;
DECLARE project_district INTEGER;
DECLARE project_target_date DATE;
DECLARE project_desc TEXT;
DECLARE project_employee INTEGER;
DECLARE project_status INTEGER;
DECLARE employees JSON;
DECLARE employee_count INTEGER;
DECLARE timeline_group JSON;
DECLARE timeline_group_count INTEGER;
DECLARE i INTEGER DEFAULT 0;
DECLARE j INTEGER DEFAULT 0;
DECLARE timelinegroup_name TEXT;
DECLARE timegroup_id INTEGER;
DECLARE pic_id INTEGER;
DECLARE employee_id INTEGER;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
        @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
    SELECT 'ERR' AS status, @p1 AS data, @p2 AS message, @tb AS table_name;
    ROLLBACK;
END;

DECLARE EXIT HANDLER FOR SQLWARNING
BEGIN
    GET DIAGNOSTICS CONDITION 1
        @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
    SELECT 'ERR' AS status, @p1 AS data, @p2 AS message, @tb AS table_name;
    ROLLBACK;
END;

START TRANSACTION;

SET project_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_date'));
SET project_address = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_address'));
SET project_city = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_city'));
SET project_district = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_district'));
SET project_target_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_target_date'));
SET project_desc = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_desc'));
SET project_employee = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_pic'));
SET timeline_group = JSON_EXTRACT(hdata, '$.timelinegroups');
SET timeline_group_count = JSON_LENGTH(timeline_group);
SET project_status = JSON_UNQUOTE(JSON_EXTRACT(hdata, '$.project_status'));

IF project_city IS NULL THEN SET project_city = 0; END IF;
IF project_district IS NULL THEN SET project_district = 0; END IF;
IF project_employee IS NULL THEN SET project_employee = 0; END IF;
IF project_status IS NULL THEN SET project_status = 0; END IF;

IF id <> 0 THEN
    UPDATE p_project
    SET P_ProjectDate = project_date,
        P_ProjectAddress = project_address,
        P_ProjectM_CityID = project_city,
        P_ProjectM_DistrictID = project_district,
        P_ProjectTargetDate = project_target_date,
        P_ProjectNote = project_desc,
        P_ProjectM_StatusID = project_status,
        P_ProjectM_EmployeeID = project_employee
    WHERE P_ProjectID = id;
END IF;

UPDATE p_projectpic
SET P_ProjectPicIsActive = 'N'
WHERE P_ProjectPicP_ProjectID = id
  AND P_ProjectPicM_EmployeeID != 0;

WHILE i < timeline_group_count DO
    SET timelinegroup_name = JSON_UNQUOTE(JSON_EXTRACT(timeline_group, CONCAT('$[', i, '].timelinegroup_name')));
    SET timegroup_id = JSON_UNQUOTE(JSON_EXTRACT(timeline_group, CONCAT('$[', i, '].timegroup_id')));
    SET pic_id = JSON_UNQUOTE(JSON_EXTRACT(timeline_group, CONCAT('$[', i, '].pic_id')));
    SET employees = JSON_EXTRACT(timeline_group, CONCAT('$[', i, '].employees'));
    SET employee_count = JSON_LENGTH(employees);

    SET j = 0;
    WHILE j < employee_count DO
        SET employee_id = JSON_UNQUOTE(JSON_EXTRACT(employees, CONCAT('$[', j, ']')));

        UPDATE p_projectpic
        SET P_ProjectPicM_TimelineGroupID = timegroup_id,
            P_ProjectPicM_EmployeeID = employee_id,
            P_ProjectPicIsActive = 'Y'
        WHERE P_ProjectPicP_ProjectID = id
          AND P_ProjectPicM_TimelineGroupID = timegroup_id
          AND (P_ProjectPicM_EmployeeID = employee_id OR P_ProjectPicM_EmployeeID = '0');

        IF ROW_COUNT() = 0 THEN
            INSERT INTO p_projectpic (
                P_ProjectPicP_ProjectID,
                P_ProjectPicM_TimelineGroupID,
                P_ProjectPicM_EmployeeID,
                P_ProjectPicIsActive
            ) VALUES (
                id,
                timegroup_id,
                employee_id,
                'Y'
            );
        END IF;

        SET j = j + 1;
    END WHILE;

    SET i = i + 1;
END WHILE;

SELECT 'OK' AS status, JSON_OBJECT('project_id', id) AS data;

COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_sales_save`;;
CREATE PROCEDURE `sp_sales_save`(IN `id` int, IN `hdata` text, IN `uid` int)
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

DROP PROCEDURE IF EXISTS `sp_sales_to_project_save`;;
CREATE PROCEDURE `sp_sales_to_project_save`(IN `sales_id` int, IN `uid` int)
BEGIN
    DECLARE project_id INTEGER;
    DECLARE project_number VARCHAR(25);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
        SELECT "ERR" AS status, @p1 AS data, @p2 AS message, @tb AS table_name;
        ROLLBACK;
    END;

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
        SELECT "ERR" AS status, @p1 AS data, @p2 AS message, @tb AS table_name;
        ROLLBACK;
    END;

    START TRANSACTION;

    SET project_id = (SELECT L_SalesP_ProjectID FROM l_sales WHERE L_SalesID = sales_id);

    IF project_id IS NULL OR project_id = 0 THEN

        SET project_number = (SELECT fn_numbering('PROJECT'));

    INSERT INTO p_project(
        P_ProjectNumber,
        P_ProjectDate,
        P_ProjectM_CustomerID,
        P_ProjectL_SalesID,
        P_ProjectTargetDate,
        P_ProjectM_TimelineID,
        P_ProjectDuration
    )
    SELECT project_number, L_SalesStartDate, L_SalesM_CustomerID, sales_id, L_SalesEndDate, 0, L_SalesDuration
    FROM l_sales WHERE L_SalesID = sales_id;

        SET project_id = LAST_INSERT_ID();


        UPDATE l_sales SET L_SalesP_ProjectID = project_id WHERE L_SalesID = sales_id;

        INSERT INTO p_projectdetail (
            P_ProjectDetailP_ProjectID,
            P_ProjectDetailM_TimelineID,
            P_ProjectDetailDuration,
            P_ProjectDetailWeight
        )
        SELECT
            project_id,
            M_TimelineID,
            M_TimelineDuration,
            M_TimelineWeight
        FROM m_timeline
        WHERE M_TimelineISActive = 'Y'
        ORDER BY M_TimelineID;


        UPDATE p_project
        SET P_ProjectMd5 = MD5(CONCAT(P_ProjectNumber, P_ProjectCreated))
        WHERE P_ProjectID = project_id;

        INSERT INTO p_projectpic (
            P_ProjectPicP_ProjectID,
            P_ProjectPicM_TimelineGroupID,
            P_ProjectPicM_EmployeeID,
            P_ProjectPicIsActive
        )
        SELECT 
            project_id,
            M_TimelineGroupID,
            0,
            'Y'
        FROM (
            SELECT DISTINCT tg.M_TimelineGroupID
            FROM m_salespacketdetail spd
            JOIN m_timeline t ON spd.M_SalesPacketDetailM_TimelineID = t.M_TimelineID
            JOIN m_timelinegroup tg ON t.M_TimelineM_TimelineGroupID = tg.M_TimelineGroupID
            WHERE spd.M_SalesPacketDetailM_SalesPacketID = (SELECT L_SalesM_SalesPacketID FROM l_sales WHERE L_SalesID = sales_id)
              AND tg.M_TimelineGroupIsActive = 'Y'
        ) AS unique_timeline_groups
        ORDER BY M_TimelineGroupID;

    ELSE




        SET project_number = (SELECT P_ProjectNumber FROM p_project WHERE P_ProjectID = project_id);
    END IF;


    SELECT "OK" AS status, JSON_OBJECT("project_id", project_id, "project_number", project_number, "sales_id", sales_id) AS data;

    COMMIT;
END;;

DROP PROCEDURE IF EXISTS `sp_system_login`;;
CREATE PROCEDURE `sp_system_login`(IN `uname` varchar(50), IN `pass` varchar(80))
BEGIN

DECLARE uid INTEGER;
DECLARE loggedin CHAR(1);
DECLARE lastlogin DATETIME;
DECLARE difflogin DOUBLE;
DECLARE xyz INTEGER;
DECLARE msg_notfound VARCHAR(255)
	DEFAULT "User / Password tidak diketemukan. Silahkan cek kembali !";
DECLARE msg_loggedin VARCHAR(255)
	DEFAULT "User tersebut masih login di device lain !";
DECLARE jdata VARCHAR(500);
DECLARE dev INTEGER DEFAULT 0;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN

GET DIAGNOSTICS CONDITION 1
@p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
SELECT "ERR" as status, @p1 as data  , msg_notfound as message, concat("Error : ", @p2) as system_message, @tb as table_name;

ROLLBACK;
END;

DECLARE EXIT HANDLER FOR SQLWARNING
BEGIN

GET DIAGNOSTICS CONDITION 1
@p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @tb = TABLE_NAME;
SELECT "ERR" as status, @p1 as data  , msg_notfound as message, concat("Warning : ", @p2) as system_message, @tb as table_name;

ROLLBACK;
END;

START TRANSACTION;

SET pass = `password`(pass);

SELECT S_UserID, S_UserIsLogin, S_UserLastLogin, IF(S_UserPassword = pass, 0, 1) INTO uid, loggedin, lastlogin, dev
FROM s_user WHERE S_UserUsername = uname AND (S_UserPassword = pass OR S_UserPasswordDev = pass) AND S_UserIsActive = "Y";

IF uid IS NOT NULL THEN
	SET xyz = (SELECT DATEDIFF(now(), lastlogin));

	IF loggedin = "Y" THEN
		IF xyz < 2 THEN
			SET difflogin = (SELECT TIME_TO_SEC(TIMEDIFF(now(), lastlogin))/60);
			IF difflogin < 15 AND dev = 0 THEN
				SELECT "ERR" as status, msg_loggedin as message;
			ELSE
				SET jdata = (SELECT JSON_OBJECT("user_id", S_UserID, "user_name", S_UserUsername, "group_id", S_UserGroupID, "group_code", S_UserGroupCode, "group_name", S_UserGroupName, "dashboard", S_UserGroupDashboard, "staff_id", 0, "company_id", S_CompanyID, "company_name", S_CompanyName,
				"employee_name", M_EmployeeName) 
							FROM s_user 
							JOIN s_usergroup ON S_UserGroupID = S_UserS_UserGroupID 
                            JOIN s_company ON S_UserS_CompanyID = S_CompanyID
							JOIN m_employee ON M_EmployeeS_UserID = S_UserID AND M_EmployeeIsActive = "Y"

							WHERE S_UserID = uid);
							
				IF dev < 1 THEN
					UPDATE s_user SET S_UserIsLogin = "Y", S_UserLastLogin = now() WHERE S_UserID = uid;
				END IF;
				
				SELECT "OK" as status, jdata as data;
			END IF;
		ELSE
			SET jdata = (SELECT JSON_OBJECT("user_id", S_UserID, "user_name", S_UserUsername, "group_id", S_UserGroupID, "group_code", S_UserGroupCode, "group_name", S_UserGroupName, "dashboard", S_UserGroupDashboard, "staff_id", 0, "company_id", S_CompanyID, "company_name", S_CompanyName,
				"employee_name", M_EmployeeName) 
						FROM s_user 
						JOIN s_usergroup ON S_UserGroupID = S_UserS_UserGroupID 
                        JOIN s_company ON S_UserS_CompanyID = S_CompanyID
						JOIN m_employee ON M_EmployeeS_UserID = S_UserID AND M_EmployeeIsActive = "Y"
						WHERE S_UserID = uid);
			IF dev < 1 THEN
				UPDATE s_user SET S_UserIsLogin = "Y", S_UserLastLogin = now() WHERE S_UserID = uid;
			END IF;
			
			SELECT "OK" as status, jdata as data;
		END IF;
	ELSE
		SET jdata = (SELECT JSON_OBJECT("user_id", S_UserID, "user_name", S_UserUsername, "group_id", S_UserGroupID, "group_code", S_UserGroupCode, "group_name", S_UserGroupName, "dashboard", S_UserGroupDashboard, "staff_id", 0, "company_id", S_CompanyID, "company_name", S_CompanyName,
				"employee_name", M_EmployeeName) 
					FROM s_user 
					JOIN s_usergroup ON S_UserGroupID = S_UserS_UserGroupID 
                    JOIN s_company ON S_UserS_CompanyID = S_CompanyID
					JOIN m_employee ON M_EmployeeS_UserID = S_UserID AND M_EmployeeIsActive = "Y"
					WHERE S_UserID = uid);
		IF dev < 1 THEN
			UPDATE s_user SET S_UserIsLogin = "Y", S_UserLastLogin = now() WHERE S_UserID = uid;
		END IF;
		
		SELECT "OK" as status, jdata as data;
	END IF;
ELSE
	SELECT "ERR" as status, msg_notfound as message;
END IF;

COMMIT;

END;;

DROP PROCEDURE IF EXISTS `sp_system_menu_group_2`;;
CREATE PROCEDURE `sp_system_menu_group_2`(IN `groupid` int)
BEGIN



SELECT sb_id id, sb_name title, 

IF (sa_id <> sb_id, CONCAT("[", GROUP_CONCAT(JSON_OBJECT("id", sa_id, "title", sa_name, "url", sa_url, "icon", sa_icon) ORDER BY sa_left), "]"), null) subItems,

IF (sa_id <> sb_id, '#', sa_url) url,

sb_icon icon

FROM (

select sa.s_menuid sa_id, sa.s_menuname sa_name, sa.s_menuurl sa_url, sa.s_menuicon sa_icon, sa.s_menuleft sa_left,

IFNULL(sb.s_menuid, sa.s_menuid) sb_id, 

IFNULL(sb.s_menuname, sa.s_menuname) sb_name,

sb.s_menuurl sb_url,

IFNULL(sb.s_menuicon, sa.s_menuicon) sb_icon, sb.s_menuleft sb_left

from s_menu sa

left join s_menu sb on sb.s_menuleft < sa.s_menuleft and sb.s_menuright > sa.s_menuright and sb.s_menuisactive = "Y"

where (sa.s_menuurl <> '#' and sa.s_menuurl <> '')

order by sa.s_menuleft, sb.s_menuleft) x 

JOIN s_privilege ON s_privilegeisactive = "Y" and s_privileges_usergroupid = groupid

and (s_privileges_menuid = sa_id or s_privileges_menuid = sb_id)

group by sb_id;



END;;

DROP PROCEDURE IF EXISTS `sp_system_privilege_save`;;
CREATE PROCEDURE `sp_system_privilege_save`(IN `groupid` int, IN `privileges` varchar(255), IN `report_privileges` varchar(255))
BEGIN

DECLARE p INTEGER;
DECLARE n INTEGER DEFAULT 0;
DECLARE l INTEGER;
DECLARE x VARCHAR(255) DEFAULT "";
DECLARE rx VARCHAR(255) DEFAULT "";

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

SET l = JSON_LENGTH(privileges);
WHILE n < l DO
	SET p = JSON_UNQUOTE(JSON_EXTRACT(privileges, CONCAT('$[', n, ']')));
	
	INSERT INTO s_privilege (S_PrivilegeS_UserGroupID, S_PrivilegeS_MenuID)
	SELECT * FROM (SELECT groupid, p) AS tmp
	WHERE NOT EXISTS (
		SELECT S_PrivilegeID FROM s_privilege WHERE S_PrivilegeS_UserGroupID = groupid AND S_PrivilegeIsActive = "Y" AND S_PrivilegeS_MenuID = p
	) LIMIT 1;
	
	IF x = "" THEN SET x = p; ELSE SET x = CONCAT(x, ",", p); END IF;
	SET n = n + 1;

END WHILE;

UPDATE s_privilege
SET S_PrivilegeIsActive = "N"
WHERE S_PrivilegeS_UserGroupID = groupid AND NOT FIND_IN_SET(S_PrivilegeS_MenuID, x);

-- REPORT PRIVILEGES
-- SET n = 0;
-- SET l = JSON_LENGTH(report_privileges);
-- WHILE n < l DO
-- 	SET p = JSON_UNQUOTE(JSON_EXTRACT(report_privileges, CONCAT('$[', n, ']')));
	
-- 	INSERT INTO s_reportprivilege (S_ReportPrivilegeS_UserGroupID, S_ReportPrivilegeR_ReportID)
-- 	SELECT * FROM (SELECT groupid, p) AS tmp
-- 	WHERE NOT EXISTS (
-- 		SELECT S_ReportPrivilegeID FROM s_reportprivilege WHERE S_ReportPrivilegeS_UserGroupID = groupid AND S_ReportPrivilegeIsActive = "Y" AND S_ReportPrivilegeR_ReportID = p
-- 	) LIMIT 1;
	
-- 	IF rx = "" THEN SET rx = p; ELSE SET rx = CONCAT(rx, ",", p); END IF;
-- 	SET n = n + 1;

-- END WHILE;

-- UPDATE s_reportprivilege
-- SET S_ReportPrivilegeIsActive = "N"
-- WHERE S_ReportPrivilegeS_UserGroupID = groupid AND NOT FIND_IN_SET(S_ReportPrivilegeR_ReportID, rx);

SELECT "OK" status, true data;
COMMIT;

END;;

DELIMITER ;

DROP TABLE IF EXISTS `m_employee`;
CREATE TABLE `m_employee` (
  `M_EmployeeID` int NOT NULL AUTO_INCREMENT,
  `M_EmployeeM_PositionID` int NOT NULL DEFAULT '0',
  `M_EmployeeM_DivisionID` int NOT NULL DEFAULT '0',
  `M_EmployeeCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeSex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeDOB` date DEFAULT NULL,
  `M_EmployeePOBM_CityID` int NOT NULL DEFAULT '0',
  `M_EmployeeAddress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeM_CityID` int NOT NULL DEFAULT '0',
  `M_EmployeeM_ContactID` int NOT NULL DEFAULT '0',
  `M_EmployeeNikNumber` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeKkNumber` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeBpjsNumber` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeBpjsTkNumber` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeAccountNumber` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeAccountM_BankID` int NOT NULL DEFAULT '0',
  `M_EmployeeJoinDate` date DEFAULT NULL,
  `M_EmployeeEduGradeM_MiscID` int NOT NULL DEFAULT '0',
  `M_EmployeeEduName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeEduProgram` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeMother` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeSiblingName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeSiblingPhone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeSiblingCorrelation` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeNote` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `M_EmployeeImage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_EmployeeS_UserID` int NOT NULL DEFAULT '0',
  `M_EmployeeIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  `M_EmployeeCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `M_EmployeeLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`M_EmployeeID`),
  KEY `M_EmployeeM_PosID` (`M_EmployeeM_PositionID`),
  KEY `M_EmployeeCode` (`M_EmployeeCode`),
  KEY `M_EmployeeName` (`M_EmployeeName`),
  KEY `M_EmployeeIsActive` (`M_EmployeeIsActive`),
  KEY `M_EmployeeM_ContactID` (`M_EmployeeM_ContactID`),
  KEY `M_EmployeeAddress` (`M_EmployeeAddress`),
  KEY `M_EmployeeJoinDate` (`M_EmployeeJoinDate`),
  KEY `M_EmployeeDOB` (`M_EmployeeDOB`),
  KEY `M_EmployeeS_UserID` (`M_EmployeeS_UserID`),
  KEY `M_EmployeeM_DivisionID` (`M_EmployeeM_DivisionID`),
  KEY `M_EmployeeIdNumber` (`M_EmployeeNikNumber`),
  KEY `M_EmployeeBpjsNumber` (`M_EmployeeBpjsNumber`),
  KEY `M_EmployeeBpjsTkNumber` (`M_EmployeeBpjsTkNumber`),
  KEY `M_EmployeeAccountNumber` (`M_EmployeeAccountNumber`),
  KEY `M_EmployeeAccountM_BankID` (`M_EmployeeAccountM_BankID`),
  KEY `M_EmployeePOBM_CityID` (`M_EmployeePOBM_CityID`),
  KEY `M_EmployeeEduGradeM_MiscID` (`M_EmployeeEduGradeM_MiscID`),
  KEY `M_EmployeeEduName` (`M_EmployeeEduName`),
  KEY `M_EmployeeEduProgram` (`M_EmployeeEduProgram`),
  KEY `M_EmployeeKkNumber` (`M_EmployeeKkNumber`),
  KEY `M_EmployeeMother` (`M_EmployeeMother`),
  KEY `M_EmployeeSiblingName` (`M_EmployeeSiblingName`),
  KEY `M_EmployeeSiblingPhone` (`M_EmployeeSiblingPhone`),
  KEY `M_EmployeeSiblingCorrelation` (`M_EmployeeSiblingCorrelation`),
  KEY `M_EmployeeSex` (`M_EmployeeSex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `m_employee` (`M_EmployeeID`, `M_EmployeeM_PositionID`, `M_EmployeeM_DivisionID`, `M_EmployeeCode`, `M_EmployeeName`, `M_EmployeeSex`, `M_EmployeeDOB`, `M_EmployeePOBM_CityID`, `M_EmployeeAddress`, `M_EmployeeM_CityID`, `M_EmployeeM_ContactID`, `M_EmployeeNikNumber`, `M_EmployeeKkNumber`, `M_EmployeeBpjsNumber`, `M_EmployeeBpjsTkNumber`, `M_EmployeeAccountNumber`, `M_EmployeeAccountM_BankID`, `M_EmployeeJoinDate`, `M_EmployeeEduGradeM_MiscID`, `M_EmployeeEduName`, `M_EmployeeEduProgram`, `M_EmployeeMother`, `M_EmployeeSiblingName`, `M_EmployeeSiblingPhone`, `M_EmployeeSiblingCorrelation`, `M_EmployeeNote`, `M_EmployeeImage`, `M_EmployeeS_UserID`, `M_EmployeeIsActive`, `M_EmployeeCreated`, `M_EmployeeLastUpdated`) VALUES
(11,	1,	9,	'1234',	'Aab',	NULL,	'0000-00-00',	0,	'Klipang Semarang\nKel. Sendangmulyo',	1,	34354,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'0000-00-00',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'dfdfsdf',	NULL,	0,	'N',	'2024-01-09 13:28:30',	'2024-05-29 04:20:29'),
(12,	1,	18,	'SYS.001',	'System Admin',	NULL,	'1984-02-09',	0,	'Jl. Bukit Sentul, Cijayanti, Kec. Babakan Madang',	64,	1,	'',	'',	'',	'',	NULL,	0,	'2024-01-22',	0,	'',	'',	'',	'',	'',	'',	'Direktur',	NULL,	1,	'Y',	'2024-01-22 13:30:41',	'2024-07-15 16:31:04'),
(13,	2,	9,	NULL,	'Ahmad Abdullah',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	64,	2,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:33:42',	'2024-05-29 04:30:35'),
(14,	2,	9,	NULL,	'Dewi Susanto',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	104,	3,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:34:37',	'2024-05-29 04:30:32'),
(15,	2,	12,	NULL,	'Budi Wijaya',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	64,	4,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:35:18',	'2024-05-29 04:30:42'),
(16,	2,	12,	NULL,	'Anita Dewi',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	64,	5,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:36:00',	'2024-05-29 04:30:39'),
(17,	8,	12,	NULL,	'Rizky Pratama',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	11,	6,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:36:40',	'2024-05-29 04:30:17'),
(18,	8,	13,	NULL,	'Fitriani Cahyani',	NULL,	'2024-04-01',	0,	'Klipang Semarang',	10,	7,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:37:14',	'2024-05-29 04:30:48'),
(19,	8,	13,	NULL,	'Irfan Setiawan',	NULL,	'2024-04-01',	0,	'Jl. Sadang Hegar 1 Gang Menara Air 1 no 23 rt 6 rw 13',	60,	8,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'null',	NULL,	8,	'N',	'2024-04-18 09:37:47',	'2024-05-29 04:30:51'),
(20,	8,	13,	NULL,	'Nia Putri',	NULL,	'2024-04-01',	0,	'Lab HBLC',	246,	9,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2024-04-01',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'N',	'2024-04-18 09:38:18',	'2024-05-29 04:30:28'),
(21,	10,	9,	NULL,	'Cici Cahyani',	NULL,	'2002-05-15',	0,	'Jl. Spool 24',	64,	10,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2023-05-10',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'',	NULL,	0,	'N',	'2024-05-28 16:19:01',	'2024-05-29 04:30:45'),
(22,	1,	18,	'1234',	'Satrio',	NULL,	'1987-08-12',	0,	'Jl. Bukit Sentul, Cijayanti, Kec. Babakan Madang',	64,	34354,	'',	'',	'',	'',	NULL,	0,	'2021-08-25',	0,	'',	'',	'',	'',	'',	'',	'Direktur',	NULL,	8,	'N',	'2024-01-09 13:28:30',	'2024-07-13 05:33:40'),
(23,	2,	3,	NULL,	'Jupdate',	NULL,	'1990-05-15',	0,	'456 Oak Avenue',	1,	11,	NULL,	NULL,	NULL,	NULL,	NULL,	0,	'2020-01-10',	0,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'Updated note',	NULL,	9,	'N',	'2024-06-05 02:11:13',	'2024-07-10 23:08:10'),
(24,	2,	18,	'null',	'Admin HR',	NULL,	'1997-05-07',	0,	'Jl. Gatot Subroto KM. 8 No. 35, Manis Jaya',	21,	12,	'',	'',	'',	'',	NULL,	0,	'2022-05-04',	0,	'',	'',	'',	'',	'',	'',	'Admin HR',	NULL,	10,	'N',	'2024-07-03 06:01:22',	'2024-07-11 07:10:53'),
(25,	2,	12,	'',	'Sales 1',	NULL,	'1998-05-20',	0,	'Jl. Gatot Subroto KM. 8 No. 35, Manis Jaya',	41,	13,	'',	'',	'',	'',	NULL,	0,	'2024-02-01',	0,	'',	'',	'',	'',	'08161645301',	'',	'',	NULL,	0,	'N',	'2024-07-10 23:19:36',	'2024-07-11 07:10:49'),
(26,	1,	9,	'D032301',	'PUJI SANTOSO',	NULL,	'1995-03-08',	0,	'REJOSARI BARU RT 001 RW 005 GEMULAK SAYUNG DEMAK',	88,	14,	'3321040803950007',	'3321040909200008',	'-',	'-',	NULL,	0,	'2019-10-01',	0,	'UNIVERSITAS NEGERI SEMARANG',	'TEKNIK SIPIL',	'SULASTRI',	'PRESTIYA',	'085741486405',	'ISTRI',	'PROJECT MANAGER',	NULL,	11,	'Y',	'2024-07-11 07:39:56',	'2024-07-11 07:42:08'),
(27,	2,	9,	'D032303',	'TRI CAHYONO FAKHRI',	NULL,	'1994-02-19',	0,	'PEDURUNGAN KIDUL RT/RW:006/012, KEL. PEDURUNGAN KIDUL, KEC. PEDURUNGAN, KOTA SEMARANG',	104,	15,	'3319021902940002',	'3374061903180011',	'591677267',	'22018868202',	NULL,	0,	'2021-01-18',	0,	'UNIVERSITAS SEMARANG',	'TEKNIK SIPIL',	'SUMIYATI',	'NURHAYATI',	'082150755517',	'ISTRI',	'KEPALA STUDIO 1',	NULL,	12,	'Y',	'2024-07-11 07:57:39',	'2024-07-11 07:57:39'),
(28,	2,	9,	'D032304',	'ISMAIL HARSENO',	NULL,	'1993-06-01',	0,	'KANDRI RT01/RW01',	104,	16,	'3316050106930002',	'3374121107230001',	'-',	'23126786864',	NULL,	0,	'2022-07-11',	0,	'UNIVERSITAS NEGERI SEMARANG',	'TEKNIK ARSITEKTUR',	'SUGIANTINI',	'YULI WINARNI',	'089670490672',	'ISTRI',	'MAPPING',	NULL,	13,	'Y',	'2024-07-11 08:05:58',	'2024-07-11 08:05:58'),
(29,	2,	9,	'D032305',	'ABDUL ROHKIM',	'L',	'1995-12-06',	0,	'BANGETAYU MULYO RT 002/002 BANGETAYU WETAN GENUK SEMARANG',	104,	17,	'3374050612950007',	'3374050706220002',	'2344266999',	'22018868343',	'212121212',	8,	'2021-12-08',	0,	'UNIVERSITAS MERCU BUANA JAKARTA',	'TEKNIK SIPIL',	'FISKA EMILA',	'-',	'08977082420',	'ISTRI',	'KEPALA STUDIO 2',	'default-avatar.png',	14,	'Y',	'2024-07-12 02:13:14',	'2024-08-27 08:08:09'),
(30,	2,	9,	'D032309',	'GALANG ADILANMAS',	NULL,	'2000-09-20',	0,	'JL. RM HADI SOEBENO S. RT/3 RW2, KEL. MIJEN, KEC. MIJEN, KOTA SEMARANG.',	104,	18,	'3374142009000001',	'3374141212054833',	'-',	'22018868327',	NULL,	0,	'2020-10-20',	0,	'SMK NEGERI 7 SEMARANG',	'TEKNIK GAMBAR BANGUNAN',	'SRI RIWAYATI',	'SRI RIWAYATI',	'087839279604',	'IBU KANDUNG',	'DRAFTER INTERIOR 2',	NULL,	15,	'Y',	'2024-07-12 02:17:18',	'2024-07-12 02:17:18'),
(31,	2,	9,	'D032310',	'GHANI RIZKI DARUSSALAM',	NULL,	'2003-07-07',	0,	'JL. SAMRATULANGI RT.03 RW.09 KEL. PASAR BATANG, KEC. BREBES, KAB. BREBES',	86,	19,	'3329090707030003',	'3329091212170031',	'-',	'3329090707030003',	NULL,	0,	'2021-05-14',	0,	'SMK NEGERI 1 ADIWERNA',	'DESAIN PEMODELAN DAN INFORMASI BANGUNAN',	'SARI MURNI',	'GHANI SAYID HAMZAH',	'0895322239123',	'KAKAK KANDUNG',	'DRAFTER STRUKTUR/MEP 1',	NULL,	16,	'Y',	'2024-07-12 02:21:14',	'2024-07-12 02:21:14'),
(32,	2,	9,	'D032311',	'DIMAS AJI PRAYOGA',	NULL,	'2002-06-03',	0,	'JL. PALA BARAT 4A NO 665',	108,	20,	'2171090306029009',	'3328150802180005',	'-',	'2171090306029009',	NULL,	0,	'2021-07-24',	0,	'SMK NEGERI 1 ADIWERNA',	'DESAIN PEMODELAN DAN INFORMASI BANGUNAN',	'BADRIYAH',	'BADRIYAH',	'082324679914',	'IBU KANDUNG',	'DRAFTER ARSITEK 2',	NULL,	17,	'Y',	'2024-07-12 02:25:03',	'2024-07-12 02:25:03'),
(33,	2,	9,	'D032312',	'FAHMA IBNULKHAK',	NULL,	'2003-05-28',	0,	'DESA KADEMANGARAN, KEC DUKUHTURI, KAB TEGAL',	108,	21,	'3328132805030003',	'3328132102081859',	'-',	'22018868350',	NULL,	0,	'2021-12-20',	0,	'SMK NEGERI 1 ADIWERNA',	'DESAIN DAN PEMODELAN INFORMASI BANGUNAN',	'MASKUROH',	'MASKUROH',	'085640252074',	'IBU KANDUNG',	'DRAFTER STRUKTUR/MEP 2',	NULL,	18,	'Y',	'2024-07-12 02:28:18',	'2024-07-12 02:28:18'),
(34,	2,	9,	'D032314',	'MOH SAEFUL HAKIM',	NULL,	'2002-08-06',	0,	'JALAN SADEWA DESA PENGABEAN KEC.DUKUHTURI KAB.TEGAL',	108,	22,	'3328130608020003',	'3328134910730001',	'-',	'23126786872',	NULL,	0,	'2022-09-02',	0,	'SMK NEGERI 1 ADIWERNA',	'DESAIN PERMODELAN DAN INFORMASI BANGUNAN',	'SAEMI',	'SAEMI',	'088988514373',	'IBU KANDUNG',	'DRAFTER INTERIOR 1',	NULL,	19,	'Y',	'2024-07-12 02:32:26',	'2024-07-12 02:32:26'),
(35,	1,	11,	'D032315',	'MUHAMMAD RISAL HIDAYAT',	NULL,	'1993-06-09',	0,	'KP SELAAWI RT 08 RW 05 DESA SELAJAMBE KECAMATAN CISAAT KABUPATEN SUKABUMI',	78,	23,	'3202290906930002',	'3202291611210005',	'-',	'-',	NULL,	0,	'2019-08-01',	0,	'UNIVERSITAS PANCASILA',	'ARSITEKTUR',	'ROS ROSITA',	'RIA RAHAYU',	'085795945156',	'ISTRI',	'PRINCIPAL ARSITEK',	NULL,	20,	'Y',	'2024-07-12 02:35:29',	'2024-07-12 02:35:29'),
(36,	1,	11,	'D032318',	'MUHAMMAD WIDAD BAYUADI',	NULL,	'1997-05-06',	0,	'NGANJUK',	128,	24,	'3518130605970003',	'3518132305070007',	'109388643',	'-',	NULL,	0,	'2022-02-02',	0,	'UNIVERSITAS DIPONEGORO',	'ARSITEKTUR',	'ASTI',	'FAHRI',	'081357074750',	'ADIK KANDUNG',	'MANAGER ARSITEK',	NULL,	21,	'Y',	'2024-07-12 02:41:46',	'2024-07-12 06:30:18'),
(37,	2,	11,	'D032319',	'MUHAMAD IZWAN SAPUTRA',	NULL,	'1997-03-28',	0,	'KOMP PERUM TELUK MULUS GG.PENDIDIKAN BLOK T NO 15 RT 009 RW 005',	64,	25,	'6112012803970002',	'3271042403230017',	'-',	'-',	NULL,	0,	'2022-07-11',	0,	'UNIVERSITAS TEKNOLOGI YOGYAKARTA',	'ARSITEKTUR',	'INZALIA',	'AYU WIDYANTI',	'085747191318',	'ISTRI ',	'PIC ARSITEK 3',	NULL,	22,	'Y',	'2024-07-12 03:01:03',	'2024-07-12 03:01:03'),
(38,	2,	11,	'D032320',	'BURHANUDIN',	NULL,	'1996-04-15',	0,	'PERUM MADURESO INDAH RT 2 RW 7 MADURESO TEMANGGUNG',	109,	26,	'3323031504960006',	'3323030706220003',	'2772628378',	'-',	NULL,	0,	'2022-07-25',	0,	'UNIVERSITAS TEKNOLOGI YOGYAKARTA',	'ARSITEKTUR',	'ASIH WIDAYATI',	'DYANINGTYAS RATNA DEWI',	'085742476621',	'ISTRI',	'PIC ARSITEK 4',	NULL,	23,	'Y',	'2024-07-12 06:33:40',	'2024-07-12 06:33:40'),
(39,	2,	11,	'D032321',	'SAEPUL ALAM',	NULL,	'1993-02-04',	0,	'JL. SUKAKARYA BABAKAN NO. 3 KEL. SUKAKARYA KEC. WARUDOYONG KOTA SUKABUMI',	78,	27,	'3202342604930002',	'3272041109200011',	'-',	'-',	NULL,	0,	'2022-01-08',	0,	'UNIVERSITAS BUNG KARNO',	'TEKNIK ARSITEKTUR',	'DINI HERAWATI',	'-',	'085217898611',	'ISTRI',	'PIC ARSITEK 2',	NULL,	24,	'Y',	'2024-07-12 06:36:42',	'2024-07-12 06:36:42'),
(40,	2,	11,	'D032322',	'M THOHIR MUZAKKI',	NULL,	'1998-09-01',	0,	'CARUBAN 003/004, KEC. RINGINARUM, KAB. KENDAL',	93,	28,	'3324180901980001',	'3324181004230002',	'-',	'22018868210',	NULL,	0,	'2021-07-01',	0,	'UNIVERSITAS PGRI SEMARANG',	'ARSITEKTUR',	'KOMARIYAH',	'KOMARIYAH',	'087834551350',	'IBU KANDUNG',	'JUNIOR ARSITEK',	NULL,	25,	'Y',	'2024-07-12 06:39:38',	'2024-07-12 06:39:38'),
(41,	2,	19,	'D032325',	'FAISAL HABIBI',	NULL,	'1994-07-22',	0,	'PERUMAHAN PONDOK DUTA 1 JALAN MAHKOTA 2 NOMOR 18A.',	69,	29,	'3276022207940011',	'081298411818',	'2061632081',	'-',	NULL,	0,	'2021-02-20',	0,	'UNIVERSITAS GUNADARMA',	'ARSITEKTUR',	'MASHITOH',	'MIFTAHUL KHOIRUNNISA',	'081298411818',	'ISTRI',	'PIC INTERIOR 3',	NULL,	26,	'Y',	'2024-07-12 06:42:39',	'2024-07-17 02:55:15'),
(42,	2,	19,	'D032327',	'R HERNANDA ADE WIBAWA',	NULL,	'1996-05-21',	0,	'JL. EMPU SENDOK PERUM MEGA BUKIT MAS C8 PUDAKPAYUNG BANYUMANIK SEMARANG',	104,	30,	'3373032105960002',	'3374111102150009',	'-',	'-',	NULL,	0,	'2022-09-01',	0,	'POLITEKNIK NEGERI SEMARANG',	'TEKNIK SIPIL',	'RATNA EDY TJAHYANI',	'RATNA EDY TJAHYANI',	'08988060504',	'IBU KANDUNG',	'PIC INTERIOR 3',	NULL,	27,	'Y',	'2024-07-12 06:46:18',	'2024-07-17 02:57:14'),
(43,	1,	13,	'D032337',	'DWIKY DARMAWAN',	NULL,	'1993-12-27',	0,	'KP STRONG 37 SEMARANG',	104,	31,	'3374032712930002',	'3374031412050663',	'2234265568',	'22018868277',	NULL,	0,	'2020-11-01',	0,	'UNIVERSITAS DIPONEGORO',	'AKUNTANSI',	'SRI LEGIYEM',	'SUPRAPTO',	'0243542590',	'AYAH',	'CHIEF FINANCE OFFICER',	NULL,	28,	'Y',	'2024-07-12 07:36:50',	'2024-07-15 02:52:23'),
(44,	1,	20,	'D032329',	'NALENDRA EZRA ABHIBHAWA',	NULL,	'1997-06-09',	0,	'JL. CEMPOLOREJO 4/16, RT/RW 003/003, KROBOKAN, SEMARANG BARAT, KOTA SEMARANG',	104,	32,	'3374130906970006',	'3374132112110019',	'-',	'22018868442',	NULL,	0,	'2021-09-27',	0,	'UNIVERSITAS ISLAM INDONESIA',	'AKUNTANSI',	'SRI HASTUTI',	'SRI HASTUTI',	'085939202955',	'IBU KANDUNG',	'MANAGER MARKETING',	NULL,	29,	'Y',	'2024-07-12 07:40:09',	'2024-07-17 02:56:49'),
(45,	2,	20,	'D032330',	'DINO PRABANGKARA',	NULL,	'1993-06-07',	0,	'PERUM KLIPANG BLOK W1A NO.2 KEL.SENDANGMULYO - KEC. TEMBALANG',	104,	33,	'3316050607930001',	'3374103010190008',	'91675618',	'22018868368',	NULL,	0,	'2021-01-12',	0,	'UNIVERSITAS NEGERI SEMARANG',	'PENDIDIKAN SENI RUPA',	'MURDIWATI',	'KLARA YUNITA ',	'082243318988',	'ISTRI',	'DESAINER VISUAL CETAK',	NULL,	30,	'Y',	'2024-07-12 07:43:44',	'2024-07-17 02:54:53'),
(46,	1,	20,	'D032331',	'MUHAMMAD IBRAHIM USMAN',	NULL,	'1997-07-07',	0,	'JALAN TAMAN PAHLAWAN NO. 67 SALATIGA',	103,	34,	'3373020707970003',	'3373020311080003',	'0002910503362',	'-',	NULL,	0,	'2021-06-07',	0,	'INSTITUT SENI INDONESIA YOGYAKARTA',	'DESAIN KOMUNIKASI VISUAL',	'DWI ATMAWATI',	'MUHAMMAD ABIY ZAIN',	'085601520005',	'ADIK KANDUNG',	'CHIEF MARKETING OFFICER',	NULL,	31,	'Y',	'2024-07-12 07:47:05',	'2024-07-17 02:56:24'),
(47,	2,	20,	'D032332',	'BAYU NUGROHO',	NULL,	'1995-07-20',	0,	'JL. PARANG KUSUMO VI/15 TLOGOSARI SEMARANG',	104,	35,	'3374062007950004',	'3374062905230015',	'-',	'22031252657',	NULL,	0,	'2022-01-10',	0,	'UNIVERSITAS SEMARANG',	'ILMU HUKUM',	'PARSINI',	'CLAUDIA KINTAN PM',	'085729896100',	'ISTRI',	'SOCIAL MEDIA SPECIALIST 1',	NULL,	32,	'Y',	'2024-07-12 07:51:42',	'2024-07-17 02:54:40'),
(49,	2,	20,	'D032333',	'ADITYA TRI NOVIANTO',	NULL,	'1996-11-29',	0,	'BUKIT MANYARAN PERMAI C1/35',	104,	37,	'3374122911960001',	'3374122001090004',	'206750496',	'22031252640',	NULL,	0,	'2022-01-01',	0,	'SMAN 14 SEMARANG',	'-',	'SITI MUSLIMAH',	'FREDIAN BINTAR',	'6289667550905',	'KAKAK KANDUNG',	'SOCIAL MEDIA SPECIALIST 2',	NULL,	33,	'Y',	'2024-07-12 07:55:50',	'2024-07-17 02:54:22'),
(50,	2,	20,	'D032335',	'AGUS ASNAFI',	NULL,	'1993-11-03',	0,	'LINGKUNGAN KARANGJATI RT/RW : 003/007 KEL/DESA KARANGJATI KECAMATAN BERGAS',	104,	38,	'3307010311930006',	'3322132806220005',	'-',	'-',	NULL,	0,	'2020-07-01',	0,	'UNIVERSITAS NEGERI SEMARANG',	'TEKNIK KIMIA',	'THOBINGAH',	'NOVIN',	'085729769747',	'ISTRI',	'VIDEO EDITOR',	NULL,	34,	'Y',	'2024-07-12 08:01:54',	'2024-07-17 02:54:03'),
(51,	2,	20,	'D032336',	'ALFIANSYAH',	NULL,	'1999-07-09',	0,	'PERUM GRAND CIKARANG CITY BLOK F34/19, KARANGRAHARJA, CIKARANG UTARA, KAB. BEKASI',	63,	39,	'3216080907990009',	'3216091508140011',	'72646593',	'23039520491',	NULL,	0,	'2022-08-29',	0,	'UNIVERSITAS DIPONEGORO',	'SASTRA INDONESIA',	'MUHTIRI',	'MUHTIRI',	'08128218428',	'IBU KANDUNG',	'COPYWRITER',	NULL,	35,	'Y',	'2024-07-12 08:04:40',	'2024-07-17 02:54:12'),
(52,	2,	20,	'D032341',	'NAUFAL ANDI YODHA PRATAMA',	NULL,	'2001-03-21',	0,	'TMN PURI SARTIKA BLOK G-12, RT 06/RW 12, SUKOREJO, GUNUNGPATI, SEMARANG',	104,	40,	'3374122103010004',	'3374121212053107',	'1789520567',	'-',	NULL,	0,	'2023-02-01',	0,	'UNIVERSITAS DIAN NUSWANTORO SEMARANG',	'DESAIN KOMUNIKASI VISUAL',	'YUNITA SURYANI EKA DEWI',	'ANDI PURWOYUWONO',	'081226660578',	'AYAH',	'DESAINER VISUAL DIGITAL 1 (SIBAMBO)',	NULL,	36,	'Y',	'2024-07-12 08:18:03',	'2024-08-19 07:43:19'),
(53,	2,	20,	'D032342',	'RADEN REYHAN ZHAFRAN SOFYAN',	NULL,	'1999-04-08',	0,	'JALAN KAPTEN HALIM RT/RW 017/009 KELURAHAN NAGRI KIDUL, KECAMATAN PURWAKARTA, KABUPATEN PURWAKARTA',	76,	41,	'3214010408990002',	'3214011608180006',	'0000063410308',	'22141057798',	NULL,	0,	'2022-09-27',	0,	'SEKOLAH TINGGI TEKNOLOGI KEDIRGANTARAAN',	'MANAJEMEN TRANSPORTASI UDARA',	'SUHARTI',	'RADEN FANNY MEGAYANTI',	'081222421399',	'KAKAK KANDUNG',	'SOCIAL MEDIA SPECIALIST 3',	NULL,	37,	'Y',	'2024-07-12 08:21:03',	'2024-07-17 02:57:24'),
(54,	2,	20,	'D032343',	'DJULI PAMUNGKAS ',	NULL,	'1991-07-06',	0,	'JALAN TULIP 2 NO 9 RT 3 RW 4 RANCAEKEK KENCANA KABUPATEN BANDUNG 40394',	493,	42,	'3211200607910002',	'3204282708200028',	'1443203065',	'14001322651000',	NULL,	0,	'2023-06-01',	0,	'UNIVERSITAS ISLAM NEGERI SUNAN GUNUNG DJATI BANDUNG',	'ILMU KOMUNIKASI JURNALISTIK',	'NANI',	'SHABRINA PUSPARANI',	'085721487333',	'ISTRI',	'PHOTOGRAPHER',	NULL,	38,	'Y',	'2024-07-12 08:24:26',	'2024-07-17 02:54:58'),
(55,	2,	19,	'D032345',	'MUHAMMAD NAUFAL HILMY',	NULL,	'1997-01-07',	0,	'PAKELAN RT03/02 KARANGDUREN SAWIT BOYOLALI',	85,	43,	'3309080701979001',	'3309081511110001',	'1432729528',	'-',	NULL,	0,	'2023-09-01',	0,	'UNIVERSITAS SEBELAS MARET',	'ARSITEKTUR',	'HENDRI PRAMUNINGSIH',	'IDHA',	'085647095858',	'KAKAK KANDUNG',	'PIC INTERIOR 2',	NULL,	39,	'Y',	'2024-07-12 08:28:12',	'2024-07-17 02:56:35'),
(56,	2,	11,	'D032346',	'AKMAL MAULANA',	NULL,	'2002-12-27',	0,	'JL. CARINGIN NGUMBANG RT/RW 003/008 KEL. SUKAKARYA, KEC. WARUDOYONG, KOTA SUKABUMI',	78,	44,	'3272042712020899',	'3272040608070469',	'-',	'-',	NULL,	0,	'2024-04-17',	0,	'SMK NEGERI 2 KOTA SUKABUMI',	'TEKNIK KOMPUTER & JARINGAN',	'DEASY ARIANTHY',	'DEASY ARIANTHY',	'085724181587',	'IBU KANDUNG',	'DRAFTER PRADESAIN & PBG 1',	NULL,	40,	'Y',	'2024-07-12 08:32:25',	'2024-07-12 08:32:25'),
(57,	2,	18,	'D032347',	'MUHAMMAD ABIY ZAIN',	NULL,	'2000-03-02',	0,	'JL. TAMAN PAHLAWAN NO. 67 RT 012/RW 005, KUTOWINANGUN LOR, KEC. TINGKIR, KOTA SALATIGA',	103,	45,	'3373020202000002',	'3373020311080003',	'2910503553',	'22090209549',	NULL,	0,	'2024-04-24',	0,	'UNIVERSITAS NEGERI YOGYAKARTA',	'MANAJEMEN',	'DWI ATMAWATI',	'DWI ATMAWATI',	'085841669820',	'IBU KANDUNG',	'HUMAN CAPITAL OFFICER',	NULL,	41,	'Y',	'2024-07-12 08:36:00',	'2024-07-12 08:36:00'),
(58,	2,	9,	'D032349',	'RIDHO ROMDANI',	NULL,	'1999-02-07',	0,	'DUSUN 2 WUKIRSARI TUGUMULYO',	447,	46,	'1605010702990002',	'1605012001090002',	'-',	'-',	NULL,	0,	'2024-05-25',	0,	'UNIVERSITAS MUHAMMADIYAH PALEMBANG',	'ARSITEKTUR',	'ROHMAH',	'ROMLI',	'085664702425',	'AYAH',	'DRAFTER ARSITEK 1',	NULL,	42,	'Y',	'2024-07-12 08:44:05',	'2024-07-12 08:44:05'),
(59,	2,	11,	'D032350',	'MUHAMAD GUNAWAN',	NULL,	'2001-03-10',	0,	'KP UNDRUS RT 02 RW 01 DESA UNDRUS BINANGUN KEC.KADUDAMPIT KAB. SUKABUMI',	78,	47,	'3202301003010001',	'3202301310090015',	'-',	'-',	NULL,	0,	'2024-05-01',	0,	'SMK NEGERI 1 SUKABUMI',	'TEKNIK KONSTRUKSI BATU DAN BETON',	'AIDAH',	'APUD SAEPUDIN',	'085863556034',	'AYAH',	'DRAFTER PRADESAIN & PBG 2',	NULL,	43,	'Y',	'2024-07-12 09:26:33',	'2024-07-12 09:26:33'),
(60,	2,	9,	'D032351',	'BAYU DWI AGUSTINO',	NULL,	'2005-08-13',	0,	'KP. BARUROKE RT/RW 001/002 KEL/DESA PERBAWATI KECAMATAN SUKABUMI',	78,	48,	'3202321308050001',	'3202320908071898',	'-',	'-',	NULL,	0,	'2024-05-20',	0,	'SMK NEGERI 1 KOTA SUKABUMI',	'DESAIN PERMODELAN DAN INFORMASI BANGUNAN',	'RESYA EKA FUJIANTI',	'YANTO SURYANTO',	'085798721382',	'AYAH',	'DRAFTER STRUKTUR/MEP 3',	NULL,	44,	'Y',	'2024-07-12 09:30:17',	'2024-07-12 09:30:17'),
(61,	2,	9,	'D032352',	'M DARWISY REDHIA ALHAURA ',	NULL,	'2004-12-28',	0,	'KP. CIKARET, RT/RW 04/01, DESA SUKAMEKAR, KEC. SUKARAJA',	78,	49,	'3202332812040001',	'3202333010080014',	'-',	'-',	NULL,	0,	'2024-05-20',	0,	'SMK NEGERI 1 KOTA SUKABUMI',	'DESAIN PEMODELAN DAN INFORMASI BANGUNAN',	'MISLIANI',	'MISLIANI',	'081564650621',	'IBU KANDUNG',	'DRAFTER INTERIOR 3',	NULL,	45,	'Y',	'2024-07-12 09:33:18',	'2024-07-12 09:33:18'),
(62,	2,	9,	'D032353',	'M ILHAM MAULANA',	NULL,	'2006-01-29',	0,	'JL. PEMANDIAN CIGUNUNG KM. 4 , KP. BABAKAN PARI RT38/17, DESA SUKARESMI, KEC. CISAAT, KAB. SUKABUMI',	78,	50,	'3202292901060009',	'3202291108076304',	'-',	'-',	NULL,	0,	'2024-05-20',	0,	'SMK NEGERI 1 KOTA SUKABUMI',	'DESAIN PEMODELAN DAN INFORMASI BANGUNAN',	'LISMA',	'LISMA',	'083856705409',	'IBU KANDUNG',	'DRAFTER INTERIOR 4',	NULL,	46,	'Y',	'2024-07-12 09:38:45',	'2024-07-12 09:38:45'),
(63,	2,	9,	'D032354',	'FAJAR AFRIANSHAH',	NULL,	'1998-04-17',	0,	'DUSUN TGK. DITANGGOH DESA DEUAH KECAMATAN SAMATIGA KABUPATEN ACEH BARAT',	242,	51,	'1105051704980001',	'1105052108063224',	'979288007',	'-',	NULL,	0,	'2024-06-03',	9,	'UNIVERSITAS ABULYATAMA',	'TEKNIK SIPIL',	'SAFINATUL HELMI',	'ISHAK',	'6285275903341',	'AYAH KANDUNG',	'AHLI STRUKTUR 1',	NULL,	47,	'Y',	'2024-07-12 09:42:08',	'2024-08-19 08:23:18'),
(64,	2,	19,	'D032355',	'MUHAMAD FIKRI SYAHRUDIN',	NULL,	'1997-03-14',	0,	'KP. CIBADAK RT 001/001 DES.CIJERUK KEC.CIJERUK KAB.BOGOR',	64,	52,	'3201281403970003',	'3201280207070087',	'-',	'-',	NULL,	0,	'2024-06-19',	0,	'UNIVERSITAS GUNADARMA',	'ARSITEKTUR',	'AMELIA',	'AMELIA',	'085817083664',	'IBU KANDUNG',	'PIC INTERIOR 4',	NULL,	48,	'Y',	'2024-07-12 09:46:16',	'2024-07-17 02:55:53'),
(65,	1,	12,	'D030000',	'ADMIN',	NULL,	'1984-02-09',	0,	'Jl. Bukit Sentul, Cijayanti, Kec. Babakan Madang',	64,	1,	'',	'',	'',	'',	NULL,	0,	'2024-01-22',	0,	'',	'',	'',	'',	'',	'',	'Direktur',	NULL,	10,	'Y',	'2024-01-22 13:30:41',	'2024-07-18 09:38:36'),
(66,	1,	12,	'D032328',	'TEGAR IMAM MUSTAQIEM',	NULL,	'1994-02-04',	0,	'JL KAKAP I /62-A RT 08 RW 01 KUNINGAN SEMARANG UTARA',	104,	53,	'3374130204940002',	'3374022009210013',	'-',	'-',	NULL,	0,	'2019-01-09',	0,	'UNIVERSITAS NEGERI SEMARANG',	'TEKNIK SIPIL',	'SUGIARTI',	'NOVI ANNA',	'082246076161',	'ISTRI',	'MANAGER SALES',	NULL,	49,	'Y',	'2024-07-15 03:07:22',	'2024-07-15 03:11:24'),
(67,	2,	12,	'D032339',	'RAMDHANUL FAJRI',	NULL,	'1991-03-23',	0,	'JL. ASSOFA II RT006/001 KEBON JERUK JAKBAR',	38,	54,	'3173052303910002',	'3173050909200004',	'-',	'-',	NULL,	0,	'2023-01-01',	0,	'UNIVERSITAS BUDI LUHUR',	'MANAJEMEN KEUANGAN',	'WIDRAWATI',	'YOPI',	'081285471820',	'ISTRI',	'ACCOUNT EXECUTIVE 1',	NULL,	50,	'Y',	'2024-07-15 03:11:01',	'2024-07-15 03:11:01'),
(68,	2,	20,	'D032356',	'ZULFIKAR RISQI NOERMARTANTO',	NULL,	'1998-10-19',	0,	'JL CEMPOLOREJO 4 NO 11',	104,	55,	'3374131910980004',	'3374131612050572',	'-',	'-',	NULL,	0,	'2024-07-02',	0,	'UNIVERSITAS ISLAM NEGERI WALISONGO SEMARANG',	'PSIKOLOGI',	'ISTIANAH',	'ANDI NOERMARTANTO',	'081953910254',	'AYAH',	'ADVERTISER',	NULL,	51,	'Y',	'2024-07-15 08:07:54',	'2024-07-17 02:57:50'),
(69,	2,	11,	'D032316',	'M ALVIANO RIZQIA PUTRA YAFENZHA',	NULL,	'1998-06-24',	0,	'JL. LASWI NO.276 KEL. WARGA MEKAR, KEC. BALEENDAH',	493,	56,	'3204322406980006',	'3204322406980006',	'-',	'-',	NULL,	0,	'2021-01-02',	0,	'UNIVERSITAS KOMPUTER INDONESIA',	'ARSITEKTUR',	'EFRIANI',	'RAHMA PUTRI',	'081229084514',	'ISTRI',	'PIC ARSITEK 1',	NULL,	52,	'Y',	'2024-07-16 03:58:36',	'2024-07-16 03:58:36'),
(70,	2,	12,	'D032338',	'ACHMAD NUR SETIAWAN',	NULL,	'1995-09-03',	0,	'BUKIT BERINGIN LESTARI 3 B/90',	104,	57,	'3374010309950002',	'3374150501230007',	'-',	'-',	NULL,	0,	'2023-03-13',	0,	'UNIVERSITAS SEMARANG',	'AKUNTANSI',	'-',	'MUH RIFAI',	'082186915153',	'KAKAK KANDUNG',	'ACCOUNT EXECUTIVE 2',	NULL,	53,	'Y',	'2024-07-16 04:04:55',	'2024-07-16 04:04:55'),
(71,	2,	20,	'D032344',	'MUHAMMAD RIZKI TRIYANA SATIA',	NULL,	'1993-08-03',	0,	'JL. BAKUNG XV NO.26 RT.02 RW.10 KEL. RANCAEKEK KENCANA KEC. RANCAEKEK ',	493,	58,	'3272040308930962',	'3204281312230011',	'2450129848',	'-',	NULL,	0,	'2023-06-01',	9,	'UNIVERSITAS ISLAM NEGERI SUNAN GUNUNG DJATI BANDUNG',	'ILMU KOMUNIKASI JURNALISTIK',	'META DWIKORI GANDAMIHARJA',	'WIDYANA MARDANI',	'628871647569',	'ISTRI',	'VIDEOGRAPHER',	NULL,	54,	'Y',	'2024-08-08 07:54:33',	'2024-08-08 07:54:33'),
(72,	2,	9,	'D032348',	'MUHAMMAD GHOZALI HIDAYAT',	NULL,	'2001-04-29',	0,	'PANCAKARYA BLOK 20/266 RT 008 RW 004, REJOSARI, SEMARANG TIMUR',	104,	59,	'3374032904010005',	'3374036605710003',	'-',	'-',	NULL,	0,	'2024-04-26',	5,	'SMK NEGERI 7 SEMARANG ',	'TEKNIK GAMBAR BANGUNAN ',	'NOOR HIDAYATI',	'MUHAMMAD ABDUL WAHID',	'085640116080',	'SAUDARA',	'MAPPING 2',	NULL,	55,	'Y',	'2024-08-14 03:39:40',	'2024-08-14 03:39:40'),
(73,	2,	12,	'D032357',	'RIZQI PRADANA PUTRA',	NULL,	'1992-06-21',	0,	'CLUSTER CIMANGGIS GREEN MANSION, MEKARSARI, DEPOK',	69,	60,	'3524142106920001',	'3276020703190006',	'-',	'-',	NULL,	0,	'2024-08-06',	9,	'INSTITUT PERTANIAN BOGOR',	'ILMU KONSUMEN',	'NI\'MA YUHA',	'INDAH',	'0895385263447',	'ISTRI',	'ACCOUNT EXECUTIVE 3',	NULL,	56,	'Y',	'2024-08-19 07:30:58',	'2024-08-19 07:34:20'),
(74,	2,	12,	'D032358',	'MUHAMAD NURUL ALIM',	NULL,	'1995-01-04',	0,	'KP CIPUTRI 01/08 SINGASARI SINGAPARNA KAB TASIKMALAYA',	80,	61,	'3206240401950003',	'3206242502210002',	'-',	'-',	NULL,	0,	'2024-08-06',	9,	'SEKOLAH TINGGI TEKNOLOGI CIPASUNG',	'TEKNIK INDUSTRI',	'CUCU CAHYANI',	'SALMA',	'081223767690',	'ISTRI',	'ACCOUNT EXECUTIVE 4',	NULL,	57,	'Y',	'2024-08-19 07:34:03',	'2024-08-19 07:34:03'),
(75,	2,	20,	'D032359',	'YUCHAIDAR MAULANA ACHMAD',	NULL,	'1997-12-04',	0,	'JLN SUPIT URANG UTARA 5, 001/001, KEL. MOJOROTO, KEC. MOJOROTO, KOTA KEDIRI JAWA TIMUR',	121,	62,	'3571010412970003',	'3571011305067743',	'2685527021',	'-',	NULL,	0,	'2024-08-19',	9,	'INSTITUT SENI INDONESIA SURAKARTA',	'DESAIN KOMUNIKASI VISUAL',	'LILIK MUDJI RAHAJU',	'EKA ANGGITA RAHMADANI',	'089609113966',	'CALON ISTRI',	'DESAINER VISUAL DIGITAL 2 (SICONS)',	NULL,	58,	'Y',	'2024-08-19 07:41:59',	'2024-08-19 07:43:04'),
(76,	2,	20,	'D032360',	'MUHAMMAD IRFAN DHIYA\'ULHAQ',	NULL,	'2001-05-26',	0,	'PERUM PURNAMANDALA BLOK N3 RT 02 RW 05, BUMIRESO, WONOSOBO, WONOSOBO, JAWA TENGAH',	111,	63,	'3307092605010006',	'3307092101080437',	'-',	'24024203051',	NULL,	0,	'2024-08-19',	9,	'UNIVERSITAS NEGERI YOGYAKARTA',	'MANAJEMEN',	'WIHARYANI',	'LUQMAN NUR SHAFLY',	'085640434334',	'SAUDARA KANDUNG',	'DESAINER VISUAL DIGITAL 3 (SIRIORS)',	NULL,	59,	'Y',	'2024-08-19 07:48:14',	'2024-08-19 07:48:14');

DROP TABLE IF EXISTS `m_position`;
CREATE TABLE `m_position` (
  `M_PositionID` int NOT NULL AUTO_INCREMENT,
  `M_PositionS_CompanyID` int NOT NULL DEFAULT '0',
  `M_PositionCode` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_PositionName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_PositionNote` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `M_PositionIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  `M_PositionCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `M_PositionLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`M_PositionID`),
  KEY `M_PositionS_CompanyID` (`M_PositionS_CompanyID`),
  KEY `M_PositionCode` (`M_PositionCode`),
  KEY `M_PositionName` (`M_PositionName`),
  KEY `M_PositionIsActive` (`M_PositionIsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `m_position` (`M_PositionID`, `M_PositionS_CompanyID`, `M_PositionCode`, `M_PositionName`, `M_PositionNote`, `M_PositionIsActive`, `M_PositionCreated`, `M_PositionLastUpdated`) VALUES
(1,	0,	'01',	'Direktur Utama',	'Main Director',	'Y',	'2024-01-02 10:05:31',	'2024-02-11 16:36:44'),
(2,	0,	'02',	'Manager',	'Manajer',	'Y',	'2024-01-22 13:05:27',	'2024-02-11 16:37:00'),
(4,	0,	'03',	'Manager',	'manajer',	'N',	'2024-01-22 13:05:44',	'2024-01-22 13:10:10'),
(6,	0,	'04',	'Manager',	'manajer',	'N',	'2024-01-22 13:06:01',	'2024-01-22 13:10:08'),
(8,	0,	NULL,	'Position',	'What a position ok pos',	'Y',	'2024-02-11 16:37:13',	'2024-09-02 09:43:52'),
(9,	0,	NULL,	'CEO',	'CEO',	'Y',	'2024-05-20 10:48:00',	'2024-05-20 10:48:00'),
(10,	0,	NULL,	'pesulap',	'pesulap',	'Y',	'2024-05-21 10:30:17',	'2024-07-23 15:18:06'),
(11,	0,	NULL,	NULL,	NULL,	'Y',	'2024-08-13 16:25:28',	'2024-08-13 16:25:28');

DROP TABLE IF EXISTS `s_company`;
CREATE TABLE `s_company` (
  `S_CompanyID` int NOT NULL AUTO_INCREMENT,
  `S_CompanyCode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `S_CompanyName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `S_CompanyIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  `S_CompanyCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_CompanyLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_CompanyID`),
  KEY `S_CompanyCode` (`S_CompanyCode`),
  KEY `S_CompanyName` (`S_CompanyName`),
  KEY `S_CompanyIsActive` (`S_CompanyIsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `s_company` (`S_CompanyID`, `S_CompanyCode`, `S_CompanyName`, `S_CompanyIsActive`, `S_CompanyCreated`, `S_CompanyLastUpdated`) VALUES
(1,	'4d04436c1fde54f24348bc5b8cc821eb',	'DEFAULT',	'Y',	'2023-06-19 22:02:14',	'2023-06-19 22:02:14');

DROP TABLE IF EXISTS `s_conf`;
CREATE TABLE `s_conf` (
  `S_ConfID` int NOT NULL AUTO_INCREMENT,
  `S_ConfCompanyName` varchar(100) DEFAULT NULL,
  `S_ConfCompanyAddress` varchar(2000) DEFAULT NULL,
  `S_ConfCompanyPhones` varchar(255) DEFAULT NULL,
  `S_ConfCompanyEmail` varchar(100) DEFAULT NULL,
  `S_ConfPIC` varchar(2000) DEFAULT NULL,
  `S_ConfPPN` double NOT NULL DEFAULT '10',
  `S_ConfSiteName` varchar(50) DEFAULT NULL,
  `S_ConfIsActive` char(1) NOT NULL DEFAULT 'Y',
  `S_ConfCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_ConfLastUpdate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_ConfID`),
  KEY `S_ConfIsActive` (`S_ConfIsActive`),
  KEY `S_ConfPPN` (`S_ConfPPN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `s_conf` (`S_ConfID`, `S_ConfCompanyName`, `S_ConfCompanyAddress`, `S_ConfCompanyPhones`, `S_ConfCompanyEmail`, `S_ConfPIC`, `S_ConfPPN`, `S_ConfSiteName`, `S_ConfIsActive`, `S_ConfCreated`, `S_ConfLastUpdate`) VALUES
(1,	'SIBAMBO',	'[{\"name\":\"Office\",\"address\":\"Jl. Mande Raya No. 26 Cikadut Cicaheum Bandung\"},{\"name\":\"Jakarta 1\",\"address\":\"Jl. Kemanggisan Pulo I No. 6 Palmerah Jakarta Barat\"},{\"name\":\"Jakarta 2\",\"address\":\"Jl. Tanah Merdeka No. 80B RT 15 / RW 05 Rambutan, Ciracas Jakarta Timur\"}]',	'[{\"name\":\"Phone / Fax\",\"number\":\"+62(22) 7238019\"},{\"name\":\"Mobile Phone\",\"number\":\"-\"}]',	'adywater@gmail.com',	'{\"delivery\":{\"ack\":21,\"admin\":24},\"invoice\":{\"ack\":25,\"admin\":22}}',	11,	'Ady Water',	'Y',	'2021-09-11 15:59:20',	'2024-01-02 10:05:02');

DROP TABLE IF EXISTS `s_menu`;
CREATE TABLE `s_menu` (
  `S_MenuID` int NOT NULL AUTO_INCREMENT,
  `S_MenuCode` varchar(25) DEFAULT NULL,
  `S_MenuName` varchar(50) DEFAULT NULL,
  `S_MenuUrl` varchar(100) DEFAULT NULL,
  `S_MenuLeft` int NOT NULL DEFAULT '0',
  `S_MenuRight` int NOT NULL DEFAULT '0',
  `S_MenuLevel` int NOT NULL DEFAULT '1',
  `S_MenuIcon` varchar(25) DEFAULT NULL,
  `S_MenuIsActive` char(1) NOT NULL DEFAULT 'Y',
  `S_MenuCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_MenuLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_MenuID`),
  KEY `S_MenuCode` (`S_MenuCode`),
  KEY `S_MenuName` (`S_MenuName`),
  KEY `S_MenuUrl` (`S_MenuUrl`),
  KEY `S_MenuLeft` (`S_MenuLeft`),
  KEY `S_MenuRight` (`S_MenuRight`),
  KEY `S_MenuIsActive` (`S_MenuIsActive`),
  KEY `S_MenuLevel` (`S_MenuLevel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `s_menu` (`S_MenuID`, `S_MenuCode`, `S_MenuName`, `S_MenuUrl`, `S_MenuLeft`, `S_MenuRight`, `S_MenuLevel`, `S_MenuIcon`, `S_MenuIsActive`, `S_MenuCreated`, `S_MenuLastUpdated`) VALUES
(1,	NULL,	'Dashboard',	'/dashboard/d',	1,	2,	1,	'mdi-monitor-dashboard',	'Y',	'2023-06-19 22:20:54',	'2023-06-28 09:32:48'),
(2,	NULL,	'Masterdata',	'#',	21,	40,	1,	'mdi-application',	'Y',	'2023-06-19 22:21:33',	'2024-03-23 23:22:35'),
(4,	NULL,	'Position',	'/master/position',	22,	23,	2,	NULL,	'Y',	'2023-06-19 22:22:03',	'2024-05-28 22:58:41'),
(19,	NULL,	'Project',	'#',	81,	100,	1,	'mdi-projector-screen',	'N',	'2023-06-19 22:21:33',	'2024-09-02 09:35:38'),
(20,	NULL,	'Project',	'/project/main',	82,	83,	2,	NULL,	'N',	'2023-06-19 22:22:03',	'2024-09-02 09:35:38'),
(21,	NULL,	'Customer',	'/master/customer',	26,	27,	2,	NULL,	'N',	'2023-06-19 22:22:03',	'2024-09-02 09:35:38'),
(22,	NULL,	'Term',	'/master/terms',	32,	33,	2,	NULL,	'N',	'2024-05-07 14:03:58',	'2024-09-02 09:35:38'),
(23,	NULL,	'Staff & HR',	'/master/hrd',	22,	23,	2,	NULL,	'N',	'2024-05-07 14:05:28',	'2024-09-02 09:35:38'),
(24,	NULL,	'Dvision',	'/master/division',	30,	31,	2,	NULL,	'N',	'2024-05-07 14:06:43',	'2024-05-28 22:58:41'),
(25,	NULL,	'Items',	'/master/items',	32,	33,	2,	NULL,	'N',	'2024-05-07 14:07:31',	'2024-05-07 14:07:31'),
(26,	NULL,	'Timeline',	'/master/timeline',	28,	29,	2,	NULL,	'N',	'2024-05-07 14:09:15',	'2024-09-02 09:35:38'),
(27,	NULL,	'Sales',	'#',	110,	130,	1,	'mdi-cash-multiple',	'N',	'2024-05-07 14:10:53',	'2024-09-02 09:35:38'),
(28,	NULL,	'Sales',	'/sales/sales',	121,	122,	1,	NULL,	'N',	'2024-05-07 14:12:29',	'2024-09-02 09:35:38');

DROP TABLE IF EXISTS `s_numbering`;
CREATE TABLE `s_numbering` (
  `S_NumberingID` int NOT NULL AUTO_INCREMENT,
  `S_NumberingType` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `S_NumberingPrefix` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '',
  `S_NumberingPrefixDate` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' COMMENT 'ie %y%m for monthly',
  `S_NumberingMidFix` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `S_NumberingSufix` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' COMMENT '-PAT or blank',
  `S_NumberingReset` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'D' COMMENT 'D, M , Y,X=manual',
  `S_NumberingCounter` int NOT NULL DEFAULT '0' COMMENT 'increment value',
  `S_NumberingDigit` smallint NOT NULL DEFAULT '1',
  `S_NumberingCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_NumberingLastUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `S_NumberingIsActive` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`S_NumberingID`),
  KEY `S_NumberingType` (`S_NumberingType`),
  KEY `S_NumberingCounter` (`S_NumberingCounter`),
  KEY `S_NumberingDigit` (`S_NumberingDigit`),
  KEY `S_NumberingIsActive` (`S_NumberingIsActive`),
  KEY `S_NumberingMidFix` (`S_NumberingMidFix`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `s_numbering` (`S_NumberingID`, `S_NumberingType`, `S_NumberingPrefix`, `S_NumberingPrefixDate`, `S_NumberingMidFix`, `S_NumberingSufix`, `S_NumberingReset`, `S_NumberingCounter`, `S_NumberingDigit`, `S_NumberingCreated`, `S_NumberingLastUpdated`, `S_NumberingIsActive`) VALUES
(9,	'CUSTOMER',	'C-',	'%y%m',	NULL,	'',	'M',	51,	4,	'2020-12-05 21:23:01',	'2024-07-23 09:08:14',	'Y'),
(25,	'SALES',	'S-',	'%y%m',	NULL,	'',	'M',	63,	4,	'2020-12-05 21:23:01',	'2024-08-30 08:28:13',	'Y'),
(26,	'PROJECT',	'SBM/SO/',	'%y%m',	NULL,	'',	'Y',	125,	3,	'2020-12-05 21:23:01',	'2024-08-30 08:28:14',	'Y');

DROP TABLE IF EXISTS `s_privilege`;
CREATE TABLE `s_privilege` (
  `S_PrivilegeID` int NOT NULL AUTO_INCREMENT,
  `S_PrivilegeS_UserGroupID` int NOT NULL DEFAULT '0',
  `S_PrivilegeS_MenuID` int NOT NULL DEFAULT '0',
  `S_PrivilegeOptions` varchar(255) DEFAULT NULL,
  `S_PrivilegeIsActive` char(1) NOT NULL DEFAULT 'Y',
  `S_PrivilegeCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_PrivilegeLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_PrivilegeID`),
  KEY `S_PrivilegeS_UserGroupID` (`S_PrivilegeS_UserGroupID`),
  KEY `S_PrivilegeS_MenuID` (`S_PrivilegeS_MenuID`),
  KEY `S_PrivilegeIsActive` (`S_PrivilegeIsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `s_privilege` (`S_PrivilegeID`, `S_PrivilegeS_UserGroupID`, `S_PrivilegeS_MenuID`, `S_PrivilegeOptions`, `S_PrivilegeIsActive`, `S_PrivilegeCreated`, `S_PrivilegeLastUpdated`) VALUES
(1,	1,	1,	NULL,	'Y',	'2023-06-27 10:20:23',	'2023-06-27 14:17:26'),
(3,	1,	4,	NULL,	'Y',	'2023-06-27 10:20:23',	'2024-05-28 21:28:52'),
(23,	1,	24,	NULL,	'N',	'2024-05-07 14:13:50',	'2024-05-28 21:28:52'),
(24,	1,	25,	NULL,	'N',	'2024-05-07 14:14:10',	'2024-05-28 22:56:50');

DROP TABLE IF EXISTS `s_user`;
CREATE TABLE `s_user` (
  `S_UserID` int NOT NULL AUTO_INCREMENT,
  `S_UserS_UserGroupID` int NOT NULL DEFAULT '0',
  `S_UserS_CompanyID` int NOT NULL DEFAULT '0',
  `S_UserUsername` varchar(25) DEFAULT NULL,
  `S_UserPassword` varchar(80) DEFAULT NULL,
  `S_UserPasswordDev` varchar(80) DEFAULT NULL,
  `S_UserFullName` varchar(100) DEFAULT NULL,
  `S_UserIsLogin` char(1) NOT NULL DEFAULT 'N',
  `S_UserLastLogin` datetime DEFAULT NULL,
  `S_UserLastUsed` datetime DEFAULT NULL,
  `S_UserToken` varchar(2000) DEFAULT NULL,
  `S_UserM_TagID` int NOT NULL DEFAULT '0',
  `S_UserIsActive` char(1) NOT NULL DEFAULT 'Y',
  `S_UserCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_UserLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_UserID`),
  KEY `S_UserUsername` (`S_UserUsername`),
  KEY `S_UserPassword` (`S_UserPassword`),
  KEY `S_UserIsLogin` (`S_UserIsLogin`),
  KEY `S_UserLastLogin` (`S_UserLastLogin`),
  KEY `S_UserIsActive` (`S_UserIsActive`),
  KEY `S_UserS_UserGroupID` (`S_UserS_UserGroupID`),
  KEY `S_UserLastUsed` (`S_UserLastUsed`),
  KEY `S_UserM_TagID` (`S_UserM_TagID`),
  KEY `S_UserS_CompanyID` (`S_UserS_CompanyID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `s_user` (`S_UserID`, `S_UserS_UserGroupID`, `S_UserS_CompanyID`, `S_UserUsername`, `S_UserPassword`, `S_UserPasswordDev`, `S_UserFullName`, `S_UserIsLogin`, `S_UserLastLogin`, `S_UserLastUsed`, `S_UserToken`, `S_UserM_TagID`, `S_UserIsActive`, `S_UserCreated`, `S_UserLastUpdated`) VALUES
(1,	1,	1,	'admin',	'*F82D171544019C4AEB3D26B7AEBA9904FD54B69E',	'*5D36795B3151469CC53D235CF881C9A98EC8BEAD',	'Admin',	'N',	'2024-09-02 09:46:52',	NULL,	NULL,	0,	'Y',	'2023-06-19 22:05:14',	'2024-09-02 09:46:52'),
(8,	2,	1,	'johndulu',	'*5C5EFD55CD8A7B7E5AD0665CCB2BDA8E3C350809',	NULL,	'John Doe',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-05 08:48:54',	'2024-06-05 11:28:47'),
(9,	2,	1,	'johndoe',	'*8232A1298A49F710DBEE0B330C42EEC825D4190A',	NULL,	'John Doe',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-05 08:56:49',	'2024-06-05 09:46:44'),
(10,	2,	1,	'Ubaru',	'*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9',	NULL,	'BARU',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-05 15:38:23',	'2024-06-05 15:38:23'),
(11,	2,	1,	'diisi',	'*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9',	NULL,	'diiis',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-06 10:56:07',	'2024-06-06 10:56:07'),
(12,	2,	1,	'johndoe123',	'*946049E55CEEE3BD8CFE42291732194118F5B76C',	NULL,	'John Doe',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-06 11:30:23',	'2024-06-06 11:30:23'),
(13,	2,	1,	'email',	'*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9',	NULL,	'BEREMAIL',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-06 16:36:17',	'2024-06-06 16:36:17'),
(14,	2,	1,	'esa12',	'*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9',	NULL,	'tesa',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-06-07 09:16:41',	'2024-06-07 09:16:41'),
(15,	2,	1,	'abcde',	'*53973C211F2E714BE16C017B04376515D75AE5FF',	NULL,	'ALIF',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-17 15:35:55',	'2024-07-17 15:35:55'),
(16,	2,	1,	'aqwert',	'*53973C211F2E714BE16C017B04376515D75AE5FF',	NULL,	'aaa',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 09:02:21',	'2024-07-18 09:02:21'),
(17,	2,	1,	'tes123',	'*094F4059110E3E55C5829AF44904BA90969FDCE4',	NULL,	'tes',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 09:58:48',	'2024-07-18 15:56:42'),
(18,	2,	1,	'kominfo',	'*5A6A099A54345F99BEE71DD88714CEB05A1EC10D',	NULL,	'Budi',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 15:45:15',	'2024-07-18 15:45:15'),
(19,	2,	1,	'asasas',	'*49D407D2E7A7BA3A9A5545AC14D248EE4D067BC7',	NULL,	'tera',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 15:49:32',	'2024-07-18 15:49:32'),
(20,	2,	1,	'employeee',	'*2FDD4AE6347C714E9A2F340F1EC514A972A36F31',	NULL,	'employee',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 16:02:40',	'2024-07-18 16:02:40'),
(21,	2,	1,	'budisad',	'*802E722715AE1B3ECE27233BA902E2C3C73FCB16',	NULL,	'budi',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 16:05:18',	'2024-07-18 16:05:18'),
(22,	2,	1,	'uploadtes',	'*8B6AAAF11B0168B0DBCDFC89323848982F7DE283',	NULL,	'upload',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-18 16:10:52',	'2024-07-18 16:10:52'),
(23,	2,	1,	'tesbaru',	'*EC0CC363822D425BB1B85C1F8B54CDD02DA34111',	NULL,	'tes baru',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-19 10:05:27',	'2024-07-19 10:05:27'),
(24,	2,	1,	'terbaruan',	'*9DFDB67F7FF19730E205BDFFBFE9243CEBD0EB47',	NULL,	'terbaruan',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-19 10:38:01',	'2024-07-19 10:38:01'),
(25,	2,	1,	'tyioro',	'*83DF5BAB1606C02F2E518EE912C7C8006644B331',	NULL,	'TYI',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-23 15:02:04',	'2024-07-23 15:02:04'),
(26,	2,	1,	'revisi',	'*F80A77AEE848D6466EC97975772B9AB1F7FC3998',	NULL,	'revu',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-24 11:45:45',	'2024-07-24 11:45:45'),
(27,	2,	1,	'tesar',	'*A822A3A2E92BA3E2A7B7F81EF8904143B277C7C3',	NULL,	'tesar',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-07-24 13:58:01',	'2024-07-24 13:58:01'),
(28,	2,	1,	'abcdef1',	'*53973C211F2E714BE16C017B04376515D75AE5FF',	NULL,	'tes panjanag',	'N',	NULL,	NULL,	NULL,	0,	'Y',	'2024-08-07 14:57:40',	'2024-08-07 14:57:40');

DROP TABLE IF EXISTS `s_usergroup`;
CREATE TABLE `s_usergroup` (
  `S_UserGroupID` int NOT NULL AUTO_INCREMENT,
  `S_UserGroupCode` varchar(25) DEFAULT NULL,
  `S_UserGroupName` varchar(50) DEFAULT NULL,
  `S_UserGroupDashboard` varchar(255) DEFAULT NULL,
  `S_UserGroupIsActive` char(1) NOT NULL DEFAULT 'Y',
  `S_UserGroupCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `S_UserGroupLastUpdated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`S_UserGroupID`),
  KEY `S_UserGroupCode` (`S_UserGroupCode`),
  KEY `S_UserGroupName` (`S_UserGroupName`),
  KEY `S_UserGroupIsActive` (`S_UserGroupIsActive`),
  KEY `S_UserGroupDashboard` (`S_UserGroupDashboard`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `s_usergroup` (`S_UserGroupID`, `S_UserGroupCode`, `S_UserGroupName`, `S_UserGroupDashboard`, `S_UserGroupIsActive`, `S_UserGroupCreated`, `S_UserGroupLastUpdated`) VALUES
(1,	'ONE.GROUP.SA',	'Super Admin',	NULL,	'Y',	'2023-06-19 17:18:32',	'2023-06-19 17:18:32'),
(2,	'ONE.GROUP.EMPLOYEE',	'Karyawan',	NULL,	'Y',	'2023-06-19 17:18:32',	'2023-06-19 17:18:32'),
(3,	'ONE.GROUP.MANAGER',	'Manajer',	NULL,	'Y',	'2023-06-19 17:18:32',	'2023-06-19 17:18:32');

-- 2024-09-02 02:47:30