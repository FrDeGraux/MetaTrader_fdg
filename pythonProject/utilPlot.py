
import matplotlib.pyplot as plt
import numpy as np
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

