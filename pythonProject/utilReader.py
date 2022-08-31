import pandas as pd
import os
def read_positions(sBaseTickPath) :
   # df_positions = pd.read_csv(os.path.join(sBaseTickPath), sep="\t", encoding='utf-16')
    df_positions = pd.read_csv(os.path.join(sBaseTickPath), sep=";", encoding='utf-16')
    df_positions = df_positions[[' Ticket               ','Entry               ','Time                ','Reason              ','Position ID        (missed string parameter)','Volume              ','Price               ','Commission          ','Swap                ','Profit              ','Symbol              ','Comment            ','sl                  ','tp                  ']]
    df_positions.columns = df_positions.columns.str.replace(' ', '')
    df_positions['Symbol'] = df_positions['Symbol'].str.replace(' ', '')

    df_positions['Entry'] = df_positions['Entry'].str.replace(' ', '')
    df_positions['Reason'] = df_positions['Reason'].str.replace(' ', '')
    df_positions['Time'] = pd.to_datetime(df_positions['Time'])

    df_positions = df_positions.set_index(pd.DatetimeIndex(df_positions['Time']))
    return df_positions