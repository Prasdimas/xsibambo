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

END