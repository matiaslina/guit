using Gtk;
using WebKit;
using Windows.Widget;

namespace Windows {

string crearDom(string code) {
	return """
	<html>
	<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <link href="/home/matias/programas/linux-git-gui/vala/webview-content/prettify/prettify.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/home/matias/programas/linux-git-gui/vala/webview-content/prettify/prettify.js"></script>
    <script type="text/javascript"></script>
	</head>
	<body onload="prettyPrint();">
	<pre id="myCode" class="prettyprint">"""+ code +"""</pre>
	</body>
	</html>
	""";
}

public class MainWindow : Gtk.Window {
	private const string TITLE = "Git Gui";

	// Box that divides Webkit and buttons from left
	private Gtk.VBox main_box;
	
	// Divide pane
	private Gtk.HPaned main_pane;
	
	// the file tree
	private ScrolledWindow scrolled_window_files;
	private FileTree tree_view;
	
	// The webview.
	private ScrolledWindow scrolled_window_webview;
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
		this.set_border_width( 0 );
		
		// Some things for the menu
		//....
		
		// The containers
		this.main_box = new Gtk.VBox(false, 0);
		this.main_pane = new Gtk.HPaned ();
		this.main_pane.set_position(200);
		this.scrolled_window_files = new ScrolledWindow(null,null);
		this.scrolled_window_webview = new ScrolledWindow(null,null);
		
		// The file tree
		
		tree_view = new FileTree();
		this.scrolled_window_files.add( this.tree_view );
		
		
		
		// The webview 
		this.web_view = new WebView();
		this.scrolled_window_webview.add( this.web_view);
		
		this.main_pane.pack1( this.scrolled_window_files, true, false );
		this.main_pane.pack2( this.scrolled_window_webview, true,true );
		
		
		// The main box.
		
		this.main_box.pack_start ( main_pane , true, true, 0 );
		
		// menu_box.pack_start( menu, true, true, 0);
		//menu_box.add( main_box );
		
		// Add everything to the window
		add( main_box );
	}
	
	private void connect_signals() {
		this.destroy.connect ( Gtk.main_quit );
		this.tree_view.cursor_changed.connect( this.load_file_in_webview);
	}
	
	private string get_selected_path() {
		
		string path = this.tree_view.repo_path;
		
		// Get the path of the selected item.
		Gtk.TreePath tree_path;
		this.tree_view.get_cursor( out tree_path, null);
		
		var model = this.tree_view.get_model();
		
		// get the value.
		string[] path_items = tree_path.to_string().split(":");
		
		for( int i = 0; i < path_items.length ; i++ ) {
			Value val;
			Gtk.TreeIter iter;
			string string_path = "";
			// Make a aux path.
			for( int j = 0; j <= i ; j++) {
				string_path += path_items[j];
				if ( j != i ) {
					string_path += ":";
				} 
			}
			
			Gtk.TreePath aux_tree_path = new Gtk.TreePath.from_string(string_path);
			
			model.get_iter(out iter, aux_tree_path);
			model.get_value(iter, 1, out val);
			
			path += "/" + (string) val;
		}
		
		return path;
	}
	
	// Loads a url
	public void load_file_in_webview () {
		Cancellable cancellable = null;
		string code = "";
		
		try {
			
			File file = File.new_for_path(this.get_selected_path ());
			
			if( file.query_exists ( cancellable )) {
				string line = "";
				size_t s;
				var dis = new DataInputStream( file.read(null) );
				
				while( cancellable.is_cancelled() == false && ((line = dis.read_line( out s, cancellable )) != null) ) {
					code += line +"\n";
				}
				
			}
			
			
		} catch ( Error e) {
			stderr.printf("Error: " + e.message );
		} 
		
		// This load the code of the files into the webview. 
		this.web_view.load_html_string( crearDom(code) , "file:///");
		
		// I need to change the content of an html.
		//this.web_view.load_uri("file:///home/matias/programas/linux-git-gui/vala/webview-content/code.html");
		
	} 
	
} // End of class Main Window

}// end of Windows namespace
