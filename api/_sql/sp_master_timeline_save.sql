DROP PROCEDURE `sp_master_timeline_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_master_timeline_save` (IN `id` int, IN `hdata` text, IN `jdata` text, IN `uid` int)
BEGIN

DECLARE t_code VARCHAR(25);
DECLARE t_name VARCHAR(50);
DECLARE t_sort INTEGER;
DECLARE t_weight DOUBLE;
DECLARE t_dur INTEGER;
DECLARE default_dur INTEGER;
DECLARE conf_id INTEGER;

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
SET t_weight = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.t_weight"));
SET t_dur = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.t_dur"));
SET default_dur = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.default_dur"));

IF t_weight iS NULL THEN SET t_weight = 0; END IF;
IF t_dur iS NULL THEN SET t_dur = 0; END IF;
IF default_dur iS NULL THEN SET default_dur = 0; END IF;

IF id <> 0 THEN
    UPDATE m_timeline
    SET M_TimelineName = t_name, M_TimelineWeight = t_weight, M_TimelineDuration = t_dur
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

-- UPDATE APP CONF
SET conf_id = (SELECT App_ConfID FROM app_conf WHERE App_ConfCode = "TIMELINE.DURATION.TOTAL" aND App_ConfIsActive = "Y" LIMIT 1);
IF conf_id IS NULL THEN
    INSERT INTO app_conf(App_ConfCode, App_ConfValue) SELECT "TIMELINE.DURATION.TOTAL", default_dur;
ELSE
    UPDATE app_conf SET App_ConfValue = default_dur WHERE App_ConfID = conf_id;
END IF;

SELECT "OK" as status, JSON_OBJECT("timeline_id", id) as data;

COMMIT;
END;;
DELIMITER ;