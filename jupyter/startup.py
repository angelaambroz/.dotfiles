import os
import scipy
import random
import requests
import pickle
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib as mpl
# import snowflake.connector as snow
from time import time
from pprint import PrettyPrinter
from sqlalchemy import create_engine
from matplotlib import pyplot as plt
from datetime import datetime, timedelta
from IPython.display import Javascript, display, HTML

# import tunbridge as tb

plt.style.use("bmh")


def alert(text: str = "All done!"):
    js = f'alert("{text}");'
    display(Javascript(js))


def flatten_jsonb(row):
    for key, value in row["request"].items():
        row[f"request_{key}"] = value

    if "result" in row["response"].keys():
        for key, value in row["response"]["result"][0].items():
            row[f"response_{key}"] = value

    return row


def df_shape(dataframe: pd.DataFrame) -> str:
    """Print the df shape nicely"""
    print(f"rows\t{dataframe.shape[0]:,.0f}")
    print(f"cols\t{dataframe.shape[1]:,.0f}")


def pull_data(
    query: str, db_cnx, save: bool = True, impatience: int = 120
) -> pd.DataFrame:
    DATA_DIR = "data"

    stime = time()
    data = pd.read_sql(query, db_cnx)
    data.rename(columns=lambda x: str.lower(x), inplace=True)
    etime = time()
    lapsed = etime - stime

    # Only alert if it takes more than 2 mins to pull
    if lapsed > impatience:
        alert(f"That took {lapsed:.2f} seconds.")

    print(f"That took {lapsed:.2f} seconds")
    print(data.shape)

    if save and lapsed > impatience:
        filetime = datetime.fromtimestamp(etime).strftime("%Y-%m-%d_%H:%M:%S")

        if DATA_DIR not in os.listdir():
            os.mkdir(DATA_DIR)

        data.to_csv(f"{DATA_DIR}/{filetime}_data.csv")

    return data


def figsize(x: int, y: int):
    mpl.rcParams["figure.figsize"] = (x, y)


def cnx(db: str):
    """Convenience function to connect to various Optoro db's

    db: ['dw', 'pg1', 'pg2', 'pv']
    """
    if db == "dw":
        engine = f'mysql+pymysql://{os.environ.get("MYSQL_USERNAME")}:{os.environ.get("MYSQL_PASSWORD")}@{os.environ.get("MYSQL_DB_URL")}/'

    if db == "pg1":
        engine = f'postgres://{os.environ.get("PSQL_USERNAME")}:{os.environ.get("PSQL_PASSWORD")}@{os.environ.get("PSQL1_DB_URL")}'

    if db == "pg2":
        engine = f'postgres://{os.environ.get("PSQL_USERNAME")}:{os.environ.get("PSQL_PASSWORD")}@{os.environ.get("PSQL2_DB_URL")}'

    if db == "pv":
        engine = f'postgres://{os.environ.get("PV_USERNAME")}:{os.environ.get("PV_PASSWORD")}@{os.environ.get("PV_DB_URL")}'

    if db == "snow":
        engine = snow.connect(
            user=os.environ["SNOWFLAKE_UN"],
            password=os.environ["SNOWFLAKE_PW"],
            account=os.environ["SNOWFLAKE_ACCOUNT"],
            role="SYSADMIN",
            warehouse="DS",
        )

        cs = engine.cursor()
        cs.execute("USE DW;")

        return engine

    return create_engine(engine, echo=False)


def what_loaded():
    print(f"Startup file has loaded - you can find this in {__file__}")


# TODO:
# alert("Loaded cnx(), alert(), figsize(), df_shape()")
