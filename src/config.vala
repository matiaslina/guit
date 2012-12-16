namespace Configuration
{
	errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	// Constants
	public const string CONFIGURATION_FILE_PATH = "./config.ini";
	public const string[] GROUPS = {"repos"};

	// One and only one instance of the config
	public static Configuration Config;
	
	// Init for above
	public static Configuration getConfig()
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
		private string[] repo_keys;
		
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
				
				// Set the repo paths.
				repo_keys = config_file.get_string_list("repos","keys");
				
				repo_paths = new string[repo_keys.length,2];
				int n = 0;
				while(n < repo_keys.length)
				{
					repo_paths[n,0] = config_file.get_string(repo_keys[n],"name");
					repo_paths[n,1] = config_file.get_string(repo_keys[n],"path");
					n++;
				}
				
				
			} catch (Error e) 
			{
				throw new InvalidConfigError.INVALID_CONFIG( e.message );
			}
		
		
		}
		
		public void remove_repository(string name) throws InvalidConfigError
		{
			try
			{
				// Remove the group from the file
				config_file.remove_group(name);
				
				// Create an auxiliar variable to store the 
				// new array of the keys for the repos
				string[] aux = new string[repo_keys.length - 1];
				// i for the repo_keys, j for the aux array.
				int i,j;
				j=0;
				for(i = 0; i < repo_keys.length ; i++)
				{
					if( repo_keys[i] != name )
					{
						aux[j] = repo_keys[i];
						j++; 
					}
				
				}
				
				// Set the new array
				repo_keys = aux;
				//config_file.set_string_list("repos","keys",repo_keys);
				
				
			}
			catch (Error e)
			{
				throw new InvalidConfigError.INVALID_CONFIG( e.message );
			}
		}
		
		public void save_configuration()
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
			}
		
		}
		
	}
}
