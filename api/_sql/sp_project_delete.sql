DROP PROCEDURE IF EXISTS `sp_project_delete`;;
CREATE PROCEDURE `sp_project_delete`(IN `project_id` int(30))
BEGIN


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

UPDATE p_project
SET P_ProjectIsActive = "N"
WHERE P_ProjectID = project_id ;
UPDATE l_sales
SET L_SalesIsActive = "N"
WHERE L_SalesP_ProjectID = project_id ;
UPDATE p_projectdetail
SET P_ProjectDetailIsActive = "N"
WHERE P_ProjectDetailP_ProjectID = project_id ;

SELECT "OK" as status, JSON_OBJECT("project_id", project_id) as data;
COMMIT;
END;;