namespace Configuration
{
	public errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	// Constants
	public const string REPOSITORIES_PATH = "./repo.ini";
	public const string CONFIGURATION_PATH = "./config.ini";
	
	// One instance of the repos and one for the configs
	public static Repositories Repos;
	public static Configuration Config;
	
	// init for the above instances
	public static Repositories load_repos()
	{
		if( Repos == null )
		{
			try
			{
				Repos = new Repositories(REPOSITORIES_PATH);
			}
			catch ( InvalidConfigError e)
			{
				stdout.printf("%s\n",e.message);
				Repos = null;
			}
		}
		
		return Repos;
	}
	
	
	public static Configuration load_config()
	{
		if (Config == null) 
		{
			try 
			{
				Config = new Configuration(CONFIGURATION_PATH);
			}
			catch ( InvalidConfigError e)
			{
				stdout.printf("%s\n",e.message);
				Config = null;
			}
		}
		
		return Config;
	}

	public class Repositories
	{
		// The key file
		private KeyFile file;

		public static string[] repositories;

		public signal void add( string name );
		public signal void modify ( string old_name, string new_name );
		public signal void remove ( string name );
				
		/**
		 * Constructor of a new Repositories manager
		 */
		public Repositories( string where ) throws InvalidConfigError
		{
			try
			{
				file = new KeyFile();
				file.load_from_file( where, KeyFileFlags.NONE);
				repositories = file.get_groups();
			}
			catch ( Error e )
			{
				throw new InvalidConfigError.INVALID_CONFIG(e.message);
			}
		}
		
		/**
		 * Add a repository
		 */
		public void add_repository( string name, string path )
		{
			file.set_string(name,"path", path);
			file.set_boolean(name,"last_used",false);
		}
		
		/**
		 * Remove a repository from the list
		 */
		
		public void remove_repository( ref string name ) throws InvalidConfigError
		{
			try
			{
				file.remove_group( name );
			}
			catch (Error e)
			{
				throw new InvalidConfigError.INVALID_CONFIG(e.message);
			}
		}
		
		/**
		 * Save the data into a file.
		 */
		
		public bool save_in_file()
		{
			// New data to write into the config file.
			string keyfile_str = file.to_data ();
			try
			{
				FileUtils.set_contents(REPOSITORIES_PATH, keyfile_str);
			}
			catch (Error e)
			{
				stderr.printf("Error:%s\n",e.message);
				return false;
			}
			return true;	
		}
		
		/**
		 * Get the value from the key passed by parameter
		 */
		
		public string? get_info( string group, string key )
		{
			try
			{
				return file.get_string( group, key);
			}
			catch( Error e )
			{
				stderr.printf("%s\n", e.message);
				return null;
			}
		}
		
		public bool get_active ( string group )
		{
			try
			{
				return file.get_boolean( group, "last_used");
			}
			catch( Error e)
			{
				stderr.printf("%s\n",e.message);
				return false;
			}
		}

		/**
		 * Retrieve the groups in the file.
		 */
		public string[] get_groups()
		{
			return this.file.get_groups();
		}

		public string get_last_repo()
		{
			string[] aux = this.file.get_groups();
			uint last_index = aux.length - 1;

			return aux[last_index];
		}

		/**
		 * How much repositories are in the file.
		 */
		public int size()
		{
			return file.get_groups().length;
		}
		
		
	} // End of Repositories class

	public class Configuration
	{
		private KeyFile file;

		public string name;
		public string email;
		
		/**
		 * Constructor
		 */
		public Configuration( string where ) throws InvalidConfigError
		{
			try
			{
				file = new KeyFile();
				file.load_from_file( where, KeyFileFlags.NONE);
			}
			catch ( Error e )
			{
				throw new InvalidConfigError.INVALID_CONFIG(e.message);
			}
		}
		/**
		 * Save the configuration into a file
		 */ 
		public bool save_in_file()
		{
			// New data to write into the config file.
			string keyfile_str = this.file.to_data ();
			try
			{
				FileUtils.set_contents(CONFIGURATION_PATH, keyfile_str);
			}
			catch (Error e)
			{
				stderr.printf("Error:%s\n",e.message);
				return false;
			}
			return true;	
		}
	}

	
} // End of namespace Configuration
