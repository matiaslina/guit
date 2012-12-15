namespace Configuration
{
	errordomain InvalidConfigError
	{
		INVALID_CONFIG,
	}
	
	public const string[] GROUPS = {"repos"};

	public static Configuration config;
	public static Configuration getConfig()
	{
		if (config == null) 
		{
			try 
			{
				config = new Configuration("../config.ini");
			}
			catch ( InvalidConfigError e)
			{
				stdout.printf("%s\n",e.message);
				config = null;
			}
		}
		
		return config;
	}
	
	public class Configuration 
	{
		private KeyFile config_file;
		public string[] repo_paths{ public get; private set; }
		
		public Configuration (string where) throws InvalidConfigError
		{
			try 
			{
				
				config_file.load_from_file(where, KeyFileFlags.NONE);
				repo_paths = config_file.get_string_list("repos","paths");
				
				
			} catch (Error e) 
			{
				throw new InvalidConfigError.INVALID_CONFIG( e.message );
			}
		
		
		}
		
	}
}
