import matplotlib.pyplot as plt
from os import path

class MultiTFReporter :
    def __init__(self,in_list_reporter,in_sRunName,in_config_common):
        self.config_common =in_config_common
        self.frequencies = {'H1': self.in_config_common.get('AllInputs', 'Frequencies_1'),
                            'H4': self.in_config_common.get('AllInputs', 'Frequencies_2'),
                            'D1': self.in_config_common.get('AllInputs', 'Frequencies_3'),
                            'W1': self.in_config_common.get('AllInputs', 'Frequencies_4')}
        self.Frequencies = [value for key, value in self.frequencies.items()]
        self.sBasePath = self.in_config_common.get('FilePth','sBasePath')
        self.sFileNames = [item.sFileName for item in in_list_reporter]
        self.lst_reporters = in_list_reporter
        self.name = in_sRunName
    def plot_profits_all_timeframes_with_save(self):
        self.plot_profits_all_timeframes_no_save()
        plt.title(self.config_common.get('Returns', 'Graph_Title') + "_" + "_MANY RUNS " + " TIMEFRAMES")
        plt.legend(loc="best")
        plt.show()
        plt.savefig(path.join(self.sBasePath, 'All_returns' + '.png'))
    def plot_profits_all_timeframes_no_save(self): # for one run

        [item.plot_profit_timeframe() for item in self.lst_reporters]
