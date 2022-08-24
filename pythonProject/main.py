# This is a sample Python script.
from utilPlot import plot_scatter,plot_time_graph
from utilMapping import from_entry_to_category
from utilReader import read_positions
import matplotlib.pyplot as plt
from os import path
from itertools import combinations
from math import floor

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import pandas as pd
import numpy as np
from datetime import timedelta
from datetime import datetime
symbolList =['EURUSD','GBPUSD','AUDUSD','AUDJPY','EURJPY']
sBaseTickPath = 'C:\\Users\\franc\\Documents\\MetaTrader_tests\\Strategy_1_MM_crossover\\run_20_07'
sFileName = '_2022_07_21 23_07_28.csv'
balance_initial = 10000


#5.•	Graphique Trade durations vs Profit (correlation by symbol?), with marker for the reason (technical or SL/TP)
#•	Number of SL/TP vs full winner (in number and in euro) : full winner
#•	Number of SL lost vs TP win
#•	Return correlations by symbol (with regression line)
# Return 1 is on the H1 dataframe =
#•	Volatility of timeframe returns (H1,D1,etc)#
# Trade Histogram (by biggest to losest trade with dt)
# Plot(time,return)
# Plot(time,nTrades)def print_hi(name):
# knowing the reaons why it was hit (SL,TP,etc)
# Plot(return,régime)    # Use a breakpoint in the code line below to debug your script.
# Plot BySymbol    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.



#1. #Profit TimeSeriees


def plot_profits_all_symbols(in_df_positions,in_timeframe,sSymbolList) :       # plot_balance
    for symbol in sSymbolList :
        in_df_positions_filtered = filterBySymbol(in_df_positions,symbol)
        in_df_positions_filtered = in_df_positions_filtered[['Profit','Swap','Commission']]
        profits = in_df_positions_filtered.resample(in_timeframe).sum()
        profits_cumulated = profits.cumsum()
        profits_cumulated['Total'] = profits_cumulated[list(profits_cumulated.columns)].sum(axis=1)
        plot_time_graph(profits_cumulated.index.tolist(),profits_cumulated['Total'].values,symbol)
        # filter

    # LEGENDE
#2 Profit vs Time
def plot_return_durations(in_df_positions,in_symbol) :

    in_df_positions = filterBySymbol(in_df_positions,in_symbol)

    # plot return vs Trade duration (color is the profit)
    mask = in_df_positions['Entry'] == 'DEAL_ENTRY_OUT'
    df_sell = (in_df_positions[mask])
    df_sell['Reason_number'] = df_sell.apply(lambda row: from_entry_to_category(row), axis=1)
    toplot = []
    for row in df_sell.iterrows() :
        row = row[1]
        val = row['PositionID(missedstringparameter)']
        mask_position = (in_df_positions['PositionID(missedstringparameter)'] == val)
        df = in_df_positions[mask_position]
        df = df[df['Entry'] == 'DEAL_ENTRY_IN']
        if(len(df) > 1) :
            raise Exception('plot_return_durations::more than one purchase')
        entryIn = df['Time'].values[0]
        entryOut = row['Time']
       #  entryIn = datetime.strptime(df['Time'].values[0],'%Y.%m.%d %H:%M:%S ')
    #entryOut = datetime.strptime(row['Time'],'%Y.%m.%d %H:%M:%S ')
        toplot.append((entryOut-entryIn,(row['Profit']),(row['Reason_number'])))
    titles = ('Hours','Euro','Profit vs durations for ' + in_symbol)
    plot_scatter(in_symbol,toplot,titles)
def plot_returns_duration_bySymbol() :
    pass
#3. # of money (TP) vs # of money (SL)
def plot_histogram_SL_TP(in_df_position,symbolList):
    columns = tuple(symbolList)
    rows = ['TP' 'SL' 'Expert']

    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'

    df_tp = in_df_position[mask_tp]
    df_sl = in_df_position[mask_sl]
    df_other = in_df_position[~df_tp & ~df_sl]

    # Get some pastel shades for the colors
    colors = plt.cm.BuPu(np.linspace(0, 0.5, len(rows)))
    fig = plt.figure()
    ax = fig.add_axes([0, 0, 1, 1])
    ax.bar(X + 0.00, data[0], color='b', width=0.25)
    ax.bar(X + 0.25, data[1], color='g', width=0.25)
    ax.bar(X + 0.50, data[2], color='r', width=0.25)
    plt.show()
def get_cmap(n, name='hsv'):
    '''Returns a function that maps each index in 0, 1, ..., n-1 to a distinct
    RGB color; the keyword argument name must be a standard mpl colormap name.'''
    return plt.cm.get_cmap(name, n)
