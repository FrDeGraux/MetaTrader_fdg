import os
def init_config() :
    from configparser import ConfigParser
    # instantiate
    config = ConfigParser()
    # parse existing file
    config.read('config.ini')
    return config
def build_working_hysteresis_path(config) :
    sRunName = config.get('Run', 'sRunNameHysteresis')
    sBasePath = config.get('FilePth', 'sBasePath')
    sBasePath = sBasePath.replace("\\\\", "\\")
    threshold = config.get("FixedHysteresisInput","threshold")

    sBasePath = os.path.join(sBasePath, sRunName)
    sBasePathFreq = os.path.join(sBasePath, config.get('Inputs', 'Frequency'))
    sFixedHysteresisPath =  config.get('FilePth', 'sFixedHysteresisPath')
    sPath = os.path.join(sBasePathFreq,sFixedHysteresisPath,str(100*float(threshold)) + "_Procent")

    if not os.path.exists(sPath):
        os.makedirs(sPath)
    return sPath
