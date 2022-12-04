from utils.utilReader import read_positions
import matplotlib.pyplot as plt
from os import path

from utils.utilData import remove_none_points,get_gross_position,get_point_digit,get_in_or_out_sign,filterBySymbol, filterOnInDeals,filterOnInDeals_AndLastOut,getSymbolList, get_net_position,unpackComment_MM,from_frequency_to_resample_period,create_directory_if_not_exists
from utils.utilPlot import plot_scatter_durations
from itertools import combinations
from math import floor

from utils.utilMapping import from_entry_to_category

import pandas as pd
import numpy as np
from matplotlib import cm


class Reporter:
  def __init__(self,in_config_specific,in_config_subrun,in_config_common):
      self.config = in_config_specific
      self.configcommon = in_config_common
      self.configsubrun = in_config_subrun


      self.sRunName = self.configsubrun.get('Run', 'sRunName')
      self.sSubRunName =  self.configsubrun.get('Run', 'sSubRunName')
      self.freq = self.config.get('Inputs','Frequency')
      self.sMotherPath = self.configcommon.get('FilePth', 'sBasePath')
      self.sMotherPath = self.sMotherPath.replace("\\\\", "\\")

      self.sBasePath = path.join(self.sMotherPath, self.sRunName)
      self.sBasePath = path.join(self.sBasePath,self.sSubRunName)
      self.sBasePathFreq = path.join(self.sBasePath, self.config.get('Inputs', 'Frequency'))

      self.sReportsPath = path.join(self.sBasePathFreq, self.configcommon.get('FilePth', 'sReportsPath'))
      self.sDurationReturnPath = path.join(self.sReportsPath, self.configcommon.get('FilePth', 'sDurationPath'))
      create_directory_if_not_exists(self.sDurationReturnPath)

      self.sFileName =  self.config.get('Inputs', 'sFileName')

      self.balance_initial = 10000
      self.style = self.configsubrun.get('Styles','Style')
      self.df_positions =  read_positions(path.join(self.sBasePathFreq, self.sFileName))
      self.df_positions = self.df_positions.head(1000)
      self.df_positions[self.configcommon.get('Names', 'PositionMissedParameters')] = (self.df_positions[self.configcommon.get('Names', 'PositionMissedParameters')]).astype(str)
      self.symbolList= getSymbolList(self.df_positions,self.configcommon)
      self.symbolListNoALL = self.symbolList[:-1]
      self.previous_row_average_entry_price = None



  def plot_profit_timeframe(self):

      sFilePath = self.sFileName
      sFilePath = path.join(self.sBasePath, sFilePath)
      df_positions = read_positions(sFilePath)
      in_timeframe = from_frequency_to_resample_period(self.freq)

      df_positions_filtered = df_positions[['Profit', 'SwapReal', 'Commission']]
      profits = df_positions_filtered.resample(in_timeframe).sum()
      profits_cumulated = profits.cumsum()
      profits_cumulated['Total'] = profits_cumulated[list(profits_cumulated.columns)].sum(axis=1)

      plt.plot(profits_cumulated.index.tolist(), profits_cumulated['Total'].values,label=(self.freq + '_' + self.sRunName), linestyle=self.style)
  def plot_profit_by_symbol(self,in_df,in_symbol,in_timeFrame,in_color) :
        pass
        plt.plot(in_df.index.tolist(), in_df['Equity'].values, label=in_symbol,color=in_color)

        plt.title(self.config.get('Inputs', 'Frequency') + '_' + self.configsubrun.get('Run','sRunName') + '_' + self.configcommon.get('Returns', 'Graph_Title') + in_timeFrame + "_" + in_symbol)
        plt.legend(loc="best")
        plt.show()

  def plot_profits_all_symbols(self):  # plot_balance
      in_timeframe = from_frequency_to_resample_period(self.freq)
      turbo = cm.get_cmap('turbo', len(self.symbolList))
      df_all_equity = None
      for idx, symbol in enumerate(self.symbolListNoALL):
          df_equity_symbol = self.compute_equity(symbol)
          self.plot_profit_by_symbol(df_equity_symbol,symbol,in_timeframe,turbo.colors[idx])

          if df_all_equity :
              df_equity_symbol = df_equity_symbol.reindex(df_all_equity.index.union(df_equity_symbol.index), method='bfill')

              df_all_equity = df_all_equity.reindex(df_equity_symbol.index)
              df_all_equity = df_all_equity + df_equity_symbol
          else :
              df_all_equity = df_equity_symbol
          pass

      self.plot_profit_by_symbol(df_all_equity,'ALL',in_timeframe,turbo.colors[len(self.symbolList)-1])

      plt.savefig(path.join(self.sReportsPath, self.sRunName + '_Profits' + symbol) + '.png')


  def get_avg_entry_price(self,in_ID,price,in_symbol,in_previous_positioning,in_type,in_entry,in_quantity = 1):

      if in_entry == 'DEAL_ENTRY_OUT' :
        mask = (self.df_positions['PositionID()'] == in_ID) & (self.df_positions['Symbol'] == in_symbol) & (self.df_positions['Entry'] == 'DEAL_ENTRY_IN')
        entry_row = self.df_positions[mask]
        price = entry_row['Price']

      if self.previous_row_average_entry_price is None : # first buy/sell
            average_entry_price = price
      else :
          new_positioning = in_previous_positioning + get_in_or_out_sign(in_entry) * abs(in_quantity)

          if new_positioning == 0 : # portfolio is sold out, avg price = 0
            average_entry_price = 0
          else :
            average_entry_price =  ((1/new_positioning)*(in_previous_positioning*(self.previous_row_average_entry_price) + get_in_or_out_sign(in_entry)*price))
      if in_entry == 'DEAL_ENTRY_IN' :
        self.previous_row_average_entry_price = average_entry_price
      return average_entry_price

  def compute_equity(self,in_symbol) :

      positions =  self.df_positions[['Symbol','Type','Entry','Price','Commission','Swap_corrected','Profit','PositionID()','Point']]
      positions.columns = ['Symbol','Type','Entry','Price','Commission','Swap_corrected','Balance','PositionID','Point_value']
      positions = filterBySymbol(positions, in_symbol,self.configcommon)

      positions['positioning_net'] = positions.apply(lambda x: get_net_position(x.Type,x.Entry),axis=1)
      positions['positioning_gross'] = positions.apply(lambda x: get_gross_position(x.Entry),axis=1)

      positions['positioning_net']  = positions['positioning_net'].cumsum()
      positions['positioning_gross']  = positions['positioning_gross'].cumsum()

      positions['positioning_gross_shifted'] = positions['positioning_gross'].shift(1)

      positions['avgEntryPrice'] = positions.apply(lambda x: self.get_avg_entry_price(x.PositionID,x.Price,x.Symbol,x.positioning_gross_shifted,x.Type,x.Entry,1), axis=1)

      positions_cumulative = positions[['Commission','Swap_corrected','Balance']].cumsum()
      positions_cumulative['Final_balance'] = positions_cumulative[['Commission','Swap_corrected','Balance']].sum(axis=1)
      positions_cumulative[['Symbol','avgEntryPrice','Entry','positioning_net','Point_value','positioning_gross']] = positions[['Symbol','avgEntryPrice','Entry','positioning_net','Point_value','positioning_gross']]
      positions_cumulative = filterOnInDeals(positions_cumulative)
      prices_list = pd.read_csv(path.join(self.configcommon.get('FilePth', 'sBaseDevelopmentPath'),'Data',in_symbol,in_symbol + '_' + self.freq + '.csv'),delim_whitespace=True)
      prices_list = prices_list[['<DATE>','<TIME>','<OPEN>']]
      prices_list['<DateTime>'] = prices_list['<DATE>'] + ' ' + prices_list['<TIME>']
      prices_list = prices_list.drop(columns = ['<DATE>','<TIME>'])
      prices_list = prices_list.set_index('<DateTime>')
      positions_cumulative = positions_cumulative.reindex(prices_list.index, method='ffill')
      positions_cumulative = positions_cumulative.dropna(how='all')
      positions_cumulative = positions_cumulative.dropna(subset=['Point_value'])
      positions_cumulative['Price'] = prices_list['<OPEN>']

      positions_cumulative['PL_Points'] =get_point_digit( positions_cumulative['Symbol'])*(positions_cumulative['Price'] - positions_cumulative['avgEntryPrice'])
      positions_cumulative['Point_value'] = pd.to_numeric(positions_cumulative['Point_value'].str.strip())
      positions_cumulative['PL_Points_Euro'] = positions_cumulative['PL_Points']*positions_cumulative['Point_value']
      positions_cumulative['PL_final']  = 100000*0.01*positions_cumulative['positioning_net']*positions_cumulative['PL_Points_Euro']
      positions_cumulative['Equity'] = positions_cumulative['PL_final'] + positions_cumulative['Final_balance']
      positions_cumulative = positions_cumulative.drop(columns=['PL_Points','PL_Points_Euro', 'Point_value','Symbol','Price','avgEntryPrice'])    #2
      return positions_cumulative
  def plot_return_durations_all_symbols(self):
      [self.plot_return_durations(symbol) for symbol in self.symbolList]
  def plot_return_durations(self, in_symbol):

      df_positions = filterBySymbol(self.df_positions, in_symbol,self.configcommon)

      # plot return vs Trade duration (color is the profit)
      mask = df_positions['Entry'] == self.configcommon.get('Names', 'Entry_Out')
      df_sell = (df_positions[mask])
      df_sell['Reason_number'] = df_sell.apply(lambda row: from_entry_to_category(row), axis=1)
      toplot = []
      for row in df_sell.iterrows():
          row = row[1]
          val = row[self.configcommon.get('Names', 'PositionMissedParameters')]
          mask_position = (df_positions[self.configcommon.get('Names', 'PositionMissedParameters')] == val)
          df = df_positions[mask_position]
          df = df[df['Entry'] == self.configcommon.get('Names', 'Entry_In')]
          if (len(df) > 1):
              raise Exception('plot_return_durations::more than one purchase')
          entryIn = df['Time'].values[0]
          entryOut = row['Time']
          #  entryIn = datetime.strptime(df['Time'].values[0],'%Y.%m.%d %H:%M:%S ')
          # entryOut = datetime.strptime(row['Time'],'%Y.%m.%d %H:%M:%S ')
          toplot.append((entryOut - entryIn, (row['Profit']), (row['Reason_number'])))
          titles = ('Hours', 'Euro', self.sRunName + "( " + self.freq + " ) " + 'Profit vs durations  ' + in_symbol)
      toplot = sorted(toplot, key=lambda x: x[0], reverse=True)
      plot_scatter_durations(in_symbol, toplot, titles, 'b', self.configcommon)

      plt.savefig(path.join(self.sDurationReturnPath,self.sRunName + '_durations_vs_returns_' + "_" + self.freq + "_" + in_symbol + '.png'))


  # 3. # of money (TP) vs # of money (SL)

  def get_cmap(self,n, name='hsv'):
      '''Returns a function that maps each index in 0, 1, ..., n-1 to a distinct
      RGB color; the keyword argument name must be a standard mpl colormap name.'''
      return plt.cm.get_cmap(name, n)

  def plot_histogram_SL_TP(self):



      rows = ['TP' 'SL' 'Expert']

      mask_tp = self.df_positions['Reason'] == self.configcommon.get('Names', 'Entry_TP')
      mask_sl = self.df_positions['Reason'] == self.configcommon.get('Names', 'Entry_SL')
      mask_expert = (self.df_positions['Reason'] == self.configcommon.get('Names', 'Entry_Expert')) & (
                  self.df_positions['Entry'] == self.configcommon.get('Names', 'Entry_Out'))

      df_tp = self.df_positions[mask_tp]
      df_sl = self.df_positions[mask_sl]
      df_other = self.df_positions[mask_expert]

      dataframes = [df_tp, df_sl, df_other]
      dataframes_processed = []

      for df in dataframes:
          df = df['Profit']
          df = df.reset_index(drop='True')
          df = df.sort_values(ascending=True)
          dataframes_processed.append(df)

      barWidth = 1
      edgeWidth = 0.12
      color_maps = [self.configcommon.get('SL_TP_Histogram', 'Color_TP'), self.configcommon.get('SL_TP_Histogram', 'Color_SL'),
                    self.configcommon.get('SL_TP_Histogram', 'Color_Expert')]
      names = ['TP', 'SL', 'Expert']

      for count_X, df_plt in enumerate(dataframes_processed):
          cmap = self.get_cmap(len(df_plt), color_maps[count_X])
          total = df_plt.sum()
          part_list = []
          mini = df_plt.min()
          maxi = df_plt.max()
          for count, row in enumerate(df_plt):
              part = (row - mini) / (maxi - mini)
              part_list.append(part)
              if count == 0:
                  plt.bar(names[count_X], row, linewidth=edgeWidth, color=cmap(200), alpha=part, edgecolor='blue',
                          width=barWidth, align='edge')
              else:
                  sum = df_plt.iloc[0:count].sum()
                  plt.bar(names[count_X], row, linewidth=edgeWidth, bottom=sum, color=cmap(200), alpha=part,
                          edgecolor='blue', width=barWidth, align='edge')
      plt.title(self.configcommon.get('SL_TP_Histogram', 'Title_SL_TP_Histo'))
      plt.savefig(path.join(self.sReportsPath, self.sRunName + '_SL_TP_Histogram.png'))

  def filterByDateTimePrevious(self,in_df_position, in_dt):
      mask = in_df_position['Symbol'] < in_dt
      in_df_position = in_df_position[mask]
      return in_df_position

  def plot_return_correlation_ByPair(self,in_nRowsTotalSubPlot,in_nColsTotalSubPlot,in_plot_count,symbol_one, symbol_two):

      df_positions =  read_positions(path.join(self.sBasePathFreq, self.sFileName))

      mask = df_positions['Entry'] ==  self.configcommon.get('Names', 'Entry_Out')
      in_df_positions = (df_positions[mask])
      df_to_process = [filterBySymbol(in_df_positions, item, self.configcommon) for item in [symbol_two, symbol_one]]
      df_processed = []
      for item in df_to_process:
          try:
              item = item['Profit'] + item['Commission'] + item['Swap_corrected']
          except:
              pass
          item = pd.DataFrame(item.resample('W').sum())
          item['Balance'] = item.cumsum()
          item['Balance'] = item['Balance'].shift(periods=1)

          item['Balance'] = self.balance_initial + item['Balance']
          item.iat[0, 1] = self.balance_initial
          item.columns = ['Profit', 'Balance']
          item['Return'] = item['Profit'] / item['Balance']
          item = item.drop(['Profit', 'Balance'], axis=1)
          df_processed.append(item)

      res = pd.concat(df_processed, axis=1)
      res = res.dropna()
      res.columns = ['Return_' + symbol_one, 'Return_' + symbol_two]
      ax1 = plt.subplot(in_nRowsTotalSubPlot, in_nColsTotalSubPlot, in_plot_count)
      plt.scatter(res.iloc[:, 0], res.iloc[:, 1], s=int(self.configcommon.get('Correlations', 'Correlations_Marker_Size')),
                  label=('correlations' + symbol_one + '_' + symbol_two))

      ax1.set_xlim([-0.05, 0.05])
      if ((symbol_one == ('ALL') or symbol_two == 'ALL')):
          ax1.set_xlim([float(self.configcommon.get('Correlations', 'Correlations_xlim_all_min')),
                        float(self.configcommon.get('Correlations', 'Correlations_xlim_all_max'))])
      else:
          ax1.set_xlim([float(self.configcommon.get('Correlations', 'Correlations_xlim_symbol_min')),
                        float(self.configcommon.get('Correlations', 'Correlations_xlim_symbol_max'))])

      # plt.xlabel(symbol_one,fontsize =  config.get('Correlations', 'Correlations_Font_Size'))
      # plt.ylabel(symbol_two,fontsize = config.get('Correlations', 'Correlations_Font_Size'))
      m, b = np.polyfit(res.iloc[:, 0], res.iloc[:, 1], 1)

      plt.plot(res.iloc[:, 0], m * (res.iloc[:, 0]) + b)
      plt.title((symbol_one + '_' + symbol_two + '(' + str(round(m, 4)) + ')'),
                fontsize=self.configcommon.get('Correlations', 'Correlations_Font_Size'))

      plt.subplots_adjust(wspace=float(self.configcommon.get('Correlations', 'Correlations_wspace')),
                          hspace=float(self.configcommon.get('Correlations', 'Correlations_hspace')))

  def plot_return_correlation_All(self):
      df_positions =  read_positions(path.join(self.sBasePathFreq, self.sFileName))

      list_combinations = list(combinations(self.symbolList, 2))
      in_nColsTotalSubPlot = self.configcommon.get('Correlations','Correlations_NColumns')
      in_nRowsTotalSubPlot = floor(
          (len(list_combinations) / int(self.configcommon.get('Correlations', 'Correlations_NColumns')))) + 1
      in_nColsTotalSubPlot = 0
      if len(list_combinations) < int(self.configcommon.get('Correlations', 'Correlations_NColumns')):
          in_nColsTotalSubPlot = len(list_combinations)
      else:
          in_nColsTotalSubPlot = int(self.configcommon.get('Correlations', 'Correlations_NColumns'))
      for count, item in enumerate(list_combinations):
          self.plot_return_correlation_ByPair(in_nRowsTotalSubPlot, in_nColsTotalSubPlot,count + 1, item[0], item[1])

      plt.suptitle(
          self.configcommon.get('Correlations', 'SupTilteName') + " (" + self.configsubrun.get('Run', 'sRunName') + ":" + self.configsubrun.get('Run', 'sSubRunName') + ")" +  " (" + self.freq + ")", fontsize=int(self.configcommon.get('Correlations', 'Correlations_SupTitleSize')))
      plt.show()
      plt.savefig(path.join(self.sReportsPath, self.config.get('Inputs', 'Frequency') + '_' + self.sRunName + '_Correlations.png'))
  def run(self):

     #self.plot_return_correlation_All()
     #plt.figure(1)
     # self.plot_histogram_SL_TP()
     # self.plot_return_durations_all_symbols()
      #plt.figure(2)
    self.plot_profits_all_symbols()
