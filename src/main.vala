using Gtk;
using Windows;
using Configuration;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	
	Configuration.load_repos();
	
	new Windows.MainWindow();
	
	Gtk.main();
	
	if( ! Config.save_repositories_in_file() )	
		stderr.printf("Error: Cannot save the configuration on %s\n",Configuration.REPOSITORIES_PATH);
	return 0;
}
