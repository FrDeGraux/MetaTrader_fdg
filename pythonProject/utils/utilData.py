from utils.utilMapping import from_entry_to_category
import pandas as pd
import os
import numpy as np
def compute_loss_SL (in_df_position) :

    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'
    df_sl = in_df_position[mask_sl]
    df_sl = df_sl[['Profit', 'Swap', 'Commission']]
    df_sl = df_sl.sum(axis=1)
    return df_sl
def get_point_digit(in_symbol):
    sDepositCurr = in_symbol[-3]
    if(sDepositCurr == 'JPY'):
        return 3
    return 5
def unpackComment_MM(in_df_positions) :
    in_df_positions[['Slow_MM', 'Fast_MM','Other','Point']] = in_df_positions['Comment()'].str.split('_', expand=True)
    in_df_positions.drop(columns = ['Other'])
    return in_df_positions

# create a dataframe with in positions matched with out ones (entryIn, entryOut, etc)
def from_in_to_out_mapping(in_df_positions,in_config) :
    mask = in_df_positions['Entry'] == in_config.get('Names', 'Entry_Out')
    df_sell = (in_df_positions[mask])
    df_sell['Reason_number'] = df_sell.apply(lambda row: from_entry_to_category(row), axis=1)
    res = []
    for row in df_sell.iterrows() :
        row = row[1]
        val = row[in_config.get('Names', 'PositionMissedParameters')]
        mask_position = (in_df_positions[in_config.get('Names', 'PositionMissedParameters')] == val)
        df = in_df_positions[mask_position]
        df = df[df['Entry'] == in_config.get('Names', 'Entry_In')]
        if(len(df) > 1) :
            raise Exception('plot_return_durations::more than one purchase')
        entryIn = df['Time'].values[0]
        hysteresis_in = df['Hysteresis'].values[0]
        hysteresis_out = row['Hysteresis']
        entryOut = row['Time']

        res.append((entryIn,entryOut,row['Symbol'],(row['Profit']),hysteresis_in,hysteresis_out,(row['Reason_number'])))
    return(pd.DataFrame(res, columns =['TimeIn', 'TimeOut','Symbol', 'Profit','Hysteresis_in','Hysteresis_out','ReasonNumber']))
def getSymbolList(in_df_positions,in_configcommon) :
    symbolList = in_df_positions['Symbol'].unique()
    symbolList = [item.replace(' ', '') for item in symbolList]
    symbolList = symbolList + [(in_configcommon.get('Names', 'ALL_Symbol'))]

    return symbolList
def get_in_or_out_sign(in_type) :
    if (in_type == 'DEAL_ENTRY_IN'):
        return 1
    if (in_type == 'DEAL_ENTRY_OUT'):
        return -1
    else:
        raise Exception
def get_gross_position(in_type) :
    in_entry = in_type.strip()
    if ( in_entry == 'DEAL_ENTRY_IN') :
        return 1
    if (in_entry == 'DEAL_ENTRY_OUT') :
        return -1
    raise Exception
def get_net_position(in_type,in_entry) :
    in_type = in_type.strip()
    if (in_type == 'DEAL_TYPE_BUY' and in_entry == 'DEAL_ENTRY_IN') :
        return 1
    if (in_type == 'DEAL_TYPE_BUY' and in_entry == 'DEAL_ENTRY_OUT') :
        return 1
    if (in_type == 'DEAL_TYPE_SELL' and in_entry == 'DEAL_ENTRY_IN') :
        return -1
    if (in_type == 'DEAL_TYPE_SELL' and in_entry == 'DEAL_ENTRY_OUT') :
        return -1
    raise Exception
def filterBySymbol(in_df_position,in_symbol,in_config) :
    if in_symbol == in_config.get('Names', 'ALL_Symbol'):
        return in_df_position
    mask = in_df_position['Symbol'] == in_symbol
    in_df_position = in_df_position[mask]
    return in_df_position
def remove_none_points(in_df_position):
    mask = in_df_position['Point'] != None
    in_df_position = in_df_position[mask]
    return in_df_position
def filterOnInDeals(in_df_position):
    if not in_df_position['Symbol'].unique() :
        raise Exception
    mask = in_df_position['Entry'] == 'DEAL_ENTRY_IN'
    in_df_position_filtered = in_df_position[mask]
    in_df_position_filtered = in_df_position_filtered.append(in_df_position.tail(1))
    return in_df_position_filtered
def filterOnInDeals_AndLastOut(in_df_position):
    if not in_df_position['Symbol'].unique() :
        raise Exception
    mask = in_df_position['Entry'] == 'DEAL_ENTRY_IN'
    in_df_position_filtered = in_df_position[mask]
    in_df_position_filtered = in_df_position_filtered.append(in_df_position.tail(1))
    return in_df_position_filtered
def from_frequency_to_resample_period(in_freq) :
    map = {'H1' : '60min','H4' : '240min','D1':'D','W1' : '7D'}
    return map[in_freq]
def compute_reward_tp(in_df_position) :
    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    df_tp = in_df_position[mask_tp]
    df_tp = df_tp[['Profit', 'SwapReal', 'Commission']]
    df_tp = df_tp.sum(axis=1)
    return df_tp
def compute_profit_other(in_df_position) :
    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'
    df_other = in_df_position[~mask_tp & ~mask_sl]
    df_other = df_other[['Profit', 'SwapReal', 'Commission']]
    df_other = df_other.sum(axis=1)
    return df_other
def filter_on_entry_datetimes(in_df,startTime,in_dt_second) :
    filtered_df = in_df[(in_df['TimeIn_Date'] >= startTime)]
    filtered_df = filtered_df[(in_df['TimeIn_Date'] < (in_dt_second))]

    return(filtered_df)

def filter_on_entry_datetimes_cumulative(in_df,startTime,in_dt_second) :
    filtered_df = in_df[(in_df['TimeIn_Date'] < (in_dt_second))]

    return(filtered_df)
def create_directory_if_not_exists(in_dirName):
    if not os.path.isdir(in_dirName):
        os.makedirs(in_dirName)