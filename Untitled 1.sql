SELECT 
    d.NAME AS TEST_NAME,
    t.STATUS,
    t.RUN_STARTED_AT,
    ARRAY_TO_STRING(d.TAGS, ', ') AS TAG_NAME
FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
LEFT JOIN JAFFLE_SHOP.LCF.DIM_DBT__TESTS d
    ON t.NODE_ID = d.NODE_ID
    AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
ORDER BY t.RUN_STARTED_AT DESC;

select * from JAFFLE_SHOP.LCF.DIM_DBT__TESTS

select * from lcf.FCT_DBT__TEST_EXECUTIONS order by RUN_STARTED_AT desc

CALL LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS()

CALL LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS('abc');

  update staging.stg_customers
  SET CUSTOMER_ID=NULL
  Where CUSTOMER_NAME='Henry Strickland'
  and CUSTOMER_ID='2347081e-7ae5-4085-a0d6-d1f551721f69'
  select * from staging.stg_customers Where CUSTOMER_NAME='Henry Strickland'
  


Select * from JAFFLE_SHOP.LCF.TestCaseExecution;

TRUNCATE Table JAFFLE_SHOP.LCF.TestCaseExecution;

CREATE OR REPLACE NOTIFICATION INTEGRATION EMAIL_ALERTS_INTEGRATION
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('roshan.lal@elait.com');

CALL lcf.SP_SEND_DBT_TEST_FAILURE_ALERT('customer')
SHOW NOTIFICATION INTEGRATIONS;
SELECT CURRENT_ROLE()

EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN
  ARGS = 'test --target dev';

  EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN
  ARGS = 'test --target dev --select tag:customer';

CALL LCF.SP_POPULATE_DBT_TEST_AUDIT_TABLE()

Select * from JAFFLE_SHOP.LCF.Test_AuditTable order by ID desc

truncate table JAFFLE_SHOP.LCF.Test_AuditTable

