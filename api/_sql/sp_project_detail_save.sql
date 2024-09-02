DROP PROCEDURE `sp_project_detail_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_project_detail_save` (IN `id` int, IN `hdata` text, IN `uid` int)
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
DELIMITER ;