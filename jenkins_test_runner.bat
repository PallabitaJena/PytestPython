@echo off
REM ========================================================
REM JENKINS PYTEST AUTOMATION - FIXED VERSION
REM ========================================================
REM This script handles both Allure and HTML reports
REM ========================================================

setlocal enabledelayedexpansion

REM Set variables from Jenkins parameters
set TEST_MARKER=%TEST_MARKER%
set BROWSER=%BROWSER%
set REPORT_TYPE=%REPORT_TYPE%
set HEADLESS_MODE=%HEADLESS_MODE%

REM Default values if not set
if "!TEST_MARKER!"=="" set TEST_MARKER=smoke
if "!BROWSER!"=="" set BROWSER=chrome
if "!REPORT_TYPE!"=="" set REPORT_TYPE=allure
if "!HEADLESS_MODE!"=="" set HEADLESS_MODE=false

echo.
echo ========================================================
echo PARAMETERS:
echo TEST_MARKER: !TEST_MARKER!
echo BROWSER: !BROWSER!
echo REPORT_TYPE: !REPORT_TYPE!
echo HEADLESS_MODE: !HEADLESS_MODE!
echo ========================================================
echo.

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install requirements
    exit /b 1
)

echo Installing Playwright browsers...
python -m playwright install
if errorlevel 1 (
    echo ERROR: Failed to install Playwright browsers
    exit /b 1
)

REM Install pytest-html if HTML report is selected
if "!REPORT_TYPE!"=="html" (
    echo Installing pytest-html...
    pip install pytest-html
    if errorlevel 1 (
        echo ERROR: Failed to install pytest-html
        exit /b 1
    )
)

REM Build the pytest command
set PYTEST_CMD=python -m pytest --browser_name=!BROWSER! --alluredir=allure-results -v

REM Add marker if not "all"
if not "!TEST_MARKER!"=="all" (
    set PYTEST_CMD=!PYTEST_CMD! -m "!TEST_MARKER!"
)

REM Add HTML report option if selected
if "!REPORT_TYPE!"=="html" (
    set PYTEST_CMD=!PYTEST_CMD! --html=report.html --self-contained-html
)

echo.
echo ========================================================
echo RUNNING TESTS...
echo Command: !PYTEST_CMD!
echo ========================================================
echo.

REM Run the tests
call !PYTEST_CMD!
set TEST_RESULT=%errorlevel%

if !TEST_RESULT! neq 0 (
    echo WARNING: Some tests failed (exit code: !TEST_RESULT!)
)

echo.
echo ========================================================
echo GENERATING REPORT...
echo ========================================================
echo.

REM Generate reports based on REPORT_TYPE
if "!REPORT_TYPE!"=="allure" (
    echo Generating Allure Report...
    allure generate allure-results -o allure-report --clean
    if errorlevel 1 (
        echo ERROR: Failed to generate Allure report
        echo Make sure Allure CLI is installed: https://docs.qameta.io/allure/
    ) else (
        echo Allure report generated successfully!
        echo Report location: allure-report/index.html
    )
) else if "!REPORT_TYPE!"=="html" (
    echo HTML Report generated successfully!
    echo Report location: report.html
) else (
    echo Unknown report type: !REPORT_TYPE!
)

echo.
echo ========================================================
echo TEST RUN COMPLETED
echo ========================================================
echo.

exit /b !TEST_RESULT!
