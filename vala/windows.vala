using Gtk;
using WebKit;

namespace Windows {

public class MainWindow : Gtk.Window {
	private const string TITLE = "Git Gui";
	
	// First box, divide menu and content 
	//private Gtk.VBox menu_box;
	
	// Box that divides Webkit and buttons from left
	private Gtk.HBox main_box;
	
	private FileTree tree_view;
	
	// The webview.
	private WebView web_view;
	
	/**
	 *	Construct for the main window
	 */
	public MainWindow() {
		set_default_size (800,600);
		this.create_widgets ();
		this.connect_signals ();
		show_all();
		
	} // End constructor
	
	private void create_widgets () {
		// New windows and properties.
		
		this.title = this.TITLE;
		this.window_position = WindowPosition.CENTER;
		
		// Some things for the menu
		//....
		
		tree_view = new FileTree();
		
		// The webview 
		this.web_view = new WebView();
		
		// The main box.
		this.main_box = new Gtk.HBox(false, 0);
		
		this.main_box.pack_start ( tree_view , true, true, 0 );
		this.main_box.pack_start( web_view, true, true, 0);
		
		// menu_box.pack_start( menu, true, true, 0);
		//menu_box.add( main_box );
		
		// Add everything to the window
		add( main_box );
	}
	
	private void connect_signals() {
		this.destroy.connect ( Gtk.main_quit );
	}
	
	
	
} // End of class Main Window

}// end of Windows namespace
