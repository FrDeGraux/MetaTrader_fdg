
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from utilConfig import build_working_hysteresis_path
from os import path
def plot_histo_fixed_hysteresis(in_item_list,in_cfg,isCumulative) :
        sFrequency =  in_cfg.get('Inputs', 'Frequency')
        sFileName = in_cfg.get('FilePth', 'sFileNameFixedHysteresisSummary')
        if isCumulative :
            sFileName = sFrequency + '_cumulative' + sFileName + '.png'
        else :
            sFileName = sFrequency + '_' + sFileName + '.png'
        sFileName = path.join(build_working_hysteresis_path(in_cfg),sFileName)



        sFileNameCSV = in_cfg.get('FilePth', 'sFileNameFixedHysteresisMQLInput')


        if isCumulative :
            sTitle = sFrequency + "_cumulative_Fixed_spread"
            sFileNameCSV = sFrequency + '_cumulative' + sFileNameCSV + '.csv'
        else :
            sTitle = sFrequency + "_Fixed_spread"
            sFileNameCSV = sFrequency + '_' + sFileNameCSV + '.csv'


        sFileNameCSV = path.join(build_working_hysteresis_path(in_cfg),sFileNameCSV)

        df = pd.DataFrame(in_item_list, columns=['Symbol', 'Year', 'Fixed_spread'])
        df.to_csv(sFileNameCSV,sep=';',index = False)

        df = df.pivot("Symbol", "Year", "Fixed_spread")
        df.plot(kind='bar')

        plt.title(sTitle)

        plt.savefig(sFileName)
        pass
def plot_time_graph(in_dt,in_values,in_legendValue) :
    plt.plot(in_dt,in_values,label = in_legendValue)
    pass

def plot_scatter(insName,toplot,in_titles,in_config) :

    toplot = list(zip(*toplot))
    x = [item.total_seconds() / 3600 for item in toplot[0]]
    y = toplot[1]
    colormap = np.array(['b','g', 'r'])
    reasonMap = ['Normal','Stop Loss','Take Profit']
    plt.scatter(x,y, c=colormap[list(toplot[2])],label = reasonMap,s= int(in_config.get('Correlations', 'Correlations_Marker_Size')))
    plt.title(in_titles[2])
    plt.xlabel(in_titles[0])
    plt.ylabel(in_titles[1])




    pass

