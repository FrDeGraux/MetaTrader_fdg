import pandas as pd
import os
from utils.utilData import unpackComment_MM

def read_positions(sBaseTickPath) :

    df_positions = pd.read_csv(os.path.join(sBaseTickPath), sep=";", encoding='utf-16',dtype=str)

    list_first_trial = [' Ticket               ','Entry               ','Time                ','Reason              ','Position ID        (missed string parameter)','Volume              ','Price               ','Commission          ','Swap                ','Swap_corrected','Profit              ','Symbol              ','Comment            ','sl                  ','tp                  ']
    list_second_trial = [' Ticket               ','Entry               ','Type                ','Time                ','Reason              ','Position ID        (missed string parameter)','Volume              ','Price               ','Commission          ','Swap                ','Swap_corrected','Profit ','Symbol              ','Comment             (missed string parameter)','sl                  ','tp                  ','Comment                                  ','MFE                 ','MAE                 ','Commissions         ','Point              ']
    df_positions = df_positions[list_second_trial]
    df_positions.columns = df_positions.columns.str.replace(' ', '',regex = True)
    df_positions.columns = df_positions.columns.str.replace('(missedstringparameter)','',regex = True)
    df_positions = pd.concat([df_positions,],axis=1)



    df_positions['Symbol'] = df_positions['Symbol'].str.replace(' ', '')

    df_positions['Entry'] = df_positions['Entry'].str.replace(' ', '')
    df_positions['Reason'] = df_positions['Reason'].str.replace(' ', '')
    df_positions['Time'] = pd.to_datetime(df_positions['Time'])
    #  df_positions = df_positions[mask]
    df_positions = df_positions.set_index(pd.DatetimeIndex(df_positions['Time']))
    cols = df_positions.columns.drop(['Symbol','Comment()','Comment','PositionID()','Reason','Time','Entry','Type','Point'])
    df_positions[cols] = df_positions[cols].apply(pd.to_numeric, errors='coerce')


    return df_positions