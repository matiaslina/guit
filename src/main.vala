using Gtk;
using Windows;
using Configuration;
using GitCore;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	
	Configuration.load_repos();
	GitCore.load_repository("/home/matias/workspace/guit");
	GitCore.last_commit ();
	
	GitCore.test_tree(0);

	new Windows.MainWindow();
	
	Gtk.main();
	
	if( ! Repos.save_in_file() )	
		stderr.printf("Error: Cannot save the configuration on %s\n",Configuration.REPOSITORIES_PATH);
	return 0;
}
