namespace Configuration
{
	public errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	// Constants
	public const string REPOSITORIES_PATH = "./repo.ini";
	//public const string CONFIGURATION_PATH = "./config.ini";
	
	// One instance of the repos and one for the configs
	public static Repositories Repos;
	//public static Configuration Config;
	
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
	
	/*
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
	*/
	public class Repositories
	{
		// The key file
		private KeyFile file;

		public static string[] repositories;
				
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
				foreach( unowned string group in repositories)
				{
					stdout.printf("group:%s\n", group);
				}
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

		/**
		 * Retrieve the groups in the file.
		 */
		public string[] get_groups()
		{
			return this.file.get_groups();
		}

		/**
		 * How much repositories are in the file.
		 */
		public int size()
		{
			return file.get_groups().length;
		}
		
		
	} // End of Repositories class

	
} // End of namespace Configuration
