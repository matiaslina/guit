/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using WebKit;
using Windows.Widget;
using Configuration;

namespace Windows {

	
	string crearDom(string code) 
	{
		return """
			<html>
			<head>
			<meta http-equiv="Content-type" content="text/html; charset=utf-8" />
			<link href="/home/matias/workspace/linux-git-gui/webview-content/prettify/prettify.css" type="text/css" rel="stylesheet" />
			<script type="text/javascript" src="/home/matias/workspace/linux-git-gui/webview-content/prettify/prettify.js"></script>
			<script type="text/javascript"></script>
			<style>
			 html body { padding: 0px; margin: 0px; }
			 .prettyprint {
				height: auto;
				white-space: pre-wrap;
				white-space: -moz-pre-wrap;
				white-space: -pre-wrap;
				white-space: -o-pre-wrap;
				word-wrap: break-word;
				padding: 15px;

			 } 
			</style>
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
		private Gtk.MenuItem preferences_menu;
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
			this.preferences_menu = new Gtk.MenuItem.with_label("Preferences");
			file_submenu.add(this.preferences_menu);
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
			
			// Should change the policytype on the first parameter
			// to some config.
			scrolled_window_webview.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
		
			// The file tree
			tree_view_title = new  Label.with_mnemonic("Files.");
			tree_view = new FileTree();
			scrolled_window_files.add( tree_view );
			tree_view_container.pack_start(tree_view_title, false, false, 3);
			tree_view_container.pack_start(scrolled_window_files, true, true ,0);
		
		
		
			// The webview 
			web_view = new WebView();
			scrolled_window_webview.add( web_view );
		
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
			this.destroy.connect (this.destroy);
			this.preferences_menu.activate.connect(this.show_preferences);
			this.exit_menu.activate.connect(this.destroy);
			this.tree_view.cursor_changed.connect( this.load_file_in_webview);
		}
		
		/*
		 * 	Signals
		 */

		private void show_preferences()
		{
			new Preferences();
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
		
		private void destroy()
		{
			Config.save_configuration();
			Gtk.main_quit(); 
		} 
	
	} // End of class Main Window


	public class Preferences : Gtk.Dialog
	{
	
		// inicialization
		
		private Gtk.Notebook notebook;
		
		// Repository list
		private Gtk.TreeView repository_list;
		private Button btn_add_repository;
		private Button btn_remove_repository;
		
		// Constructor.
		public class Preferences() 
		{
		
			this.title = "Preferences";
			this.border_width = 5;
			set_default_size(650,450);
			this.create_widgets();
			this.connect_signals();
			this.show_all();
		}
		
		private void create_widgets()
		{
			// Containers
			HBox tree_container = new HBox(false, 0);
			VBox button_tree_container = new VBox(false,0);
			Gtk.Box this_container = get_content_area() as Gtk.Box;
			notebook = new Gtk.Notebook();
			
			
			// Repo tree
			Gtk.ListStore store = new Gtk.ListStore(2,typeof(string),typeof(string));
			Gtk.TreeIter iter;
			
			// Get the paths from config
			string[,] repo_info = Config.repo_paths;
			
			for(int i = 0; i < repo_info.length[0]; i++)
			{
				stdout.printf("%s %s\n",repo_info[i,0],repo_info[i,1]);
				store.append(out iter);
				store.set(iter,0, repo_info[i,0],1,repo_info[i,1]);
			}
			
			repository_list = new Gtk.TreeView.with_model(store);
			CellRendererText cell = new CellRendererText();
			repository_list.insert_column_with_attributes(-1, "Name",cell,"text",0);
			repository_list.insert_column_with_attributes(-1, "Path to repository",cell,"text",1);
			
			// Buttons of the tree
			btn_add_repository = new Button.with_label("Add");
			
			btn_remove_repository = new Button.with_label("Remove");
			// Set the remove button to insensitive
			btn_remove_repository.set_sensitive(false);
			
			button_tree_container.pack_start(btn_add_repository, false,true, 0);
			button_tree_container.pack_start(btn_remove_repository, false, true,0);
			
			tree_container.pack_start(repository_list, true,true,5);
			tree_container.pack_start(button_tree_container,true,true,0);
			
			tree_container.set_border_width(5);
			
			Gtk.Label page_title = new Gtk.Label("Repositories");
			
			notebook.append_page(tree_container, page_title);
			
			this_container.pack_start(notebook,true,true,1);
			
			add_button(STOCK_HELP, Gtk.ResponseType.HELP);
			add_button(STOCK_CLOSE,Gtk.ResponseType.CLOSE);
		}
		
		private void connect_signals()
		{
			repository_list.cursor_changed.connect(check_enabled);
			btn_remove_repository.clicked.connect(this.remove_repository);
			response.connect(on_response);
		}
		
		private void remove_repository()
		{
			// To iteration over the tree.
			Value val;
			Gtk.TreePath tree_path;
			Gtk.TreeIter iter;
			repository_list.get_cursor( out tree_path, null);
			var model = repository_list.get_model();
			
			// Name of the repository to remove
			string name;
			
			model.get_iter(out iter, tree_path);
			model.get_value(iter, 0, out val);
		
			// Set the name, could be null.
			name = (string) val;
			
			stdout.printf("name: %s\n",name);
			
			if( name != null)
			{
				try{
					Config.remove_repository(name);
				}
				catch (Error e)
				{
					stderr.printf("%s\n",e.message);
				}
			}
			
		}
		
		private void check_enabled()
		{
			// Get the path of the selected item.
			Gtk.TreePath tree_path = null;
			this.repository_list.get_cursor( out tree_path, null);
			
			if( tree_path != null && btn_remove_repository.is_sensitive() == false)
				this.btn_remove_repository.set_sensitive(true);
			else if( tree_path == null && btn_remove_repository.is_sensitive() == true)
				this.btn_remove_repository.set_sensitive(false);
		}
		
		private void on_response(Gtk.Dialog source, int response_id)
		{
			switch( response_id )
			{
				case Gtk.ResponseType.CLOSE:
					// Save the preferences.
					destroy();
					break;
			}
		}
	
	}
	
	
}// end of Windows namespace
