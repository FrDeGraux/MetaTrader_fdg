import pandas as pd
from utilReader import read_positions
from utilPlot import plot_histo_fixed_hysteresis
from utilData import from_in_to_out_mapping,unpackComment_MM,getSymbolList
from utilConfig import init_config
from defined_enums import OptionPlotHysteresis
from os import path
from utilCalibrationFixedHysteresis import build_all_hyper_cubes,scatter_data,tot_hours,build_all_hyper_cubes_cumulated
import warnings
warnings.filterwarnings("ignore")

config = init_config()
sBasePath = config.get('FilePth', 'sBasePath')
sFrequency = config.get('Inputs', 'Frequency')
dict_FilePath = {'H1' : config.get('Inputs', 'sFileName_H1'),'H4' : config.get('Inputs', 'sFileName_H4'),'D1' : config.get('Inputs', 'sFileName_D1'),'W1' : config.get('Inputs', 'sFileName_W1')}
sRunName =  config.get('Run', 'sRunName')
threshold = config.get('FixedHysteresisInput','threshold')
sFilePath = path.join(sBasePath,sRunName,sFrequency,dict_FilePath[sFrequency])


df_positions = unpackComment_MM(read_positions(sFilePath))
df_positions = from_in_to_out_mapping((df_positions[(df_positions['Slow_MM'] != "EOT")]),config)


symbolList = getSymbolList(df_positions)

df_positions['duration']  =  df_positions['TimeOut']-df_positions['TimeIn']
df_positions['duration'] = df_positions.apply(lambda row: tot_hours(row['duration']), axis=1)


res = [build_all_hyper_cubes(df_positions,item,threshold,config) for item in symbolList]
res_cumulated = [build_all_hyper_cubes_cumulated(df_positions,item,threshold,config) for item in symbolList]

res = [item for sublist in res for item in sublist]
res_cumulated = [item for sublist in res_cumulated for item in sublist]

res_compared = [(x,y,z1-z2) for ((x,y,z1),(t,s,z2)) in zip(res,res_cumulated)]
plot_histo_fixed_hysteresis(res,config,OptionPlotHysteresis.STANDARD)
plot_histo_fixed_hysteresis(res_cumulated,config,OptionPlotHysteresis.COMPARATIVE)
plot_histo_fixed_hysteresis(res_compared,config,OptionPlotHysteresis.CUMULATIVE)


pass

