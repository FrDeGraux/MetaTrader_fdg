from reporter import Reporter
from utils.utilConfig import init_config
if __name__ == '__main__':
    config = init_config('Configs/config_run_1.1_H4.ini')
    config_common = init_config('Configs/config_common_reporting.ini')
    config_subrun = init_config('Configs/config_run_1_1.ini')
    objReporter = Reporter(config,config_subrun,config_common)
    objReporter.run()


