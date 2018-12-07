import os
import scipy
import random
import psycopg2
import requests
import pickle
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib as mpl
import snowflake.connector as snow
from time import time
from sqlalchemy import create_engine
from matplotlib import pyplot as plt
from datetime import datetime, timedelta
from IPython.display import Javascript, display

import tunbridge as tb

plt.style.use('bmh')


def alert(text: str = 'All done!'):  
    js = f'alert("{text}");'
    display(Javascript(js))

def figsize(x: int, y: int):
    mpl.rcParams['figure.figsize'] = (x, y)

def cnx(db: str):
    """Convenience function to connect to various Optoro db's

    db: ['dw', 'pg1', 'pg2', 'pv']
    """
    if db == 'dw':
        engine = f'postgres+pymysql://{os.environ.get("MYSQL_USERNAME")}:{os.environ.get("MYSQL_PASSWORD")}@{os.environ.get("MYSQL_DB_URL")}/'

    if db == 'pg1':
        engine = f'postgres://{os.environ.get("PSQL_USERNAME")}:{os.environ.get("PSQL_PASSWORD")}@{os.environ.get("PSQL1_DB_URL")}'
    
    if db == 'pg2':
        engine = f'postgres://{os.environ.get("PSQL_USERNAME")}:{os.environ.get("PSQL_PASSWORD")}@{os.environ.get("PSQL2_DB_URL")}'
    
    if db == 'pv':
        engine = f'postgres://{os.environ.get("PV_USERNAME")}:{os.environ.get("PV_PASSWORD")}@{os.environ.get("PV_DB_URL")}' 

    if db == 'snow':
        engine = snow.connect(
            user=os.environ['SNOWFLAKE_UN'],
            password=os.environ['SNOWFLAKE_PW'],
            account=os.environ['SNOWFLAKE_ACCOUNT']
            )

        cs = engine.cursor()
        cs.execute("USE DW;")

        return engine

    
    return create_engine(engine, echo=False)


def df_shape(dataframe: pd.DataFrame) -> str:
    """Print the df shape nicely"""
    print(f'rows\t{dataframe.shape[0]:,.0f}')
    print(f'cols\t{dataframe.shape[1]:,.0f}')


# TODO:
# alert("Loaded cnx(), alert(), figsize(), df_shape()")    

