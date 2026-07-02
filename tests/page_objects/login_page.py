from playwright.sync_api import Page

class LoginPage:
    def __init__(self, page: Page):
        self.page = page
        self.username = page.get_by_label("Username:")
        self.password = page.get_by_label("Password:")
        self.role = page.get_by_role("combobox")
        self.terms = page.locator("#terms")
        self.sign_in = page.get_by_role("button", name="Sign In")

    def goto(self):
        self.page.goto("https://rahulshettyacademy.com/loginpagePractise/")

    def login(self, user: str, pwd: str, role: str = "teach"):
        self.username.fill(user)
        self.password.fill(pwd)
        self.role.select_option(role)
        self.terms.check()
        self.sign_in.click()
