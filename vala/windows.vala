using Gtk;
using WebKit;

namespace Windows {

public class MainWindow : Gtk.Window {
	private const string TITLE = "Git Gui";
	
	// First box, divide menu and content */
	private Gtk.VBox menu_box;
	
	// Box that divides Webkit and buttons from left
	private Gtk.HBox main_box;
	
	// Box for the buttons 
	private Gtk.VBox button_box;
	
	// Buttons for readme, todo and licence.
	private Gtk.Button readme;
	private Gtk.Button licence;
	private Gtk.Button todo;
	
	// The webview.
	private WebView web_view;
	
	/**
	 *	Construct for the main window
	 */
	public MainWindow() {
		set_default_size (800,600);
		this.create_widgets();
		
		show_all();
		
	} // End constructor
	
	private void create_widgets () {
		// New windows and properties.
		
		this.title = this.TITLE;
		this.window_position = WindowPosition.CENTER;
		
		// Some things for the menu
		//....
		
		
		// Side panel with 3 buttons
		this.button_box = new Gtk.VBox(false, 0);
		
		// Buttons
		this.readme = new Gtk.Button.with_label("View readme");
		this.licence = new Gtk.Button.with_label("View licence");
		this.todo = new Gtk.Button.with_label("View todo");
		
		// Pack the buttons
		this.button_box.pack_start( this.readme, false, true, 0 );
		this.button_box.pack_start( this.licence, false, true, 0);
		this.button_box.pack_start( this.todo, false, true, 0);
		
		// The webview 
		this.web_view = new WebView();
		
		// The main box.
		this.main_box = new Gtk.HBox(false, 0);
		
		this.main_box.pack_start ( button_box, true, true, 0 );
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
