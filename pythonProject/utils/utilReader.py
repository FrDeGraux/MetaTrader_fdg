import pandas as pd
import os
from utils.utilData import unpackComment_MM
def read_positions(sBaseTickPath) :
    df_positions = pd.read_csv(os.path.join(sBaseTickPath), sep=";", encoding='utf-16')

    list_first_trial = [' Ticket               ','Entry               ','Time                ','Reason              ','Position ID        (missed string parameter)','Volume              ','Price               ','Commission          ','Swap                ','Swap_corrected','Profit              ','Symbol              ','Comment            ','sl                  ','tp                  ']
    list_second_trial = [' Ticket               ','Entry               ','Type                ','Time                ','Reason              ','Position ID        (missed string parameter)','Volume              ','Price               ','Commission          ','Swap                ','Swap_corrected','Profit ','Symbol              ','Comment             (missed string parameter)','sl                  ','tp                  ']
    df_positions = df_positions[list_second_trial]
    df_positions.columns = df_positions.columns.str.replace(' ', '')
    df_positions.columns = df_positions.columns.str.replace('(missedstringparameter)','')


    df_positions = unpackComment_MM(df_positions)






    df_positions['Symbol'] = df_positions['Symbol'].str.replace(' ', '')

    df_positions['Entry'] = df_positions['Entry'].str.replace(' ', '')
    df_positions['Reason'] = df_positions['Reason'].str.replace(' ', '')
    df_positions['Time'] = pd.to_datetime(df_positions['Time'])

    df_positions = df_positions.set_index(pd.DatetimeIndex(df_positions['Time']))
    return df_positions