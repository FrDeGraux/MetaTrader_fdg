import pandas as pd
from utilReader import read_positions
from utilData import from_in_to_out_mapping,unpackComment_MM,getSymbolList
from utilConfig import init_config

from utilCalibrationFixedHysteresis import build_all_hyper_cubes,scatter_data
sFilePath = '_2022_08_31 20_39_13.csv'

config = init_config()
sBasePath = config.get('FilePth', 'sBasePath')




df_positions = unpackComment_MM(read_positions(sFilePath))
df_positions = from_in_to_out_mapping((df_positions[(df_positions['Slow_MM'] != "EOT")]),config)


symbolList = getSymbolList(df_positions)
df_positions['TimeIn'] = df_positions['TimeIn'].dt.date
df_positions['TimeOut'] = df_positions['TimeOut'].dt.date

[build_all_hyper_cubes(df_positions,item,0.6,config) for item in symbolList]

pass

