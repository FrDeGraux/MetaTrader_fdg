from os import path
def init_config() :
    from configparser import ConfigParser
    # instantiate
    config = ConfigParser()
    # parse existing file
    config.read('config.ini')
    return config
def build_working_path(config) :
    sRunName = config.get('Run', 'sRunName')
    sBasePath = config.get('FilePth', 'sBasePath')
    sBasePath = sBasePath.replace("\\\\", "\\")

    sBasePath = path.join(sBasePath, sRunName)
    sBasePathFreq = path.join(sBasePath, config.get('Inputs', 'Frequency'))
    sFixedHysteresisPath =  config.get('FilePth', 'sFixedHysteresisPath')
    sPath = path.join(sBasePathFreq,sFixedHysteresisPath)
    return sPath
