import time
from playwright.sync_api import Page, Playwright, expect


def test_playwrightBasics(page: Page):
    # Use the pytest-playwright 'page' fixture (fresh context per test).
    page.goto("https://rahulshettyacademy.com")


def test_playwrightShortCut(page: Page):
    page.goto("https://rahulshettyacademy.com")


def test_coreLocators(page: Page):
    page.goto("https://rahulshettyacademy.com/loginpagePractise/")
    page.get_by_label("Username:").fill("rahulshettyacademy")
    page.get_by_label("Password:").fill("Learning@830$3mK2")
    page.get_by_role("combobox").select_option("teach")
    page.locator("#terms").check()
    page.get_by_role("link", name="terms and conditions").click()
    page.get_by_role("button", name="Sign In").click()
    expect(page.get_by_text("Incorrect username/password.")).to_be_visible()


def test_firefoxBrowser(playwright: Playwright):
    # If you need to explicitly test firefox, launch it headless for CI and close it cleanly
    firefox = playwright.firefox.launch(headless=True)
    context = firefox.new_context()
    page = context.new_page()
    page.goto("https://rahulshettyacademy.com/loginpagePractise/")
    page.get_by_label("Username:").fill("rahulshettyacademy")
    page.get_by_label("Password:").fill("Learning@830$3mK2")
    page.get_by_role("combobox").select_option("teach")
    page.locator("#terms").check()
    page.get_by_role("link", name="terms and conditions").click()
    page.get_by_role("button", name="Sign In").click()
    expect(page.get_by_text("Incorrect username/password.")).to_be_visible()
    context.close()
    firefox.close()
