import numpy as np
import pandas as pd
from utils.utilReader import read_positions

sFilePath = 'C:\\Users\\franc\\Documents\\MetaTrader_tests\\Strategy_1_MM_crossover_Hysteresis\\12_11_Run1_No_SL_No_TP_SMA\\Run_1.1_8_21\\H1\\12_11_Run1_No_SL_No_TP_SMA-Run_1.1_8_21-H1.csv'
dfPosition =read_positions(sFilePath)
entry_prices = []
entry_ATR = []
for idx,item in dfPosition.iterrows() :
    mask_position = (dfPosition['Ticket'] == int(item['PositionID()'])) & (dfPosition['Entry'] == 'DEAL_ENTRY_IN')
    row = dfPosition[mask_position]
    entry_prices.append(row['Price'].values[0])
    entry_ATR.append(row['ATR'].values[0])

gs = pd.DataFrame(list(zip(entry_prices,entry_ATR)),columns=['Entry_Price','ATR_entry'])
res = pd.concat([dfPosition,gs.set_index(dfPosition.index)],axis = 1)
factor = 1
res = res[(res['Entry'] == 'DEAL_ENTRY_OUT')]
res['tt'] = res['Type'].apply(lambda x: x)

res['sign'] = res['Type'].apply(lambda x: 1 if x == 'DEAL_TYPE_SELL' else -1)

res['lambda_SL'] =-res['sign']*factor*res['ATR_entry']
res['lambda_TP'] =res['sign']*factor*res['ATR_entry']


res.loc[res['lambda_SL'] > res['MAE'], 'hit_SL'] = 1
res.loc[res['lambda_SL'] <= res['MAE'], 'hit_SL'] = 0

res.loc[res['lambda_TP'] > res['MFE'], 'hit_TP'] = 1
res.loc[res['lambda_TP'] <= res['MFE'], 'hit_TP'] = 0
res['Odds'] = 0
mask = (res['hit_TP'] == 1) & (res['hit_SL'] == 1)
res['P_out'] = np.nan

res.loc[~mask,'P_out'] = res.loc[~mask,'Price']
res.loc[mask,'Odds'] = res['MAE']/(res['MAE'] + res['MFE'])
res.loc[~mask & res['hit_SL']== 1,'Odds'] =0
res.loc[~mask & res['hit_SL']== 1,'P_out'] = 1

res.loc[~mask & res['hit_SL']== 1,'P_out'] = res.loc[~mask & res['hit_SL']== 1,'Entry_Price']-res.loc[~mask & res['hit_SL']== 1,'lambda_SL']

res.loc[~mask & res['hit_TP']== 1,'Odds'] =0
res.loc[~mask & res['hit_TP']== 1,'P_out'] = res.loc[~mask & res['hit_TP']== 1,'Entry_Price']+res.loc[~mask & res['hit_TP']== 1,'lambda_TP']
res.loc[mask,'P_out'] = res.loc[mask,'Odds']*(res.loc[mask,'Entry_Price']-res.loc[mask,'lambda_SL']) + (1-res.loc[mask,'Odds'])*(res.loc[mask,'Entry_Price']-res.loc[mask,'lambda_SL'])
res['Profit'] = res['P_out'] - res['Entry_Price']

pass


