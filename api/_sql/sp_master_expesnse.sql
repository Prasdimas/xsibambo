BEGIN

DECLARE expense_date DATE;
DECLARE expense_employee INTEGER;
DECLARE expense_total DOUBLE DEFAULT 0;
DECLARE expense_note TEXT;

DECLARE tmp TEXT;
DECLARE l INTEGER;
DECLARE n INTEGER DEFAULT 0;
DECLARE d_id inteGER;
DECLARE d_expense INTEGER;
DECLARE d_amount DOUBLE;
DECLARE d_qty DOUBLE;
DECLARE d_note VARCHAR(255);
DECLARE d_total DOUBLE DEFAULT 0;

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

SET expense_date = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.date"));
SET expense_employee = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.employee"));
SET expense_note = JSON_UNQUOTE(JSON_EXTRACT(hdata, "$.note"));

IF id = 0 THEN
    INSERT INTO f_expense(
        F_ExpenseDate,	
        F_ExpenseM_EmployeeID,	
        F_ExpenseTotal,	
        F_ExpenseNote)
    SELECT expense_date, expense_employee, expense_total, expense_note;

    SET id = (SELECT LAST_INSERT_ID());
ELSE
    UPDATE f_expense
    SET F_ExpenseDate = expense_date, F_ExpenseNote = expense_note, F_ExpenseM_EmployeeID = expense_employee 
    WHERE F_ExpenseID = id;
END IF;

UPDATE f_expensedetail
SET F_ExpenseDetailIsActive = "O" WHERE F_ExpenseDetailIsActive = "Y" AND F_ExpenseDetailF_ExpenseID = id;

SET l = JSON_LENGTH(jdata);
WHILE n < l DO
    SET tmp = JSON_EXTRACT(jdata, CONCAT("$[", n, "]"));
    SET d_id = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.d_id"));
    SET d_expense = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.d_expense"));
    SET d_amount = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.d_amount"));
    SET d_qty = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.d_qty"));
    SET d_total = d_amount * d_qty;
    SET d_note = JSON_UNQUOTE(JSON_EXTRACT(tmp, "$.d_note"));

    IF d_id IS nuLL OR d_id = 0 THEN
        INSERT INTO f_expensedetail(
            F_ExpenseDetailF_ExpenseID,
            F_ExpenseDetailM_ExpenseID,
            F_ExpenseDetailAmount,
            F_ExpenseDetailQty,
            F_ExpenseDetailTotal,
            F_ExpenseDetailNote)
        SELECT id, d_expense, d_amount, d_qty, d_total, d_note;
    ELSE
        UPDATE f_expensedetail
        SET F_ExpenseDetailIsActive = "Y", F_ExpenseDetailAmount = d_amount, F_ExpenseDetailQty = d_qty, 
            F_ExpenseDetailTotal = d_total, F_ExpenseDetailNote = d_note, F_ExpenseDetailM_ExpenseID = d_expense
        WHERE F_ExpenseDetailID = d_id;
    END IF;
    SET n = n + 1;
END WHILE;

UPDATE f_expensedetail
SET F_ExpenseDetailIsActive = "N" WHERE F_ExpenseDetailIsActive = "O" AND F_ExpenseDetailF_ExpenseID = id;

SET expense_total = (SELECT SUM(F_ExpenseDetailTotal) FROM f_expensedetail WHERE F_ExpenseDetailISActive = "Y" AND F_ExpenseDetailF_ExpenseID = id);

UPDATE f_expense SET F_ExpenseTotal = expense_total WHERE F_ExpenseID = id;

SELECT "OK" as status, JSON_OBJECT("expense_id", id) as data;

COMMIT;

END