using Gtk;
using Windows;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	Windows.MainWindow mw = new Windows.MainWindow();
	
	stdout.printf( "vamoo \n");
	Gtk.main();
	
	return 0;
}
