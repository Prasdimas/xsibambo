DROP PROCEDURE `sp_project_week_progress_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_project_week_progress_save` (IN `pid` int)
BEGIN

-- Declare variables
DECLARE done INT DEFAULT FALSE;
DECLARE p_edate DATE;
DECLARE p_tdate DATE;
DECLARE p_weight DOUBLE;

DECLARE progress DOUBLE DEFAULT 0;

-- Declare the cursor
DECLARE cur1 CURSOR FOR
    select P_ProjectDetailTargetDate, P_ProjectDetailEndDate, P_ProjectDetailWeight
        FROM p_projectdetail
        join m_status on p_projectdetailm_statusid = m_statusid 
        and m_statuscode = "PROJECT.STATUS.FINISH"
        WHERE P_ProjectDetailP_ProjectID = pid
        AND p_projectdetailisactive = "Y"
        ORDER BY P_ProjectDetailM_TimelineID ASC;

-- Declare the handler for the end of the cursor
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

UPDATE p_projectweek SET P_ProjectWeekProgress = 0 WHERE P_ProjectWeekP_ProjectID = pid;

-- Open the cursor
OPEN cur1;

    -- Fetch rows from the cursor
    read_loop: LOOP
    FETCH cur1 INTO p_tdate, p_edate, p_weight;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Do something with the fetched data
        -- For example, you can SELECT it, UPDATE another table, etc.
        SET progress = progress + p_weight;
        UPDATE p_projectweek SET P_ProjectWeekProgress = progress
        WHERE P_ProjectWeekP_ProjectID = pid AND P_ProjectWeekStartDate <= p_edate AND P_ProjectWeekEndDate >= p_edate
            AND P_ProjectWeekIsActive = "Y";
    END LOOP;

    -- Close the cursor
CLOSE cur1;
END;;
DELIMITER ;