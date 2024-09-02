DROP PROCEDURE IF EXISTS `sp_master_packet_save`;
DELIMITER ;;
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
DELIMITER ;