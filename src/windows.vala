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
	
	// what we are doing
	public static enum Status 
	{
		EDITING_REPO = 0,
		ADDING_REPO,
		REMOVING_REPO,
	}

	public class MainWindow : Gtk.Window {
		
		private const string TITLE = "Guit";
		

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
		
		// Dialogs
		private Preferences preferences;
	
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
			this.destroy.connect ( this.close_window );
			this.preferences_menu.activate.connect(this.show_preferences);
			this.exit_menu.activate.connect(this.close_window);
			this.tree_view.cursor_changed.connect( this.load_file_in_webview);
		}
		
		/*
		 * 	Signals
		 */

		private void show_preferences()
		{
			if ( preferences == null )
				preferences = new Preferences();
			else
				preferences.show_preferences();	
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
		
		private void close_window()
		{
			Gtk.main_quit(); 
		} 
	
	} // End of class Main Window


	public class Preferences : Gtk.Dialog
	{
	
		private Gtk.Notebook notebook;
		private Gtk.ScrolledWindow scrolled_repo_list;
		
		// Repository list
		private Gtk.TreeView repository_list;
		private Button btn_add_repository;
		private Button btn_remove_repository;
		private Button btn_edit_repository;
		
		private RepoDialog aer_dialog;
		
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
			Gtk.Box this_container = get_content_area() as Gtk.Box;
			// Main container for the repository list
			HBox tree_container = new HBox(false, 0);
			// Button containers
			VBox button_tree_container = new VBox(false,0);
			notebook = new Gtk.Notebook();
			
			// Scrolled window for the repository list
			scrolled_repo_list = new ScrolledWindow(null,null);
			scrolled_repo_list.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
			scrolled_repo_list.set_shadow_type( ShadowType.IN);
			
			// Repo tree
			Gtk.ListStore store = new Gtk.ListStore(2,typeof(string),typeof(string));
			Gtk.TreeIter iter;
			
			for( int i=0 ; i < Repos.repositories.length; i++)
			{
				// Here is the error.
				string key = Repos.repositories[i];
				string val = Repos.get_info( key, "path");
				stdout.printf("Key: %s\tValue: %s\n", key, val);
				store.append( out iter );
				store.set(iter,0, key, 1, val);
			}			
			repository_list = new Gtk.TreeView.with_model(store);
			CellRendererText cell = new CellRendererText();
			repository_list.insert_column_with_attributes(-1, "Name",cell,"text",0);
			repository_list.insert_column_with_attributes(-1, "Path to repository",cell,"text",1);
			
			// Buttons of the tree
			btn_add_repository = new Button.with_label("Add");
			btn_edit_repository = new Button.with_label("Edit");
			btn_remove_repository = new Button.with_label("Remove");
			
			// Set the remove button to insensitive
			btn_remove_repository.set_sensitive(false);
			btn_edit_repository.set_sensitive(false);
		
			// Packaging
			button_tree_container.pack_start(btn_add_repository, false,true, 0);
			button_tree_container.pack_start( btn_edit_repository, false, true, 0);
			button_tree_container.pack_start(btn_remove_repository, false, true,0);
			
			scrolled_repo_list.add( repository_list);
			tree_container.pack_start(scrolled_repo_list, true,true,5);
			tree_container.pack_start(button_tree_container,true,true,0);
			
			tree_container.set_border_width(5);
			
			// Tabs for the notebook
			Gtk.Label page_title;
			
			page_title = new Gtk.Label("Repositories");
			
			notebook.append_page(tree_container, page_title);
			
			this_container.pack_start(notebook,true,true,1);
			
			add_button(STOCK_HELP, Gtk.ResponseType.HELP);
			add_button(STOCK_CLOSE,Gtk.ResponseType.CLOSE);
			
		}
		
		private void connect_signals()
		{
			repository_list.cursor_changed.connect(check_enabled);
			btn_add_repository.clicked.connect(() => {
				aer_repository(Status.ADDING_REPO);
			});
			btn_edit_repository.clicked.connect(() => {
				aer_repository(Status.EDITING_REPO);
			});
			btn_remove_repository.clicked.connect(() => {
				aer_repository(Status.REMOVING_REPO);
			});
			response.connect(on_response);
		}
				
		/**
		 * This method is triggered when the user want's to 
		 * Add/Edit/Remove a repository.
		 */
		private void aer_repository(int status)
		{
			string name;
		
			switch( status )
			{
				case Status.ADDING_REPO:
					if ( aer_dialog == null )
						aer_dialog = new RepoDialog();
					break;
				case Status.EDITING_REPO:
					if ( aer_dialog == null )
						aer_dialog = new RepoDialog( );
					this.get_selected_repository( out name, Status.EDITING_REPO );
					aer_dialog.set_editing( name );
					break;
				case Status.REMOVING_REPO:
					this.get_selected_repository(out name, Status.REMOVING_REPO );
				
					stdout.printf("name: %s\n",name);
	
					if( name != null)
					{
						try{
							Repos.remove_repository(ref name);
						}
						catch (Error e)
						{
							stderr.printf("%s\n",e.message);
						}
					}
					break;
			}
		}
		
		private void get_selected_repository( out string name, Status? status )
		{
			// To iteration over the tree.
			Value val;
			Gtk.TreePath tree_path;
			Gtk.TreeIter iter;
			repository_list.get_cursor( out tree_path, null);
			Gtk.ListStore model = (Gtk.ListStore) repository_list.get_model();

			model.get_iter(out iter, tree_path);
			model.get_value(iter, 0, out val);
			
			// Lets remove the repo from the list only if we are removing the repo :P
			if ( (status != null ) && (status == Status.REMOVING_REPO))
				model.remove( iter );
			
			name = (string) val;
			
		}
		
		private void check_enabled()
		{
			// Get the path of the selected item.
			Gtk.TreePath tree_path = null;
			this.repository_list.get_cursor( out tree_path, null);
			
			if( tree_path != null 
				&& btn_remove_repository.is_sensitive() == false 
				&& btn_edit_repository.is_sensitive() == false)
			{
				this.btn_remove_repository.set_sensitive(true);
				this.btn_edit_repository.set_sensitive(true);
			}
			else if( tree_path == null 
				&& btn_remove_repository.is_sensitive() == true 
				&& btn_edit_repository.is_sensitive() == true)
			{
				this.btn_remove_repository.set_sensitive(false);
				this.btn_edit_repository.set_sensitive(false);
			}
			
		}
		
		private void on_response(Gtk.Dialog source, int response_id)
		{
			switch( response_id )
			{
				case Gtk.ResponseType.CLOSE:
					this.hide_all();
					break;
				case Gtk.ResponseType.HELP:
					// This show the help in here
					// this do nothing for now.
					break;
			}
		}
		
		/**
		 * Shows the preferences
		 */
		public void show_preferences()
		{
			assert( this != null);
			this.show_all();
		}
		
	} // End of preferences 
	
	
	/**
	 * Just a dialog to Add or edit the repositories on
	 * the click on some buttons. This dialog have only
	 * a name for the repo, and the path.
	 */
	
	public class RepoDialog : Gtk.Dialog
	{
		
		private int current_status;
		
		private Gtk.Entry t_repository_name;
		private Gtk.Entry t_repository_path;
		
		/**
		 * Consturctor.
		 * The parameter may be null because this set if we're
		 * editing or creating a repository.
		 */
		public RepoDialog ()
		{
							
			// Container
			Gtk.Box this_container = get_content_area() as Gtk.Box;
			
			// Creating some elements
			Label l_name = new Label("Name:");
			Label l_path = new Label("Path:");
			t_repository_path = new Entry();
			t_repository_name = new Entry();
			
			// Pack all in the main container
			this_container.pack_start(l_name,false, false, 0);
			this_container.pack_start(t_repository_name, true,true, 0);
			this_container.pack_start(l_path, false, false, 0);
			this_container.pack_start(t_repository_path , true, true, 0);
			
			// Adds two buttons.
			add_button(STOCK_OK, Gtk.ResponseType.OK);
			add_button(STOCK_CANCEL, Gtk.ResponseType.CANCEL);
			
			// We connect some signals in a separated function
			this.connect_signals();
			
			show_all();
		}
		
		private void connect_signals()
		{
			response.connect( on_response );
		}
		
		private void on_response(Gtk.Dialog source, int response_id)
		{
			switch( response_id )
			{
				case Gtk.ResponseType.OK:
					// Do some save information.
					stdout.printf("Button OK pressed :)\n");
					break;
				case Gtk.ResponseType.CANCEL:
					destroy();
					break;
			}
		}
		
		public void set_editing( string repository_name)
		{
			// That the repo name it's null means that we're
			// creating a new repository form a path
			t_repository_path.set_text(Repos.get_info( repository_name, "path" ));
			t_repository_name.set_text( repository_name );
			
		}
	}
	
}// end of Windows namespace
