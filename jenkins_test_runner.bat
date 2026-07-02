@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM JENKINS PYTEST HTML REPORT - ENHANCED VERSION
REM ========================================================

set TEST_MARKER=%TEST_MARKER%
set BROWSER=%BROWSER%
set REPORT_TYPE=%REPORT_TYPE%

if "!TEST_MARKER!"=="" set TEST_MARKER=smoke
if "!BROWSER!"=="" set BROWSER=chrome
if "!REPORT_TYPE!"=="" set REPORT_TYPE=allure

echo.
echo ========================================================
echo PARAMETERS: TEST_MARKER=!TEST_MARKER! BROWSER=!BROWSER! REPORT_TYPE=!REPORT_TYPE!
echo ========================================================
echo.

echo Installing dependencies...
pip install -r requirements.txt
python -m playwright install

if "!REPORT_TYPE!"=="html" (
    echo Installing pytest-html...
    pip install pytest-html
)

REM Build pytest command - runs from all test directories
set PYTEST_CMD=python -m pytest tests pytestDir bdd_Playwright_ --browser_name=!BROWSER! --alluredir=allure-results -v --tb=short

REM Add marker if not "all"
if not "!TEST_MARKER!"=="all" (
    set PYTEST_CMD=!PYTEST_CMD! -m "!TEST_MARKER!"
)

REM Add HTML report with enhanced options
if "!REPORT_TYPE!"=="html" (
    set PYTEST_CMD=!PYTEST_CMD! --html=report.html --self-contained-html --tb=short
)

echo.
echo ========================================================
echo RUNNING TESTS FROM MULTIPLE DIRECTORIES
echo ========================================================
echo Command: !PYTEST_CMD!
echo.

call !PYTEST_CMD!
set TEST_RESULT=%errorlevel%

echo.
echo ========================================================
echo GENERATING REPORT
echo ========================================================
echo.

if "!REPORT_TYPE!"=="allure" (
    echo Generating Allure Report...
    allure generate allure-results -o allure-report --clean
    if errorlevel 1 (
        echo ERROR: Failed to generate Allure report
        echo Install Allure: https://docs.qameta.io/allure/
    ) else (
        echo Allure report generated: allure-report/index.html
    )
) else if "!REPORT_TYPE!"=="html" (
    echo HTML Report Location: report.html
    echo Total Tests Run: Check report.html for details
)

echo.
echo ========================================================
echo TEST RUN COMPLETED (Exit Code: !TEST_RESULT!)
echo ========================================================
echo.

exit /b !TEST_RESULT!
