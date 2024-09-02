DROP PROCEDURE `sp_project_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_project_save` (IN `id` int, IN `hdata` text, IN `uid` int)
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
DELIMITER ;