---------------------------------
CREATE OR REPLACE PROCEDURE LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS(tag_name STRING DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    dbt_status STRING;
    latest_command_id STRING;
    test_count INTEGER;
    sql_command STRING;
    last_run_started_at TIMESTAMP;
BEGIN

   ----------------------------------------------------------------
-- Step 0: Capture the latest run timestamp before executing DBT
----------------------------------------------------------------
BEGIN
    -- Assign latest run timestamp using SELECT INTO (no colon)
    SELECT COALESCE(MAX(RUN_STARTED_AT), TO_TIMESTAMP('1900-01-01 00:00:00'))
    INTO last_run_started_at
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS;
    
    
EXCEPTION
    WHEN OTHER THEN
        last_run_started_at := TO_TIMESTAMP('1900-01-01 00:00:00');
END;


    ----------------------------------------------------------------
    -- Step 1: Run DBT Tests (with or without tag)
    ----------------------------------------------------------------
    BEGIN
        IF (:tag_name IS NULL OR TRIM(:tag_name) = '') THEN
            sql_command := 'EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN ARGS = ''test --target dev'';';
        ELSE
            sql_command := 'EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN ARGS = ''test --target dev --select tag:' || :tag_name || ''';';
        END IF;

        EXECUTE IMMEDIATE :sql_command;
        dbt_status := '✅ DBT tests executed successfully.';
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := '⚠️ DBT execution failed: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 2: Get latest COMMAND_INVOCATION_ID
    ----------------------------------------------------------------
    BEGIN
        SELECT MAX(COMMAND_INVOCATION_ID)
        INTO :latest_command_id
        FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS;

        IF (latest_command_id IS NULL) THEN
            dbt_status := dbt_status || ' | ⚠️ No test executions found.';
            RETURN dbt_status;
        END IF;
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to fetch latest COMMAND_INVOCATION_ID: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 3: Truncate TestCaseExecution table
    ----------------------------------------------------------------
    BEGIN
        TRUNCATE TABLE JAFFLE_SHOP.LCF.TestCaseExecution;
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to truncate table: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 4: Check tagged test count (if tag provided)
    ----------------------------------------------------------------
 /*   IF (:tag_name IS NOT NULL AND TRIM(:tag_name) <> '') THEN
        BEGIN
            SELECT COUNT(*)
            INTO :test_count
            FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
            LEFT JOIN JAFFLE_SHOP.LCF.DIM_DBT__TESTS d
                ON t.NODE_ID = d.NODE_ID
                AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
            WHERE t.COMMAND_INVOCATION_ID = :latest_command_id
              AND ARRAY_CONTAINS(TO_VARIANT(:tag_name), d.TAGS);

            IF (test_count = 0) THEN
                dbt_status := dbt_status || ' | ⚠️ No test cases found for tag ' || tag_name;
                RETURN dbt_status;
            END IF;
        EXCEPTION
            WHEN OTHER THEN
                dbt_status := dbt_status || ' | ⚠️ Failed to count tagged tests: ' || SQLERRM;
        END;
    END IF;*/

    ----------------------------------------------------------------
    -- Step 5: Insert latest test results
    ----------------------------------------------------------------
    BEGIN
        -- Insert the latest run test results
INSERT INTO LCF.TestCaseExecution (ID, TEST_NAME, STATUS, MESSAGE)
WITH last_run AS (
    -- Step 1: Find the latest run timestamp
    SELECT MAX(RUN_STARTED_AT) AS latest_run
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS
    WHERE RUN_STARTED_AT>:last_run_started_at
),
latest_tests AS (
    -- Step 2: Get only the tests from that latest run
    SELECT
        t.NODE_ID,
        d.NAME AS TEST_NAME,
        t.STATUS,
        t.MESSAGE,
        t.RUN_STARTED_AT
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
    INNER JOIN (
        -- Only one row per NODE_ID from DIM_DBT__TESTS
        SELECT NODE_ID, NAME
        FROM JAFFLE_SHOP.LCF.DIM_DBT__TESTS
        QUALIFY ROW_NUMBER() OVER (PARTITION BY NODE_ID ORDER BY NODE_ID) = 1
    ) d
        ON t.NODE_ID = d.NODE_ID
    CROSS JOIN last_run l
    WHERE t.RUN_STARTED_AT = l.latest_run
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    CASE 
        WHEN STATUS = 'fail' THEN 'Fail'
        WHEN STATUS = 'warn' THEN 'Warn'
        WHEN STATUS = 'pass' THEN 'Pass'
        ELSE INITCAP(STATUS)
    END AS STATUS,
    MESSAGE
FROM latest_tests
ORDER BY RUN_STARTED_AT DESC;

        dbt_status := dbt_status || ' ✅ Test results inserted successfully.';
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to insert test results: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 6: Send Alert Email
    ----------------------------------------------------------------
    BEGIN
        CALL LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(:tag_name);
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to send alert mail: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 7: Return Summary
    ----------------------------------------------------------------
    RETURN dbt_status;
END;
$$;


CREATE OR REPLACE PROCEDURE LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(TAG_NAME VARCHAR DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    failed_tests INTEGER;
    warning_tests INTEGER;
    failed_table STRING;
    warning_table STRING;
    email_subject STRING;
    tag_display STRING;
    email_body STRING;
    cmd STRING;
BEGIN
    ----------------------------------------------------------------
    -- Counts
    ----------------------------------------------------------------
    failed_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Fail');
    warning_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Warn');

    ----------------------------------------------------------------
    -- Build HTML rows
    ----------------------------------------------------------------
    failed_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:red;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Fail'
    );

    warning_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:orange;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Warn'
    );

    ----------------------------------------------------------------
    -- Prepare subject and tag display
    ----------------------------------------------------------------
    IF (TAG_NAME IS NULL OR TAG_NAME = '') THEN
        tag_display := 'All Tags';
    ELSE
        tag_display := 'Tag: ' || TAG_NAME;
    END IF;

    -- Subject now only contains project and tag
    email_subject := '🚨 DBT-POC | ' || tag_display;

    ----------------------------------------------------------------
    -- Prepare email body
    ----------------------------------------------------------------
    email_body :=
        '<html><body>' ||
        '<p>There are <b>' || failed_tests || '</b> failed test cases and <b>' || warning_tests || '</b> warning test cases.</p>' ||
        '<p><b>Project:</b> DBT-POC</p>' ||
        '<p><b>' || tag_display || '</b></p>' ||
        '<p>Please review the details below:</p>' ||
        '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; font-family:Arial; font-size:13px;">' ||
        '<tr style="background-color:#f2f2f2;"><th>TEST_NAME</th><th>STATUS</th><th>MESSAGE</th></tr>' ||
        COALESCE(failed_table, '') ||
        COALESCE(warning_table, '') ||
        '</table>' ||
        '<br><p>For full details, check the <b>Test Cases</b> in Snowflake DBT logs.</p>' ||
        '</body></html>';

    ----------------------------------------------------------------
    -- Send email
    ----------------------------------------------------------------
    IF (failed_tests > 0 OR warning_tests > 0) THEN
        cmd := 'CALL SYSTEM$SEND_EMAIL(' ||
               '''email_alerts_integration'',' ||
               '''roshan.lal@elait.com'',' ||
               '''' || REPLACE(email_subject, '''', '''''') || ''',' ||
               '''' || REPLACE(email_body, '''', '''''') || ''',' ||
               '''text/html'')';

        EXECUTE IMMEDIATE cmd;

        RETURN '📧 Email sent successfully. Found ' || failed_tests || ' failed and ' || warning_tests || ' warnings.';
    ELSE
        RETURN '✅ No failing or warning tests found.';
    END IF;
END;
$$;

----------------------------

CREATE OR REPLACE PROCEDURE LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(TAG_NAME VARCHAR DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    failed_tests INTEGER;
    warning_tests INTEGER;
    failed_table STRING;
    warning_table STRING;
    email_subject STRING;
    tag_display STRING;
    email_body STRING;
    cmd STRING;
BEGIN
    ----------------------------------------------------------------
    -- Counts
    ----------------------------------------------------------------
    failed_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Fail');
    warning_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Warn');

    ----------------------------------------------------------------
    -- Build HTML rows
    ----------------------------------------------------------------
    failed_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:red;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Fail'
    );

    warning_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:orange;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Warn'
    );

    ----------------------------------------------------------------
    -- Prepare subject and body
    ----------------------------------------------------------------
    IF (TAG_NAME IS NULL OR TAG_NAME = '') THEN
        tag_display := 'All Tags';
    ELSE
        tag_display := 'Tag: ' || TAG_NAME;
    END IF;

    email_subject := '🚨 DBT-POC | ' || tag_display || ' | ' ||
                     failed_tests || ' Failed, ' || warning_tests || ' Warning Tests Found';

    email_body :=
        '<html><body>' ||
        '<h3 style="color:red;">❌ ' || failed_tests || ' Failed</h3>' ||
        '<h3 style="color:orange;">⚠️ ' || warning_tests || ' Warning</h3>' ||
        '<p><b>Project:</b> DBT-POC</p>' ||
        '<p><b>' || tag_display || '</b></p>' ||
        '<p>Please review the details below:</p>' ||
        '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; font-family:Arial; font-size:13px;">' ||
        '<tr style="background-color:#f2f2f2;"><th>TEST_NAME</th><th>STATUS</th><th>MESSAGE</th></tr>' ||
        COALESCE(failed_table, '') ||
        COALESCE(warning_table, '') ||
        '</table>' ||
        '<br><p>For full details, check the <b>Test Cases</b> in Snowflake DBT logs.</p>' ||
        '</body></html>';

    ----------------------------------------------------------------
    -- Send email
    ----------------------------------------------------------------
    IF (failed_tests > 0 OR warning_tests > 0) THEN
        cmd := 'CALL SYSTEM$SEND_EMAIL(' ||
               '''email_alerts_integration'',' ||
               '''roshan.lal@elait.com'',' ||
               '''' || REPLACE(email_subject, '''', '''''') || ''',' ||
               '''' || REPLACE(email_body, '''', '''''') || ''',' ||
               '''text/html'')';

        EXECUTE IMMEDIATE cmd;

        RETURN '📧 Email sent successfully. Found ' || failed_tests || ' failed and ' || warning_tests || ' warnings.';
    ELSE
        RETURN '✅ No failing or warning tests found.';
    END IF;
END;
$$; --working

-----------------------

CREATE OR REPLACE PROCEDURE LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(TAG_NAME VARCHAR DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    failed_tests INTEGER;
    warning_tests INTEGER;
    failed_table STRING;
    warning_table STRING;
    email_subject STRING;
    tag_display STRING;
    email_body STRING;
    cmd STRING;
BEGIN
    ----------------------------------------------------------------
    -- Counts
    ----------------------------------------------------------------
    failed_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Fail');
    warning_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Warn');

    ----------------------------------------------------------------
    -- Build HTML rows
    ----------------------------------------------------------------
    failed_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:red;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Fail'
    );

    warning_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:orange;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Warn'
    );

    ----------------------------------------------------------------
    -- Prepare subject and body
    ----------------------------------------------------------------
    IF (TAG_NAME IS NULL OR TAG_NAME = '') THEN
        tag_display := 'All Tags';
    ELSE
        tag_display := 'Tag: ' || TAG_NAME;
    END IF;

    -- Subject now only contains project and tag
    email_subject := '🚨 DBT-POC | ' || tag_display;

    email_body :=
        '<html><body>' ||
        '<h3 style="color:red;">❌ ' || failed_tests || ' Failed</h3>' ||
        '<h3 style="color:orange;">⚠️ ' || warning_tests || ' Warning</h3>' ||
        '<p><b>Project:</b> DBT-POC</p>' ||
        '<p><b>' || tag_display || '</b></p>' ||
        '<p>Please review the details below:</p>' ||
        '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; font-family:Arial; font-size:13px;">' ||
        '<tr style="background-color:#f2f2f2;"><th>TEST_NAME</th><th>STATUS</th><th>MESSAGE</th></tr>' ||
        COALESCE(failed_table, '') ||
        COALESCE(warning_table, '') ||
        '</table>' ||
        '<br><p>For full details, check the <b>Test Cases</b> in Snowflake DBT logs.</p>' ||
        '</body></html>';

    ----------------------------------------------------------------
    -- Send email
    ----------------------------------------------------------------
    IF (failed_tests > 0 OR warning_tests > 0) THEN
        cmd := 'CALL SYSTEM$SEND_EMAIL(' ||
               '''email_alerts_integration'',' ||
               '''roshan.lal@elait.com'',' ||
               '''' || REPLACE(email_subject, '''', '''''') || ''',' ||
               '''' || REPLACE(email_body, '''', '''''') || ''',' ||
               '''text/html'')';

        EXECUTE IMMEDIATE cmd;

        RETURN '📧 Email sent successfully. Found ' || failed_tests || ' failed and ' || warning_tests || ' warnings.';
    ELSE
        RETURN '✅ No failing or warning tests found.';
    END IF;
END;
$$;  --Latest working


-----------------------
CREATE OR REPLACE PROCEDURE LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(TAG_NAME VARCHAR DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    failed_tests INTEGER;
    warning_tests INTEGER;
    failed_table STRING;
    warning_table STRING;
    email_subject STRING;
    tag_display STRING;
    email_body STRING;
    cmd STRING;
BEGIN
    ----------------------------------------------------------------
    -- Counts
    ----------------------------------------------------------------
    failed_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Fail');
    warning_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'Warn');

    ----------------------------------------------------------------
    -- Build HTML rows for failed/warning tests
    ----------------------------------------------------------------
    failed_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:red;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Fail'
    );

    warning_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:orange;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'Warn'
    );

    ----------------------------------------------------------------
    -- Prepare tag display and email subject
    ----------------------------------------------------------------
    IF (TAG_NAME IS NULL OR TAG_NAME = '') THEN
        tag_display := 'All Tags';
    ELSE
        tag_display := 'Tag: ' || TAG_NAME;
    END IF;

    email_subject := '🚨 DBT-POC | ' || tag_display;

    ----------------------------------------------------------------
    -- Prepare concise email body
    ----------------------------------------------------------------
    email_body :=
        '<html><body>' ||
        '<p>There are <b>' || failed_tests || '</b> failed test cases and <b>' || warning_tests || '</b> warning test cases.</p>' ||
        '<p>Details:</p>' ||
        '<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; font-family:Arial; font-size:13px;">' ||
        '<tr style="background-color:#f2f2f2;"><th>TEST_NAME</th><th>STATUS</th><th>MESSAGE</th></tr>' ||
        COALESCE(failed_table, '') ||
        COALESCE(warning_table, '') ||
        '</table>' ||
        '</body></html>';

    ----------------------------------------------------------------
    -- Send email
    ----------------------------------------------------------------
    IF (failed_tests > 0 OR warning_tests > 0) THEN
        cmd := 'CALL SYSTEM$SEND_EMAIL(' ||
               '''email_alerts_integration'',' ||
               '''roshan.lal@elait.com'',' ||
               '''' || REPLACE(email_subject, '''', '''''') || ''',' ||
               '''' || REPLACE(email_body, '''', '''''') || ''',' ||
               '''text/html'')';

        EXECUTE IMMEDIATE cmd;

        RETURN '📧 Email sent successfully. Found ' || failed_tests || ' failed and ' || warning_tests || ' warnings.';
    ELSE
        RETURN '✅ No failing or warning tests found.';
    END IF;
END;
$$;


----------------------
MERGE INTO LCF.DIM_DBT__TESTS d
USING (
    SELECT
        node.value:"unique_id"::STRING AS NODE_ID,
        node.value:"name"::STRING AS NAME,
        ARRAY_CONSTRUCT(node.value:"tags") AS TAGS
    FROM TABLE(
        FLATTEN(
            INPUT => PARSE_JSON(
                (SELECT $1:content
                 FROM @LCF.DBT_STAGE/manifest.json (FILE_FORMAT => 'JSON'))
            )
        )
    ) AS node
    WHERE node.value:"resource_type"::STRING = 'test'
) s
ON d.NODE_ID = s.NODE_ID
WHEN MATCHED THEN
    UPDATE SET d.TAGS = s.TAGS
WHEN NOT MATCHED THEN
    INSERT (NODE_ID, NAME, TAGS)
    VALUES (s.NODE_ID, s.NAME, s.TAGS);


SHOW STAGES IN SCHEMA JAFFLE_SHOP.LCF;
CREATE OR REPLACE STAGE LCF.DBT_STAGE;

LIST @JAFFLE_SHOP.LCF.DBT_STAGE;



---------------------


SELECT MAX(COMMAND_INVOCATION_ID)

        FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS;

        
WITH latest_tests AS (
    SELECT
        t.NODE_ID,
        d.NAME AS TEST_NAME,
        t.STATUS,
        t.MESSAGE,
        t.RUN_STARTED_AT,
        ROW_NUMBER() OVER (
            PARTITION BY t.NODE_ID
            ORDER BY t.RUN_STARTED_AT DESC
        ) AS rn
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
    INNER JOIN JAFFLE_SHOP.LCF.DIM_DBT__TESTS d
        ON t.NODE_ID = d.NODE_ID
        AND t.Test_Execution_ID= d.Test_Execution_ID
        AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
    WHERE t.COMMAND_INVOCATION_ID = 'f8415809-613b-487f-8f3d-e24537258a24'
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    CASE 
        WHEN STATUS = 'fail' THEN 'Fail'
        WHEN STATUS = 'warn' THEN 'Warn'
        WHEN STATUS = 'pass' THEN 'Pass'
        ELSE INITCAP(STATUS)
    END AS STATUS,
    MESSAGE
FROM latest_tests
WHERE rn = 1
ORDER BY RUN_STARTED_AT DESC;

select  * from JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS order by RUN_STARTED_AT desc

select * from JAFFLE_SHOP.LCF.dim_dbt__tests order by RUN_STARTED_AT desc

------------------------------
WITH last_run AS (
    -- Step 1: Find the latest run timestamp
    SELECT MAX(RUN_STARTED_AT) AS latest_run
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS
),
latest_tests AS (
    -- Step 2: Get only the tests from that latest run
    SELECT
        t.NODE_ID,
        d.NAME AS TEST_NAME,
        t.STATUS,
        t.MESSAGE,
        t.RUN_STARTED_AT
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
    INNER JOIN (
        -- Only one row per NODE_ID from DIM_DBT__TESTS
        SELECT NODE_ID, NAME
        FROM JAFFLE_SHOP.LCF.DIM_DBT__TESTS
        QUALIFY ROW_NUMBER() OVER (PARTITION BY NODE_ID ORDER BY NODE_ID) = 1
    ) d
        ON t.NODE_ID = d.NODE_ID
    CROSS JOIN last_run l
    WHERE t.RUN_STARTED_AT = l.latest_run
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    CASE 
        WHEN STATUS = 'fail' THEN 'Fail'
        WHEN STATUS = 'warn' THEN 'Warn'
        WHEN STATUS = 'pass' THEN 'Pass'
        ELSE INITCAP(STATUS)
    END AS STATUS,
    MESSAGE
FROM latest_tests
ORDER BY RUN_STARTED_AT DESC;

------------------------------------------

CREATE OR REPLACE PROCEDURE LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS(tag_name STRING DEFAULT NULL)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    dbt_status STRING;
    latest_command_id STRING;
    test_count INTEGER;
    sql_command STRING;
    last_run_started_at TIMESTAMP;
    tag_list ARRAY;
    t STRING;
    i INT;
    n INT;
BEGIN

   ----------------------------------------------------------------
-- Step 0: Capture the latest run timestamp before executing DBT
----------------------------------------------------------------
BEGIN
    -- Assign latest run timestamp using SELECT INTO (no colon)
    SELECT COALESCE(MAX(RUN_STARTED_AT), TO_TIMESTAMP('1900-01-01 00:00:00'))
    INTO last_run_started_at
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS;
    
    
EXCEPTION
    WHEN OTHER THEN
        last_run_started_at := TO_TIMESTAMP('1900-01-01 00:00:00');
END;


    ----------------------------------------------------------------
    -- Step 1: Run DBT Tests (with or without tag)
    ----------------------------------------------------------------
    BEGIN
        IF (:tag_name IS NULL OR TRIM(:tag_name) = '') THEN
            sql_command := 'EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN ARGS = ''test --target dev'';';
            EXECUTE IMMEDIATE sql_command;
        ELSE
            n := ARRAY_SIZE(SPLIT(tag_name, ','));
            sql_command := 'EXECUTE DBT PROJECT JAFFLE_SHOP.LCF.JAFFLESHOP_ROSHAN ARGS = ''test --target dev';
            i := 0;
            tag_list :=  SPLIT(tag_name, ',');

            WHILE (i < n) DO
    t := tag_list[:i];   -- ✅ no colon inside brackets
    sql_command := sql_command || ' --select tag:' || t;
    i := i+1;
  -- RETURN 'DEBUG SQL_COMMAND: ' || sql_command;
END WHILE;
--RETURN 'DEBUG SQL_COMMAND: ' || sql_command;
sql_command := sql_command || ''';'; 

EXECUTE IMMEDIATE sql_command;
           
        END IF;
        -- DEBUG: return the SQL command before execution
--RETURN 'DEBUG SQL_COMMAND: ' || sql_command;

        
        dbt_status := '✅ DBT tests executed successfully.';
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := '⚠️ DBT execution failed: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 2: Get latest COMMAND_INVOCATION_ID
    ----------------------------------------------------------------
    BEGIN
        SELECT MAX(COMMAND_INVOCATION_ID)
        INTO :latest_command_id
        FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS;

        IF (latest_command_id IS NULL) THEN
            dbt_status := dbt_status || ' | ⚠️ No test executions found.';
            RETURN dbt_status;
        END IF;
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to fetch latest COMMAND_INVOCATION_ID: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 3: Truncate TestCaseExecution table
    ----------------------------------------------------------------
    BEGIN
        TRUNCATE TABLE JAFFLE_SHOP.LCF.TestCaseExecution;
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to truncate table: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 4: Check tagged test count (if tag provided)
    ----------------------------------------------------------------
 /*   IF (:tag_name IS NOT NULL AND TRIM(:tag_name) <> '') THEN
        BEGIN
            SELECT COUNT(*)
            INTO :test_count
            FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
            LEFT JOIN JAFFLE_SHOP.LCF.DIM_DBT__TESTS d
                ON t.NODE_ID = d.NODE_ID
                AND t.COMMAND_INVOCATION_ID = d.COMMAND_INVOCATION_ID
            WHERE t.COMMAND_INVOCATION_ID = :latest_command_id
              AND ARRAY_CONTAINS(TO_VARIANT(:tag_name), d.TAGS);

            IF (test_count = 0) THEN
                dbt_status := dbt_status || ' | ⚠️ No test cases found for tag ' || tag_name;
                RETURN dbt_status;
            END IF;
        EXCEPTION
            WHEN OTHER THEN
                dbt_status := dbt_status || ' | ⚠️ Failed to count tagged tests: ' || SQLERRM;
        END;
    END IF;*/

    ----------------------------------------------------------------
    -- Step 5: Insert latest test results
    ----------------------------------------------------------------
    BEGIN
        -- Insert the latest run test results
INSERT INTO LCF.TestCaseExecution (ID, TEST_NAME, STATUS, MESSAGE)
WITH last_run AS (
    -- Step 1: Find the latest run timestamp
    SELECT MAX(RUN_STARTED_AT) AS latest_run
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS
    WHERE RUN_STARTED_AT>:last_run_started_at
),
latest_tests AS (
    -- Step 2: Get only the tests from that latest run
    SELECT
        t.NODE_ID,
        d.NAME AS TEST_NAME,
        t.STATUS,
        t.MESSAGE,
        t.RUN_STARTED_AT
    FROM JAFFLE_SHOP.LCF.FCT_DBT__TEST_EXECUTIONS t
    INNER JOIN (
        -- Only one row per NODE_ID from DIM_DBT__TESTS
        SELECT NODE_ID, NAME
        FROM JAFFLE_SHOP.LCF.DIM_DBT__TESTS
        QUALIFY ROW_NUMBER() OVER (PARTITION BY NODE_ID ORDER BY NODE_ID) = 1
    ) d
        ON t.NODE_ID = d.NODE_ID
    CROSS JOIN last_run l
    WHERE t.RUN_STARTED_AT = l.latest_run
)
SELECT
    ROW_NUMBER() OVER (ORDER BY RUN_STARTED_AT DESC) AS ID,
    TEST_NAME,
    CASE 
        WHEN STATUS = 'fail' THEN 'Fail'
        WHEN STATUS = 'warn' THEN 'Warn'
        WHEN STATUS = 'pass' THEN 'Pass'
        ELSE INITCAP(STATUS)
    END AS STATUS,
    MESSAGE
FROM latest_tests
ORDER BY RUN_STARTED_AT DESC;

        dbt_status := dbt_status || ' ✅ Test results inserted successfully.';
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to insert test results: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 6: Send Alert Email
    ----------------------------------------------------------------
    BEGIN
        CALL LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(:tag_name);
    EXCEPTION
        WHEN OTHER THEN
            dbt_status := dbt_status || ' | ⚠️ Failed to send alert mail: ' || SQLERRM;
    END;

    ----------------------------------------------------------------
    -- Step 7: Return Summary
    ----------------------------------------------------------------
    RETURN dbt_status;
END;
$$;

CALL LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS()

select * from JAFFLE_SHOP.LCF.DIM_DBT__TESTS

select * from lcf.FCT_DBT__TEST_EXECUTIONS order by RUN_STARTED_AT desc

CALL LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS()

CALL LCF.SP_RUN_DBT_TESTS_AND_LOG_RESULTS('customer,Payment');

  update staging.stg_customers
  SET CUSTOMER_ID=NULL
  Where CUSTOMER_NAME='Henry Strickland'
  and CUSTOMER_ID='2347081e-7ae5-4085-a0d6-d1f551721f69'
  select * from staging.stg_customers Where CUSTOMER_NAME='Henry Strickland'
  


Select * from JAFFLE_SHOP.LCF.TestCaseExecution;


  Select * from  staging.stg_customers_test where CUSTOMER_ID IS NULL  -- exclude soft-deleted records

    Select * from staging.stg_customers where is_deleted = false   -- exclude soft-deleted records
 
Select * from raw.raw_customers_test

select * from lcf.highwatermark
update lcf.highwatermark
SEt START_DATE='1900-01-01'
where table_name='stg_customers_test'

select * from lcf.auditlog order by loadstarttime desc

update lcf.auditlog
set status='Failed'
where status='In Progress'

select * from marts.customers_test




WITH customers AS (

    SELECT * FROM JAFFLE_SHOP.staging.stg_customers_test

),

orders AS (

    SELECT * FROM JAFFLE_SHOP.marts.orders

),

customer_orders_summary AS (

    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS count_lifetime_orders,
        COUNT(DISTINCT o.order_id) > 1 AS is_repeat_buyer,
        MIN(o.ordered_at) AS first_ordered_at,
        MAX(o.ordered_at) AS last_ordered_at,
        SUM(o.subtotal) AS lifetime_spend_pretax,
        SUM(o.tax_paid) AS lifetime_tax_paid,
        SUM(o.order_total) AS lifetime_spend
    FROM orders o
    GROUP BY 1

),

joined AS (

    SELECT
        c.customer_id,
        c.customer_name,
        s.count_lifetime_orders,
        s.first_ordered_at,
        s.last_ordered_at,
        s.lifetime_spend_pretax,
        s.lifetime_tax_paid,
        s.lifetime_spend,

        CASE WHEN s.is_repeat_buyer THEN 'returning'
             ELSE 'new'
        END AS customer_type,

        -- audit columns
        'I' AS ActionType,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS InsertDate,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS ActionDate
    FROM customers c
    LEFT JOIN customer_orders_summary s
        ON c.customer_id = s.customer_id
)

SELECT * FROM joined;



WITH highwatermark AS (
    SELECT *
    FROM metadata.highwatermark
    WHERE table_name = 'tbl_stg_customers'
),
ranked_customers AS (
    SELECT
        c.ID AS customer_id,
        c.NAME AS customer_name,
        c.UPDATED_AT AS updated_at,
        c.IS_DELETED,
        c.Effective_Date,
        c.Create_Date,
        ROW_NUMBER() OVER (
            PARTITION BY c.ID
            ORDER BY c.UPDATED_AT DESC
        ) AS rn
    FROM JAFFLE_SHOP.raw.raw_customers c
    JOIN highwatermark h
      ON c.UPDATED_AT > h.start_date AND c.UPDATED_AT <= h.end_date
),
deduped AS (
    SELECT *
    FROM ranked_customers
    WHERE rn = 1
    AND is_deleted= false
)
SELECT
    d.customer_id,
    d.customer_name,
    d.updated_at,
    d.IS_DELETED,
    d.Effective_Date,
-- Compare only DATE part for late arriving logic
    CASE
        WHEN DATE(d.Effective_Date) < DATE(d.Create_Date)
        THEN 'Y'
        ELSE 'N'
    END AS IsLateArriving,
    CASE
        WHEN existing.customer_id IS NULL THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.InsertDate
    END AS InsertDate,
    CASE
        WHEN existing.customer_id IS NULL
             OR d.customer_name <> existing.customer_name
             OR d.updated_at <> existing.updated_at
             OR d.IS_DELETED <> existing.IS_DELETED
        THEN CONVERT_TIMEZONE('Asia/Kolkata', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
        ELSE existing.ActionDate
    END AS ActionDate,
    CASE
        WHEN existing.customer_id IS NULL THEN 'I'
        WHEN d.customer_name <> existing.customer_name
             OR d.updated_at <> existing.updated_at
             OR d.IS_DELETED <> existing.IS_DELETED THEN 'U'
        ELSE 'I'
    END AS ActionType
FROM deduped d
LEFT JOIN JAFFLE_SHOP.staging.tbl_stg_customers existing
    ON d.customer_id = existing.customer_id


    Select * from marts.tbl_Customers


    -------------------------------------------
    CREATE OR REPLACE PROCEDURE JAFFLE_SHOP.METADATA.SP_SEND_MODEL_ALERT("INVOCATION_ID" VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
    proj STRING;
    tag_display STRING;
    model_err NUMBER := 0;

    model_rows_html STRING;
    html_body STRING;
    subject_line STRING;
BEGIN
    ------------------------------------------------------------------
    -- Extract project name from invocations table
    ------------------------------------------------------------------
    proj := (
        SELECT PROJECT_NAME
        FROM jaffle_shop.logs.invocations
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
        LIMIT 1
    );

    ------------------------------------------------------------------
    -- Extract tag(s) from INVOCATION_ARGS JSON
    ------------------------------------------------------------------
    tag_display := (
        SELECT IFF(
            INVOCATION_ARGS:"select" IS NULL,
            ''All Tags'',
            ARRAY_TO_STRING(INVOCATION_ARGS:"select", '' '')
        )
        FROM jaffle_shop.logs.invocations
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
        LIMIT 1
    );

    ------------------------------------------------------------------
    -- Count model errors
    ------------------------------------------------------------------
    model_err := (
        SELECT COUNT(*)
        FROM jaffle_shop.logs.model_executions
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
          AND status = ''error''
    );

    IF (model_err = 0) THEN
        RETURN ''No model errors for invocation '' || INVOCATION_ID;
    END IF;

    ------------------------------------------------------------------
    -- Build failing model rows HTML
    ------------------------------------------------------------------
    model_rows_html := (
        SELECT LISTAGG(
            ''<tr style="color:#b00000;">'' ||
            ''<td>'' || SPLIT_PART(node_id, ''.'', 3) || ''</td>'' ||
            ''<td>'' || COMMAND_INVOCATION_ID || ''</td>'' ||
            ''<td>'' || UPPER(status) || ''</td>'' ||
            ''<td>'' || REPLACE(REPLACE(COALESCE(message,''''), CHR(13), ''''), CHR(10), ''<br/>'') || ''</td>'' ||
            ''<td>'' || TO_VARCHAR(run_started_at) || ''</td>'' ||
            ''<td>'' || TO_VARCHAR(query_completed_at) || ''</td>'' ||
            ''<td>'' || DATEDIFF(seconds, run_started_at, query_completed_at) || '' sec</td>'' ||
            ''</tr>'',
            ''''
        )
        FROM jaffle_shop.logs.model_executions
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
          AND status = ''error''
    );

    ------------------------------------------------------------------
    -- Construct full HTML body
    ------------------------------------------------------------------
    html_body :=
        ''<html><body style="font-family:Arial,Helvetica,sans-serif;">'' ||
        ''<h2 style="color:#b00000;">DBT Model Failure Alert</h2>'' ||
        ''<h3>Project: '' || proj || ''</h3>'' ||
        ''<h3>Tags: '' || tag_display || ''</h3>'' ||
        ''<p>Invocation ID: <b>'' || INVOCATION_ID || ''</b></p>'' ||
        ''<p><b>'' || model_err || ''</b> model(s) failed.</p>'' ||

        ''<table border="1" cellpadding="6" cellspacing="0" '' ||
        ''style="border-collapse:collapse; width:100%; font-size:13px;">'' ||
        ''<tr style="background-color:#f5c6cb;">'' ||
        ''<th>Model</th><th>Invocation</th><th>Status</th>'' ||
        ''<th>Message</th><th>Started At</th><th>Completed At</th><th>Duration</th>'' ||
        ''</tr>'' ||
        COALESCE(model_rows_html, ''<tr><td colspan="7">No model errors</td></tr>'') ||
        ''</table>'' ||

        ''<p style="color:#777;">Generated At: '' || CURRENT_TIMESTAMP() || ''</p>'' ||
        ''</body></html>'';

    ------------------------------------------------------------------
    -- Email subject
    ------------------------------------------------------------------
    subject_line := ''DBT Model Alert – '' || proj || '' | Tags: '' || tag_display;

    ------------------------------------------------------------------
    -- Send email
    ------------------------------------------------------------------
    CALL SYSTEM$SEND_EMAIL(
        ''email_alerts_integration'',
        ''swetha.palanisamy@elait.com, kirti.sharma@elait.com, harika.dharmapuri@elait.com, sambit.nayak@elait.com, roshan.lal@elait.com'',
        :subject_line,
        :html_body,
        ''text/html''
    );

    RETURN ''Model alert sent for invocation '' || INVOCATION_ID;

EXCEPTION
    WHEN OTHER THEN
        RETURN ''Error in SP_SEND_MODEL_ALERT: '' || SQLERRM;
END;
';

---------------------------------

CREATE OR REPLACE PROCEDURE JAFFLE_SHOP.METADATA.SP_SEND_TEST_ALERT("INVOCATION_ID" VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS '
DECLARE
    proj STRING;
    tag_display STRING;

    fail_count NUMBER := 0;
    warn_count NUMBER := 0;
    error_count NUMBER := 0;

    test_rows_html STRING;
    html_body STRING;
    subject_line STRING;
BEGIN
    ------------------------------------------------------------------
    -- Project name from invocations table
    ------------------------------------------------------------------
    proj := (
        SELECT PROJECT_NAME
        FROM jaffle_shop.logs.invocations
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
        LIMIT 1
    );

    ------------------------------------------------------------------
    -- Extract tag(s) from INVOCATION_ARGS JSON
    ------------------------------------------------------------------
    tag_display := (
        SELECT 
            IFF(
                INVOCATION_ARGS:"select" IS NULL,
                ''All Tags'',
                ARRAY_TO_STRING(INVOCATION_ARGS:"select", '' '')
            )
        FROM jaffle_shop.logs.invocations
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
        LIMIT 1
    );

    ------------------------------------------------------------------
    -- Summary counts
    ------------------------------------------------------------------
    SELECT
        COALESCE(SUM(CASE WHEN status = ''fail'' THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN status = ''warn'' THEN 1 ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN status = ''error'' THEN 1 ELSE 0 END), 0)
    INTO fail_count, warn_count, error_count
    FROM jaffle_shop.logs.test_executions
    WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID;

    IF (fail_count = 0 AND warn_count = 0 AND error_count = 0) THEN
        RETURN ''No test issues for invocation '' || INVOCATION_ID;
    END IF;

    ------------------------------------------------------------------
    -- Build test rows HTML
    ------------------------------------------------------------------
    test_rows_html := (
        SELECT LISTAGG(
            ''<tr style="color:'' ||
                CASE 
                    WHEN status = ''fail''  THEN ''red''
                    WHEN status = ''warn''  THEN ''orange''
                    WHEN status = ''error'' THEN ''#b00000''
                END || '';">'' ||
            ''<td>'' || SPLIT_PART(node_id, ''.'', 3) || ''</td>'' ||
            ''<td>'' || COMMAND_INVOCATION_ID || ''</td>'' ||
            ''<td>'' || UPPER(status) || ''</td>'' ||
            ''<td>'' || REPLACE(REPLACE(COALESCE(message,''''), CHR(13), ''''), CHR(10), ''<br/>'') || ''</td>'' ||
            ''<td>'' || TO_VARCHAR(run_started_at) || ''</td>'' ||
            ''<td>'' || TO_VARCHAR(query_completed_at) || ''</td>'' ||
            ''<td>'' || DATEDIFF(seconds, run_started_at, query_completed_at) || '' sec</td>'' ||
            ''</tr>'',
            ''''
        )
        FROM jaffle_shop.logs.test_executions
        WHERE COMMAND_INVOCATION_ID = :INVOCATION_ID
          AND status IN (''fail'',''warn'',''error'')
    );

    ------------------------------------------------------------------
    -- Build HTML for email
    ------------------------------------------------------------------
    html_body := 
        ''<html><body style="font-family:Arial;">'' ||
        ''<h2 style="color:#b00000;">DBT Test Alert</h2>'' ||
        ''<h3>Project: '' || proj || ''</h3>'' ||
        ''<h3>Tags: '' || tag_display || ''</h3>'' ||
        ''<p>Invocation ID: <b>'' || INVOCATION_ID || ''</b></p>'' ||

        ''<p>'' ||
        ''Failed: <b>'' || fail_count || ''</b><br/>'' ||
        ''Warning: <b>'' || warn_count || ''</b><br/>'' ||
        ''Error: <b>''   || error_count || ''</b>'' ||
        ''</p>'' ||

        ''<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; width:100%;">'' ||
        ''<tr style="background-color:#f8d7da;">'' ||
        ''<th>Test</th><th>Invocation</th><th>Status</th>'' ||
        ''<th>Message</th><th>Start</th><th>End</th><th>Duration</th>'' ||
        ''</tr>'' ||
        COALESCE(test_rows_html, ''<tr><td colspan="7">No issues</td></tr>'') ||
        ''</table><br/>'' ||

        ''<p style="color:#777;">Generated at: '' || CURRENT_TIMESTAMP() || ''</p>'' ||
        ''</body></html>'';

    ------------------------------------------------------------------
    -- Subject line
    ------------------------------------------------------------------
    subject_line := ''DBT Test Alert – '' || proj || '' | Tags: '' || tag_display;

    ------------------------------------------------------------------
    -- Send email
    ------------------------------------------------------------------
    CALL SYSTEM$SEND_EMAIL(
        ''email_alerts_integration'',
        ''swetha.palanisamy@elait.com, kirti.sharma@elait.com, harika.dharmapuri@elait.com, sambit.nayak@elait.com, roshan.lal@elait.com'',
        :subject_line,
        :html_body,
        ''text/html''
    );

    RETURN ''Test alert sent for invocation '' || INVOCATION_ID;

EXCEPTION
    WHEN OTHER THEN
        RETURN ''Error in SP_SEND_TEST_ALERT: '' || SQLERRM;
END;
';

SHOW INTEGRATIONS;
DESC INTEGRATION EMAIL_ALERTS_INTEGRATION;

select * from  marts.tbl_Customers

Select * from lcf.highwatermark

