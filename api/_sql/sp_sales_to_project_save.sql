DROP PROCEDURE `sp_sales_to_project_save`;
DELIMITER ;;
CREATE PROCEDURE `sp_sales_to_project_save` (IN `sales_id` int, IN `uid` int)
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
DELIMITER ;