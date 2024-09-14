
dbExecute(conn = con, statement = "CREATE OR REPLACE MACRO safe_sum(a, b) AS ifnull(a, 0) + ifnull(b, 0);")
dbExecute(conn = con, statement = "CREATE OR REPLACE MACRO safe_minus(a, b) AS ifnull(a, 0) - ifnull(b, 0);")
dbExecute(conn = con, statement = "CREATE MACRO safe_division(a, b) AS (
    CASE 
        WHEN a IS NULL AND b IS NOT NULL AND b != 0 THEN 0 
        WHEN a IS NULL AND b = 0 THEN 1 
        WHEN b IS NULL and a > 0 THEN 1.7976931348623157E+308
        WHEN b IS NULL and a < 0 THEN -1.7976931348623157E+308
        WHEN b IS NULL and a IS NULL THEN 1
        WHEN b IS NULL and a = 0 THEN 1
        WHEN b = 0 and a = 0 THEN 1
        ELSE a / b
    END
);")

