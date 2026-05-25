# ============================================================
# Project      : ShopInDoor Variance Analytics
# Description  : Bronze layer load script
#                Loads raw data from .xlsb file into SQL Server
# Author       : Nkosinathi Mlotshwa
# Date         : 2026
# ============================================================

import pandas as pd
import sqlalchemy
from dotenv import load_dotenv
import os

# ── 1. Load environment variables from .env file ────────────
load_dotenv()

server   = os.getenv('DB_SERVER')
database = os.getenv('DB_NAME')
driver   = os.getenv('DB_DRIVER')

# ── 2. File path to source data ─────────────────────────────
file_path = r"C:\Users\pnmlo\Desktop\Case Study\Case study_Data_Analyst_intern .xlsb"

# ── 3. Establish connection to SQL Server ───────────────────
engine = sqlalchemy.create_engine(
    rf'mssql+pyodbc://{server}/{database}?driver={driver}&trusted_connection=yes'
)

# ── 4. Read both sheets from .xlsb file ─────────────────────
print("Reading .xlsb file...")

with pd.ExcelFile(file_path, engine='pyxlsb') as xf:
    hfm_budget = pd.read_excel(xf, sheet_name='HFM_Budget')
    erp_sales  = pd.read_excel(xf, sheet_name='ERP_Sales')

print(f"HFM_Budget : {hfm_budget.shape[0]} rows, {hfm_budget.shape[1]} columns")
print(f"ERP_Sales  : {erp_sales.shape[0]} rows, {erp_sales.shape[1]} columns")

# ── 5. Load raw data into bronze layer ──────────────────────
print("\nLoading into bronze layer...")

hfm_budget.to_sql(
    'HFM_Budget',
    engine,
    schema='bronze',
    if_exists='replace',
    index=False
)
print("✅ bronze.HFM_Budget loaded successfully")

erp_sales.to_sql(
    'ERP_Sales',
    engine,
    schema='bronze',
    if_exists='replace',
    index=False
)
print("✅ bronze.ERP_Sales loaded successfully")

print("\n🎉 Bronze layer load complete!")
