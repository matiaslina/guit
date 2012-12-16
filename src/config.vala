namespace Configuration
{
	errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	// Groups in the conf file.
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
				Config = new Configuration("./config.ini");
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
		public string[] repo_paths{ public get; private set; }
		
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
				repo_paths = config_file.get_string_list("repos","paths");
				
				
			} catch (Error e) 
			{
				throw new InvalidConfigError.INVALID_CONFIG( e.message );
			}
		
		
		}
		
	}
}
