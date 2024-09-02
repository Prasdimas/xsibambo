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

END