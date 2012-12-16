using Gtk;
using Windows;
using Configuration;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	
	Configuration.getConfig();
	
	new Windows.MainWindow();
	
	Gtk.main();
	
	
	return 0;
}
