using Gtk;
using Windows;
using Configuration;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	new Windows.MainWindow();
	
	Configuration.getConfig();
	
	Gtk.main();
	
	
	return 0;
}
