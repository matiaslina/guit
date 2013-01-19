using Gtk;
using Windows;
using Configuration;
using GitCore;
using Console;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	// Load the configuration.
	Configuration.load_repos();
	
   	string[] groups = Repos.get_groups();	   
	if ( groups.length > 0 ) 
	{
		string path = Repos.get_info( groups[0], "path" );
		GitCore.load_repository( path );
	}

	// Load a new console.
	create_console();

	new Windows.MainWindow();
	
	Gtk.main();
	
	if( ! Repos.save_in_file() )	
		stderr.printf("Error: Cannot save the configuration on %s\n",Configuration.REPOSITORIES_PATH);
	return 0;
}
