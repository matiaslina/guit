/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using WebKit;
using Windows.Widget;

namespace Windows {

string crearDom(string code) 
{
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
	
	// the menu
	private Gtk.MenuBar bar;
	private Gtk.MenuItem file_menu;
	private Gtk.MenuItem exit_menu;
	
	// the file tree
	private VBox tree_view_container ;
	private Label tree_view_title;
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
	

	// Will create all the widgets in here
	private void create_widgets () {

		// New windows and properties.
		
		this.title = this.TITLE;
		this.window_position = WindowPosition.CENTER;
		this.set_border_width( 0 );
		
		// Some things for the menu
		this.bar = new Gtk.MenuBar();
		this.file_menu = new Gtk.MenuItem.with_label("File");
		bar.add(this.file_menu);
		Gtk.Menu file_submenu = new Gtk.Menu();
		this.file_menu.set_submenu( file_submenu );
		this.exit_menu = new Gtk.MenuItem.with_label("Exit");
		file_submenu.add( this.exit_menu );
		
		// End of menu
		
		// The containers
		main_box = new Gtk.VBox(false, 0);
		main_pane = new Gtk.HPaned ();
		main_pane.set_position(200);

		scrolled_window_files = new ScrolledWindow(null,null);
		scrolled_window_files.set_policy( PolicyType.AUTOMATIC, PolicyType.AUTOMATIC );
		tree_view_container = new VBox(false, 3);
		
		scrolled_window_webview = new ScrolledWindow(null,null);
		scrolled_window_webview.set_policy( PolicyType.AUTOMATIC, PolicyType.AUTOMATIC );
		
		// The file tree
		tree_view_title = new  Label.with_mnemonic("Files.");
		tree_view = new FileTree();
		scrolled_window_files.add( tree_view );
		tree_view_container.pack_start(tree_view_title, false, false, 3);
		tree_view_container.pack_start(scrolled_window_files, true, true ,0);
		
		
		
		// The webview 
		web_view = new WebView();
		scrolled_window_webview.add( web_view);
		
		main_pane.pack1( tree_view_container, true, false );
		main_pane.pack2( scrolled_window_webview, true,true );
		
		
		// The main box.
		main_box.pack_start ( bar, false, false, 0);
		main_box.pack_start ( main_pane , true, true, 0 );
		
		// menu_box.pack_start( menu, true, true, 0);
		//menu_box.add( main_box );
		
		// Add everything to the window
		add( main_box );
	}
	

	// Gonna connect every widget in here
	private void connect_signals() {
		this.destroy.connect ( Gtk.main_quit );
		this.exit_menu.activate.connect( Gtk.main_quit );
		this.tree_view.cursor_changed.connect( this.load_file_in_webview);
	}


	// This will return the path of the selected item in the tree_view
	private string get_selected_path() {
		
		string path = this.tree_view.repo_path;
		
		// Get the path of the selected item.
		Gtk.TreePath tree_path;
		this.tree_view.get_cursor( out tree_path, null);
		var model = this.tree_view.get_model();
		
		// Splits the tree_path to get the full path of the file 
		string[] path_items = tree_path.to_string().split(":");
		

		for( int i = 0; i < path_items.length ; i++ ) 
		{
			Value val;
			Gtk.TreeIter iter;
			string string_path = "";

			// Iteration over the splited path.
			// i.e. 1) 0 , 2) 0:0 3) 0:0:0 ... and so on
			for( int j = 0; j <= i ; j++) 
			{
				string_path += path_items[j];
				if ( j != i ) 
					string_path += ":";
			}
			
			Gtk.TreePath aux_tree_path = new Gtk.TreePath.from_string(string_path);
			
			model.get_iter(out iter, aux_tree_path);
			model.get_value(iter, 1, out val);
			
			path += "/" + (string) val;
		}
		
		return path;
	}
	

	// Loads the url into the webview.
	public void load_file_in_webview () 
	{
		// Some inicializations.
		Cancellable cancellable = null;
		string code = "";
		
		try 
		{	
			File file = File.new_for_path( this.get_selected_path () );
			
			if( file.query_exists ( cancellable ) ) {
				string line = "";
				size_t s;
				var dis = new DataInputStream( file.read(null) );
				
				while( cancellable.is_cancelled() == false && ((line = dis.read_line( out s, cancellable )) != null) ) 
				{
					code += line +"\n";
				}
				
			}
		} catch ( Error e) {
			stderr.printf("Error: " + e.message );
		} 
		
		// This load the code of the files into the webview. 
		this.web_view.load_html_string( crearDom(code) , "file:///");
		
	} 
	
} // End of class Main Window


public class Preferences 
{

	// Constructor.
	public class Preferences() 
	{
	
	}
}
}// end of Windows namespace
