using Gtk;
using Windows;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	new Windows.MainWindow();
	
	Gtk.main();
	
	return 0;
}