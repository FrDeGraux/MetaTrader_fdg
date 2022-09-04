def init_config() :
    from configparser import ConfigParser
    # instantiate
    config = ConfigParser()
    # parse existing file
    config.read('config.ini')
    return config