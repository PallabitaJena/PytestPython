@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM JENKINS PYTEST AUTOMATION WITH CUSTOM HTML REPORT
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

REM Step 1: Install dependencies
echo [STEP 1/4] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install requirements
    exit /b 1
)

python -m playwright install
if errorlevel 1 (
    echo ERROR: Failed to install Playwright browsers
    exit /b 1
)

REM Step 2: Install report generation tools
echo [STEP 2/4] Installing report tools...
pip install pytest-html allure-pytest
if errorlevel 1 (
    echo WARNING: Some packages already installed
)

REM Step 3: Run tests
echo [STEP 3/4] Running tests...
set PYTEST_CMD=python -m pytest tests pytestDir bdd_Playwright_ --browser_name=!BROWSER! -v --tb=short --alluredir=allure-results

if not "!TEST_MARKER!"=="all" (
    set PYTEST_CMD=!PYTEST_CMD! -m "!TEST_MARKER!"
)

echo Command: !PYTEST_CMD!
echo.

call !PYTEST_CMD!
set TEST_RESULT=%errorlevel%

echo.
echo [STEP 4/4] Generating reports...

REM Step 4: Generate reports
if "!REPORT_TYPE!"=="allure" (
    echo Generating Allure Report...
    allure generate allure-results -o allure-report --clean
    if errorlevel 1 (
        echo WARNING: Allure report generation may have issues
    )
) else if "!REPORT_TYPE!"=="html" (
    echo Generating Jenkins-compatible HTML Report...
    python generate_report.py
    if errorlevel 1 (
        echo ERROR: Failed to generate HTML report
        exit /b 1
    )
)

echo.
echo ========================================================
echo TEST RUN COMPLETED
echo ========================================================
echo.

exit /b !TEST_RESULT!
