CREATE OR REPLACE PROCEDURE LCF.SP_SEND_DBT_TEST_FAILURE_ALERT(tag_name STRING DEFAULT NULL)
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
    failed_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'fail');
    warning_tests := (SELECT COUNT(*) FROM LCF.TestCaseExecution WHERE STATUS = 'warn');

    ----------------------------------------------------------------
    -- Build HTML rows
    ----------------------------------------------------------------
    failed_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:red;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'fail'
    );

    warning_table := (
        SELECT LISTAGG('<tr><td>' || TEST_NAME || '</td><td style="color:orange;">' || STATUS || '</td><td>' || MESSAGE || '</td></tr>', '')
        FROM LCF.TestCaseExecution
        WHERE STATUS = 'warn'
    );

    ----------------------------------------------------------------
    -- Prepare subject and body
    ----------------------------------------------------------------
    IF (tag_name IS NULL OR tag_name = '') THEN
        tag_display := 'All Tags';
    ELSE
        tag_display := 'Tag: ' || tag_name;
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
        cmd := 'CALL SYSTEM$SEND_EMAIL(''email_alerts_integration'', ''roshan.lal@elait.com'', ' ||
               '''' || REPLACE(email_subject, '''', '''''') || ''', ''' ||
               REPLACE(email_body, '''', '''''') || ''', ''text/html'')';

        EXECUTE IMMEDIATE cmd;

        RETURN '📧 Email sent successfully. Found ' || failed_tests || ' failed and ' || warning_tests || ' warnings.';
    ELSE
        RETURN '✅ No failing or warning tests found.';
    END IF;
END;
$$;

CALL LCF.SP_SEND_DBT_TEST_FAILURE_ALERT('customer')