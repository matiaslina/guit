using Gtk;
using Windows;

public static int main(string[] args) {
	Gtk.init(ref args);
	
	new Windows.MainWindow();
	
	//win.load_url("http://www.google.com.ar");
	
	Gtk.main();
	
	
	return 0;
}
