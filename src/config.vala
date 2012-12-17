namespace Configuration
{
	errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	// Constants
	public const string CONFIGURATION_FILE_PATH = "./config.ini";

	// One and only one instance of the config
	public static Configuration Config;
	
	// Init for above
	public static Configuration load_config()
	{
		if (Config == null) 
		{
			try 
			{
				Config = new Configuration(CONFIGURATION_FILE_PATH);
			}
			catch ( InvalidConfigError e)
			{
				stdout.printf("%s\n",e.message);
				Config = null;
			}
		}
		
		return Config;
	}
	
	
	public class Configuration 
	{
		
		// Inicialization.
		private KeyFile config_file;
		public string[,] repo_paths{ public get; private set; }
		
		public Configuration (string where) throws InvalidConfigError
		{
			// Inicialization
			config_file = new KeyFile();
			
			
			// Some configuration over the file
			config_file.set_list_separator(',');
			
			try 
			{
				// Load the config file.
				config_file.load_from_file(where, KeyFileFlags.NONE);
				
				// matrix of [n,2] where the first value are the names
				// of the repos and the second one the are the paths
				repo_paths = new string[config_file.get_groups().length,2];
				
				for(int i = 0; i < config_file.get_groups().length; i++)
				{
					repo_paths[i,0] = config_file.get_string(config_file.get_groups()[i],"name");
					repo_paths[i,1] = config_file.get_string(config_file.get_groups()[i],"path");
					
					stdout.printf("name: %s\npath: %s\n",repo_paths[i,0],repo_paths[i,1]);
				}
				
				
			} catch (Error e) 
			{
				throw new InvalidConfigError.INVALID_CONFIG( e.message );
			}
		
		
		}
		
		
		public bool remove_repository(ref string name) throws InvalidConfigError
		{
			try
			{
				
				// Remove the group from the file
				config_file.remove_group(name);
				
				
			}
			catch (Error e)
			{
				return false;
			}
			
			return true;
		}
		
		public bool save_config()
		{
			// New data to write into the config file.
			string keyfile_str = config_file.to_data ();
			try
			{
				FileUtils.set_contents(CONFIGURATION_FILE_PATH, keyfile_str);
			}
			catch (Error e)
			{
				stderr.printf("Error:%s\n",e.message);
				return false;
			}
			return true;
		}
			
	} // End configuration class
	

}
