
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from utilConfig import build_working_hysteresis_path
from os import path
from defined_enums import OptionPlotHysteresis
def plot_ultimate_returns():
    pass
def plot_histo_fixed_hysteresis(in_item_list,in_cfg,in_plot_enum) :
        sFrequency =  in_cfg.get('Inputs', 'Frequency')
        sFileName = in_cfg.get('FilePth', 'sFixedCalibrationFileName')
        threshold = str(100*float(in_cfg.get('FixedHysteresisInput', 'threshold')))
        sFileName = sFileName + '_' + threshold
        if in_plot_enum == OptionPlotHysteresis.CUMULATIVE :
            sFileName = sFrequency + '_cumulative' + sFileName + '.png'
            sTitle = sFrequency + "_cumulative_Fixed_spread"
        else :
            if in_plot_enum == OptionPlotHysteresis.STANDARD:
                sFileName = sFrequency + '_' + sFileName + '.png'
                sTitle = sFrequency + "_Fixed_spread"
            else :
                if in_plot_enum == OptionPlotHysteresis.COMPARATIVE :
                    sFileName = sFrequency + '_' + sFileName + '.png'
                    sTitle = sFrequency + "_Comparisons_Fixed_spread"
                else :
                    raise Exception




        sFileName = path.join(build_working_hysteresis_path(in_cfg),sFileName)


        df = pd.DataFrame(in_item_list, columns=['Symbol', 'Year', 'Fixed_spread'])


        if in_plot_enum != OptionPlotHysteresis.COMPARATIVE :
            sFileNameCSV = in_cfg.get('FilePth', 'sFixedCalibrationFileName')

            sFileNameCSV = path.join(build_working_hysteresis_path(in_cfg), sFileNameCSV)

            if in_plot_enum == OptionPlotHysteresis.CUMULATIVE :
                sFileNameCSV = sFileNameCSV + str(100*float(threshold)) + "_Procent" + "_" + sFrequency + '_cumulative'  + '.csv'
            else :
                if in_plot_enum == OptionPlotHysteresis.STANDARD :
                    sFileNameCSV = sFileNameCSV  + str(100*float(threshold)) + "_Procent" +  "_" + sFrequency + '.csv'
            df.to_csv(sFileNameCSV, sep=';', index=False)




        df = df.pivot("Symbol", "Year", "Fixed_spread")
        df.plot(kind='bar')

        plt.title(sTitle)

        plt.savefig(sFileName)
        pass
def plot_time_graph(in_dt,in_values,in_legendValue) :
    plt.plot(in_dt,in_values,label = in_legendValue)
    pass
def plot_scatter_durations(insName,toplot,in_titles,in_color,in_config) :

    toplot = list(zip(*toplot))
    x = [item.total_seconds() / 3600 for item in toplot[0]]
    y = toplot[1]
    colormap = np.array(['b','g', 'r'])
    reasonMap = ['Normal','Stop Loss','Take Profit']

    plt.scatter(x,y, c=in_color,s= int(in_config.get('Correlations', 'Correlations_Marker_Size')))
    plt.title(in_titles[2],fontsize = 8)
    plt.xlabel(in_titles[0])
    plt.ylabel(in_titles[1])
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

