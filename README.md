# Customer and Product Insights for Model Car Sales

In this project, I take on the role of a data analyst for a company that sells scale model cars. By analyzing historical sales data, I aim to extract insights that support better business decisions. The focus is on identifying product performance, understanding customer behavior, and informing strategies around inventory, marketing, and customer acquisition.

The ultimate goal is to help the company make smarter, data-informed decisions to improve efficiency, target the right customers, and boost sales.

## Tech Stack

<div>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/sqlite/sqlite-original.svg" title="SQLite" width="40" height="40" />&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/jupyter/jupyter-original.svg" title="Jupyter" width="40" height="40" />&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" title="Python" width="40" height="40" />&nbsp;
</div>

## Contents

-   [Project Structure](#project-structure)
-   [Database](#database)
-   [View it Online](#view-it-online)
-   [Steps to Run](#steps-to-run)
-   [License](#license)

## Project Structure

```
model-car-sales-sql/
├── notebook/            # Contains the Jupyter Notebook with all analysis and insights
├── project-files/       # Directory for SQLite database, database schema image, and SQL queries
├── .gitignore           # Lists ignored files for version control
├── requirements.txt     # Python package requirements (generated from pyproject.toml)
├── pyproject.toml       # Dependency and project metadata configuration
├── .python-version      # Defines Python version for virtual environments
├── uv.lock              # Dependency lock file for consistent installs
└── README.md            # Project overview and setup instructions
```

## Database

The analysis uses a sample SQLite database ([stores.db](./project-files/stores.db)) that contains sales records from a fictional scale model car business. It includes tables for customers, products, orders, and more.

You can view the [database schema image](./project-files/images/db-schema.png) for reference.

## View it Online

You can explore the full notebook directly in your browser using Binder:

[![Launch in Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/xjwllmsx/model-car-sales-sql/HEAD?urlpath=%2Fdoc%2Ftree%2Fnotebook%2Fmodel-car-sales.ipynb)

## Steps to Run

To run the notebook locally:

**1. Clone the repository**

```bash
git clone https://github.com/xjwllmsx/model-car-sales-sql.git
cd model-car-sales-sql
```

**2. Create and activate a virtual environment**

```bash
uv venv
uv pip install -r requirements.txt
```

**3. Launch Jupyter Notebook**

```bash
jupyter notebook notebook/analysis.ipynb
```

NOTE: If you're using `uv`, dependencies are managed via `pyproject.toml` instead of `requirements.txt`.

## License

This project is for educational purposes only. The database used is fictional and intended for practicing data analysis and SQL.
