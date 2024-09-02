DROP PROCEDURE `sp_project_week_set`;
DELIMITER ;;
CREATE PROCEDURE `sp_project_week_set` (IN `pid` int)
BEGIN

DECLARE p_duration INTEGER;
DECLARE p_date DATE;
DECLARE s_date DATE;
DECLARE n INTEGER DEFAULT 0;
DECLARE i INTEGER DEFAULT 0;
DECLARE w INTEGER DEFAULT 1;

DECLARE h_id INTEGER;
DECLARE day_id INTEGER;

SELECT P_ProjectDate, P_ProjectDuration INTO p_date, p_duration
FROM p_project WHERE P_ProjectID = pid;

DELETE FROM p_projectweek WHERE P_ProjectWeekP_ProjectID = pid;

SELECT n, p_duration;
WHILE n < p_duration DO
    SET h_id = (SELECT M_HolidayID FROM m_holiday WHERE M_HolidayDate = p_date AND M_HolidayIsActive = "Y");
    SELECT h_id;
    IF h_id IS NULL THEN
        SET day_id = (SELECT M_WorkDayID FROM m_workday 
                WHERE M_WorkDayIsActive = "Y" AND M_WorkDayM_DayID = DAYOFWEEK(p_date));

        
        IF day_id IS NOT NULL THEN
            SELECT day_id, i;
            -- start of week
            IF i = 0 THEN
                SET s_date = p_date;

            -- end of week
            ELSEIF i = 6 THEN
                INSERT INTO p_projectweek(P_ProjectWeekP_ProjectID,
                    P_ProjectWeekName,
                    P_ProjectWeekStartDate,
                    P_ProjectWeekEndDate,
                    P_ProjectWeekNo)
                SELECT pid, CONCAT('Pekan ke ', w), s_date, p_date, w;

                SET i = -1;
                SET w = w + 1;
            END IF;

            SET n = n + 1;
            SET i = i+ 1;
        END IF;
    END IF;

    SET p_date = DATE_ADD(p_date, INTERVAL 1 DAY);
END WHILE;

IF i > 0 THEN
    SET p_date = DATE_ADD(p_date, INTERVAL -1 DAY);
    INSERT INTO p_projectweek(P_ProjectWeekP_ProjectID,
        P_ProjectWeekName,
        P_ProjectWeekStartDate,
        P_ProjectWeekEndDate,
        P_ProjectWeekNo)
    SELECT pid, CONCAT('Pekan ke ', w), s_date, p_date, w;
END IF;

END;;
DELIMITER ;