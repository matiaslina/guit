#-------------- Imports -----------#

import ConfigParser
import os

PATH = os.path.abspath('.')
CONF_FILE = '.conf'

def config_exist():
	# Check if the conf file exists
	return os.path.isfile(PATH + "/" + CONF_FILE)
		
def create_new_config():
	if not config_exist():
		config = ConfigParser.RawConfigParser()
		
		# Section for the repo. 
		config.add_section('Repo')
		config.set('Repo','path','')
		config.set('Repo','name','')
		config.set('Repo','last_commit','Never')
		
		# Section for the static files.
		config.add_section('StaticFiles')
		config.set('StaticFiles','readme','README')
		config.set('StaticFiles','licence','LICENCE')
		config.set('StaticFiles','todo','TODO')
		
		# Write in config file
		with open(PATH + "/" + CONF_FILE, 'wb') as config_file:
			config.write(config_file)
			print "Configuration file created at {path}".format(path=PATH)
	else:
		print "Config already exists"
		
def get_configuration( option, param ):
	
	# Inicialization
	my_conf = ''
	
	config = ConfigParser.ConfigParser()
	config.read(CONF_FILE)
	
	try:
		my_conf = config.get(option , param)
	except ConfigParser.NoOptionError:
		print "No option {0} in seccion: {1}".format(option,param)
	finally:
		return my_conf
		
def set_configuration( option, param, data):
	config = ConfigParser.SafeConfigParser()
	config.set( option, param, data)
	
def get_existing_static_files():
	config = ConfigParser.ConfigParser()
	config.read(CONF_FILE)
	
	return [myFile[1] for myFile in config.items('StaticFiles')]
		
create_new_config()		