def plot_histogram_SL_TP(in_df_position,symbolList) :
    import numpy as np
    import matplotlib.pyplot as plt

    rows = ['TP' 'SL' 'Expert']

    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'
    mask_expert = (in_df_position['Reason'] == 'DEAL_REASON_EXPERT') & (in_df_position['Entry'] == 'DEAL_ENTRY_OUT')


    df_tp = in_df_position[mask_tp]
    df_sl = in_df_position[mask_sl]
    df_other = in_df_position[mask_expert]

    dataframes = [df_tp,df_sl,df_other]
    dataframes_processed = []

    for df in dataframes :
        df = df['Profit']
        df = df.reset_index(drop='True')
        df = df.sort_values(ascending=True)
        dataframes_processed.append(df)


    barWidth = 1
    edgeWidth = 0.12
    color_maps = ['viridis','inferno','Greys']
    names = ['TP', 'SL', 'Expert']

    for count_X ,df_plt in enumerate(dataframes_processed) :
        cmap = get_cmap(len(df_plt),color_maps[count_X])
        total = df_plt.sum()
        part_list = []
        mini = df_plt.min()
        maxi = df_plt.max()
        for count,row in enumerate(df_plt):
            part = (row-mini)/(maxi-mini)
            part_list.append(part)
            if count == 0 :
                plt.bar(names[count_X],row,linewidth = edgeWidth,color=cmap(200),alpha = part,edgecolor='blue',width=barWidth,align = 'edge')
            else :
                sum = df_plt.iloc[0:count].sum()
                plt.bar(names[count_X],row,linewidth = edgeWidth,bottom= sum,color=cmap(200),alpha = part,edgecolor='blue', width=barWidth,align = 'edge')
    plt.title("SL/TP histogram")
    plt.show()
def filterBySymbol(in_df_position,in_symbol) :
    if in_symbol == 'ALL' :
        return in_df_position
    mask = in_df_position['Symbol'] == in_symbol
    in_df_position = in_df_position[mask]
    return in_df_position
def filterByDateTimePrevious(in_df_position,in_dt) :
    mask = in_df_position['Symbol'] < in_dt
    in_df_position = in_df_position[mask]
    return in_df_position
def getSymbolList(in_df_positions) :
    symbolList = df_positions['Symbol'].unique()
    symbolList = [item.replace(' ', '') for item in symbolList]
    return symbolList
def add_column_balances(in_df_positions) :
    balances = []
    in_df_positions = in_df_positions[['Profit', 'Symbol']]
    for index, row in in_df_positions.iterrows():

        df_positions_by_symbol = filterBySymbol(in_df_positions,row['Symbol'])
        df_positions_by_symbol = filterByDateTimePrevious(df_positions_by_symbol,index)
        balance  = balance_initial - df_positions_by_symbol['Profit'].sum()
        balances.append(balance)

    in_df_positions['balance'] = balances
    return in_df_positions
def plot_return_correlation(in_df_positions,symbol_one,symbol_two,in_count,in_nRowsTotalSubPlot,in_nColsTotalSubPlot) :
    time_min =in_df_positions['Time'].min()
    time_max =in_df_positions['Time'].max()
    profits = in_df_positions.resample('W').sum()
    mask = in_df_positions['Entry'] == 'DEAL_ENTRY_OUT'
    in_df_positions = (in_df_positions[mask])
    df_to_process = [filterBySymbol(in_df_positions,item) for item in [symbol_two,symbol_one]]
    df_processed = []
    for item in df_to_process :

        item = item['Profit'] + item['Commission'] + item['Swap']
        item = pd.DataFrame(item.resample('W').sum())
        item['Balance'] = item.cumsum()
        item['Balance'] = item['Balance'].shift(periods=1)

        item['Balance'] = balance_initial + item['Balance']
        item.iat[0,1] = balance_initial
        item.columns = ['Profit', 'Balance']
        item['Return'] = item['Profit']/item['Balance']
        item = item.drop(['Profit', 'Balance'], axis=1)
        df_processed.append(item)

    res = pd.concat(df_processed,axis=1)
    res = res.dropna()
    res.columns = ['Return_' + symbol_one, 'Return_' + symbol_two]
    plt.subplot(in_nRowsTotalSubPlot, in_nColsTotalSubPlot, in_count)
    plt.scatter(res.iloc[:,0], res.iloc[:,1],s =5, label=('correlations' + symbol_one + '_' + symbol_two))


    plt.xlabel(symbol_one,fontsize = 8)
    plt.ylabel(symbol_two,fontsize =8)
    m, b = np.polyfit(res.iloc[:,0], res.iloc[:,1], 1)

    plt.plot(res.iloc[:,0], m * (res.iloc[:,0]) + b)
    plt.title(( symbol_one + '_' + symbol_two + '(' + str(round(m,4)) + ')'),fontsize=8)

    plt.subplots_adjust(wspace = 0.8,hspace = 1)



if __name__ == '__main__':


    df_positions = read_positions(path.join(sBaseTickPath,sFileName))

    symbolList= getSymbolList(df_positions)
    symbolList.append('ALL')

    list_combinations = list(combinations(symbolList, 2))
    in_nRowsTotalSubPlot = floor((len(list_combinations)/4))+1
    in_nColsTotalSubPlot = 0
    if len(list_combinations) < 4 :
        in_nColsTotalSubPlot = len(list_combinations)
    else :
        in_nColsTotalSubPlot = 4

    for count,item in enumerate(list_combinations):
        plot_return_correlation(df_positions,item[0], item[1],count+1,in_nRowsTotalSubPlot,in_nColsTotalSubPlot)
    plt.suptitle('Returns correlations (Weekly) ',fontsize=10)
    plt.show()
    df_positions['PositionID(missedstringparameter)']  = (df_positions['PositionID(missedstringparameter)']).astype(str) + df_positions['Symbol']

    plot_histogram_SL_TP(df_positions,symbolList)




    plt.figure(1)
    plot_profits_all_symbols(df_positions,'60min',symbolList)
    plt.legend(loc="upper left")
    plt.show()

    # 2. Duration vs Profit
    plt.figure(2)
    [plot_return_durations(df_positions,symbol) for symbol in symbolList]

    # 3. # of money (TP) vs # of money (SL)
    pass

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
