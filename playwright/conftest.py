import os
import sys
import allure
import pytest



def pytest_addoption(parser):
    parser.addoption(
        "--browser_name", action="store", default="chrome", help="browser selection"
    )
    parser.addoption(
        "--url_name", action="store", default="https://rahulshettyacademy.com/client", help="server selection"
    )


@pytest.fixture(scope="session")
def user_credentials(request):
    return request.param


@pytest.fixture
def browserInstance(playwright, request):
    browser_name = request.config.getoption("browser_name")
    url_name = request.config.getoption("url_name")
    if browser_name == "chrome":
        browser = playwright.chromium.launch(headless=False)
    elif browser_name == "firefox":
        browser = playwright.firefox.launch(headless=False)

    context = browser.new_context()
    page = context.new_page()
    #page.goto(url_name)
    yield page
    context.close()
    browser.close()
#2 times, 1st run opened browser and completed, homepage





def pytest_configure(config):
    """Ensure Allure results directory exists and write environment.properties."""
    results_dir = config.getoption("--alluredir") or "allure-results"
    os.makedirs(results_dir, exist_ok=True)

    # Write some environment info visible in Allure (optional, but helpful)
    env_file = os.path.join(results_dir, "environment.properties")
    try:
        with open(env_file, "w") as f:
            f.write(f"Platform={os.name}\n")
            f.write(f"Python={sys.version.split()[0]}\n")
            # Common CI env variables (if present)
            if os.getenv("GITHUB_RUN_ID"):
                f.write(f"CI=github-actions\n")
                f.write(f"GITHUB_RUN_ID={os.getenv('GITHUB_RUN_ID')}\n")
                f.write(f"GITHUB_REF={os.getenv('GITHUB_REF')}\n")
    except Exception:
        # Don't fail tests if we cannot write the env file
        pass

@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_makereport(item, call):
    """
    On test failure (call phase), attach Playwright page screenshot and page HTML to Allure.
    Works when your tests/steps use the pytest-playwright 'page' fixture.
    """
    outcome = yield
    rep = outcome.get_result()

    if rep.when == "call" and rep.failed:
        # Try to fetch common Playwright fixtures: page, context or playwright_page
        page = item.funcargs.get("page") or item.funcargs.get("playwright_page")
        # Optionally, attach any file paths set on the test item (custom)
        try:
            if page:
                # Screenshot (bytes)
                png = page.screenshot(full_page=True)
                if png:
                    allure.attach(png, name="screenshot", attachment_type=allure.attachment_type.PNG)

                # HTML source
                try:
                    html = page.content()
                    allure.attach(html, name="page-source", attachment_type=allure.attachment_type.HTML)
                except Exception:
                    # If page.content() fails, ignore
                    pass
        except Exception as e:
            # Attach the exception text so we know attachment failed
            try:
                allure.attach(str(e), name="attachment-error", attachment_type=allure.attachment_type.TEXT)
            except Exception:
                pass