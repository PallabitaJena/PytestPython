# PytestPython — Playwright + pytest demo

This repository is a learning/test playground for Playwright + pytest + pytest-bdd, enhanced with Allure reporting support.

Quick start (recommended):

1. Create and activate a virtual environment

```bash
python -m venv .venv
# macOS / Linux
source .venv/bin/activate
# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies and Playwright browsers

```bash
pip install -r requirements.txt
python -m playwright install
```

3. Run tests and produce Allure results

```bash
pytest --alluredir=allure-results -q
```

4. Generate and view Allure HTML report (requires Allure CLI)

- Using locally installed Allure CLI:

```bash
allure generate allure-results -o allure-report --clean
# then open the report
# macOS
open allure-report/index.html
# Linux
xdg-open allure-report/index.html
```

- Using Docker (no local install):

```bash
docker run --rm -v "$PWD/allure-results":/app/allure-results -v "$PWD/allure-report":/app/allure-report frankescobar/allure-docker-service allure generate /app/allure-results -o /app/allure-report --clean
```

Notes
- The repository now includes a root-level `pytest.ini` and `conftest.py` that write Allure results and attach screenshots/page HTML on failures. The hook looks for several fixture names (`page`, `playwright_page`, `browserInstance`, `browser_page`) so it works with the current test fixtures.
- CI workflow generation was attempted but the integration lacked permission to add workflow files; if you want the workflow added I can open a PR or you can paste the workflow YAML from the branch `enhance/allure-setup` into `.github/workflows/pytest-allure.yml`.

Recommended next steps
- Run the test suite locally, confirm `allure-results` contains JSON and attachment files on failures.
- If desired, enable the GitHub Actions workflow (see `.github/workflows/pytest-allure.yml` in the branch) by creating that file in the repo root (some repositories restrict workflow creation to admins).

