import pandas as pd
from utilReader import read_positions
from utilPlot import plot_histo_fixed_hysteresis
from utilData import from_in_to_out_mapping,unpackComment_MM,getSymbolList
from utilConfig import init_config
from os import path
from utilCalibrationFixedHysteresis import build_all_hyper_cubes,scatter_data,tot_hours,build_all_hyper_cubes_cumulated
import warnings
warnings.filterwarnings("ignore")

config = init_config()
sBasePath = config.get('FilePth', 'sBasePath')
sFrequency = config.get('Inputs', 'Frequency')
sFilePath = config.get('Inputs', 'sFileName')
sRunName =  config.get('Run', 'sRunName')
threshold = config.get('FixedHysteresisInput','threshold')
sFilePath = path.join(sBasePath,sRunName,sFrequency,sFilePath)



df_positions = unpackComment_MM(read_positions(sFilePath))
df_positions = from_in_to_out_mapping((df_positions[(df_positions['Slow_MM'] != "EOT")]),config)


symbolList = getSymbolList(df_positions)

df_positions['duration']  =  df_positions['TimeOut']-df_positions['TimeIn']
df_positions['duration'] = df_positions.apply(lambda row: tot_hours(row['duration']), axis=1)


res = [build_all_hyper_cubes(df_positions,item,threshold,config) for item in symbolList]
res_cumulated = [build_all_hyper_cubes_cumulated(df_positions,item,0.6,config) for item in symbolList]

res = [item for sublist in res for item in sublist]
res_cumulated = [item for sublist in res_cumulated for item in sublist]
plot_histo_fixed_hysteresis(res,config,isCumulative=False)
plot_histo_fixed_hysteresis(res_cumulated,config,isCumulative = True)
pass

