DROP PROCEDURE `sp_master_customer_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_master_customer_save` (IN `customerid` int, IN `jdata` mediumtext, IN `bdata` mediumtext, IN `addresses` mediumtext, IN `uid` int)
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
DECLARE p_desc VARCHAR(500);

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
DELIMITER ;