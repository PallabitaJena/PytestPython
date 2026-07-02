@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM JENKINS PYTEST AUTOMATION - SIMPLE APPROACH
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

REM Clean old results
echo Cleaning old test results...
if exist allure-results rmdir /s /q allure-results
if exist allure-report rmdir /s /q allure-report
if exist report.html del /f /q report.html

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt
python -m playwright install

if "!REPORT_TYPE!"=="html" (
    pip install pytest-html
)

REM Build pytest command
set PYTEST_CMD=python -m pytest tests pytestDir bdd_Playwright_ --browser_name=!BROWSER! -v --tb=short

if not "!TEST_MARKER!"=="all" (
    set PYTEST_CMD=!PYTEST_CMD! -m "!TEST_MARKER!"
)

REM Add report option
if "!REPORT_TYPE!"=="html" (
    set PYTEST_CMD=!PYTEST_CMD! --html=report.html --self-contained-html
) else (
    set PYTEST_CMD=!PYTEST_CMD! --alluredir=allure-results
)

echo Running tests...
echo Command: !PYTEST_CMD!
echo.

call !PYTEST_CMD!
set TEST_RESULT=%errorlevel%

echo.
echo ========================================================
echo GENERATING REPORT
echo ========================================================

if "!REPORT_TYPE!"=="allure" (
    echo Generating Allure Report...
    allure generate allure-results -o allure-report --clean
) else if "!REPORT_TYPE!"=="html" (
    echo HTML Report generated: report.html
)

echo.
exit /b !TEST_RESULT!
