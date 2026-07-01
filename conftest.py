import os
import sys
import uuid
import allure
import pytest

def pytest_configure(config):
    """Ensure Allure results directory exists and write environment.properties."""
    results_dir = config.getoption("--alluredir") or "allure-results"
    os.makedirs(results_dir, exist_ok=True)

    env_file = os.path.join(results_dir, "environment.properties")
    try:
        with open(env_file, "w") as f:
            f.write(f"Platform={os.name}\n")
            f.write(f"Python={sys.version.split()[0]}\n")
            if os.getenv("GITHUB_RUN_ID"):
                f.write(f"CI=github-actions\n")
                f.write(f"GITHUB_RUN_ID={os.getenv('GITHUB_RUN_ID')}\n")
                f.write(f"GITHUB_REF={os.getenv('GITHUB_REF')}\n")
    except Exception:
        pass

@pytest.hookimpl(hookwrapper=True, tryfirst=True)
def pytest_runtest_makereport(item, call):
    """Attach Playwright screenshot and page HTML when a test fails."""
    outcome = yield
    rep = outcome.get_result()

    if rep.when == "call" and rep.failed:
        results_dir = item.config.getoption("--alluredir") or "allure-results"
        os.makedirs(results_dir, exist_ok=True)

        # Try several possible fixture names that might hold a Playwright page
        page = (
            item.funcargs.get("page")
            or item.funcargs.get("playwright_page")
            or item.funcargs.get("browserInstance")
            or item.funcargs.get("browser_page")
        )

        try:
            if page:
                # Prefer bytes return (no path)
                try:
                    png = page.screenshot(full_page=True)
                    if png:
                        allure.attach(png, name="screenshot", attachment_type=allure.attachment_type.PNG)
                except TypeError:
                    # Fallback to saving file and attaching it
                    tmp_png = os.path.join(results_dir, f"screenshot-{uuid.uuid4().hex}.png")
                    try:
                        page.screenshot(path=tmp_png, full_page=True)
                        allure.attach.file(tmp_png, name="screenshot", attachment_type=allure.attachment_type.PNG)
                    except Exception:
                        pass

                # Attach HTML source
                try:
                    html = page.content()
                    if html:
                        allure.attach(html, name="page-source", attachment_type=allure.attachment_type.HTML)
                except Exception:
                    pass
        except Exception as e:
            try:
                allure.attach(str(e), name="attachment-error", attachment_type=allure.attachment_type.TEXT)
            except Exception:
                pass
