/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using Pango;
using Widget;
using Configuration;
using GitCore;

namespace Windows {

	/*
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
	*/
	// what we are doing
	public enum Status 
	{
		EDITING_REPO = 0,
		ADDING_REPO,
		REMOVING_REPO,
		NONE,
	}

	public class MainWindow : Gtk.Window {
		
		private const string TITLE = "Guit";
		
		private int last_commit_index;

		// Box that divides Webkit and buttons from left
		private Gtk.Box main_box;
		private Gtk.Box control_box;
	
		// Divide pane
		private Gtk.Paned main_pane;
	
		// the menu
		private Gtk.MenuBar bar;
		private Gtk.MenuItem file_menu;
		private Gtk.MenuItem preferences_menu;
		private Gtk.MenuItem exit_menu;
		
		// Top controls
		private Widget.RepositoriesList repositories_list;
		private Widget.BranchList local_branch_list;
		private Button do_pull;
		private Button do_push;
		private Widget.BranchList remote_branch_list;
		private Button do_commit;

		// Commit tree
		private ScrolledWindow commit_tree_container;
		private CommitTree commit_tree;
	
		// File tree for every commit
		private Box right_container;
		private ScrolledWindow commit_files_tree_container;
		private CommitFileTree commit_files_tree;
			
		// Dialogs
		private Preferences preferences;
		
		/**
		 *	Construct for the main window
		 */
		public MainWindow() {
			
			set_default_size (1024,600);

			this.last_commit_index = -1;

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
			main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			control_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			main_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
			main_pane.set_position(200);
			right_container = new Gtk.Box( Gtk.Orientation.VERTICAL, 3); 
			// Top controls
			repositories_list = new RepositoriesList();
			local_branch_list = new BranchList( Git.BranchType.LOCAL);
			do_push = new Button.with_label("Push");
			do_pull = new Button.with_label("Pull");
			remote_branch_list = new BranchList( Git.BranchType.REMOTE);
			do_commit = new Button.with_label("Commit");

			control_box.pack_start( repositories_list, false, false, 4);
			control_box.pack_start( local_branch_list, true, true , 0);
			control_box.pack_start( do_pull, false, true, 4);
			control_box.pack_start( do_push, false, true, 4);
			control_box.pack_start( remote_branch_list, true,true, 0);
			control_box.pack_start( do_commit, false, true, 0);

			// Commit tree
			
			commit_tree_container = new ScrolledWindow(null, null);
			commit_tree_container.set_policy( PolicyType.AUTOMATIC, PolicyType.AUTOMATIC );
			commit_tree_container.set_shadow_type( ShadowType.IN);

			// now we set to master branch. will change later
			this.commit_tree = new CommitTree("master");
			commit_tree_container.add( commit_tree );
			main_pane.pack1( commit_tree_container , true, true);

			// Commit file tree view
			commit_files_tree_container = new ScrolledWindow (null, null);
			commit_files_tree_container.set_policy( PolicyType.AUTOMATIC,PolicyType.AUTOMATIC);
			
			commit_files_tree = new CommitFileTree ();
			// We need to figure out how to fill this treeview ("¬.¬)
			
			commit_files_tree_container.add ( commit_files_tree );
			right_container.pack_start( commit_files_tree_container, true, true, 0 );
			main_pane.pack2( right_container, true, true );
			
			// The main box.
			main_box.pack_start ( bar, false, false, 0);
			main_box.pack_start ( control_box, false,false, 3);
			main_box.pack_start ( main_pane , true, true, 0 );
		
			// menu_box.pack_start( menu, true, true, 0);
			//menu_box.add( main_box );
		
			// Add everything to the window
			add( main_box );
		}
	

		// Gonna connect every widget in here
		private void connect_signals() {
			this.destroy.connect ( this.close_window );
			this.key_press_event.connect ( key_pressed );

			this.local_branch_list.changed.connect( this.change_commit_list );
			this.repositories_list.changed.connect( this.change_repository );

			this.commit_tree.cursor_changed.connect( this.load_file_tree );

			this.preferences_menu.activate.connect(this.show_preferences);
			this.exit_menu.activate.connect(this.close_window);
		}
		
		/*
		 * 	Signals
		 */

		private bool key_pressed ( Gtk.Widget source, Gdk.EventKey key)
		{
			switch ( key.keyval )
			{
				case Gdk.Key.F9:
					console.toggle();
					break;
			}

			return false;
		}
		
		private void load_file_tree ()
		{
			// Initializations.
			int[] depth;
			TreePath path;
			
			
			commit_tree.get_cursor ( out path, null );
			if ( path != null )
			{
				// Get the indice. It will be always depth[0] because
				// It's a liststore.
				depth = path.get_indices();
				if ( this.last_commit_index != depth[0] || local_branch_list.get_selected_branch() != commit_files_tree.last_branch)
				{
					this.last_commit_index = depth[0];
					commit_files_tree.load_nth_file_tree ( depth[0], local_branch_list.get_selected_branch() );
					

				}
			}
		}

		private void change_commit_list ()
		{
			// Initializations
			GLib.Value branch_name;
			TreeIter iter;
			TreePath path;
			ListStore store = (ListStore) local_branch_list.get_model();
			
			// Get the selected index in the local branchs
			int selected_branch_index = local_branch_list.get_active();
			
			// I will check if it's a valid index
			if( selected_branch_index > -1 )
			{
				// Get the value
				path = new Gtk.TreePath.from_indices( selected_branch_index );
				store.get_iter( out iter, path);
				store.get_value( iter, 0, out branch_name );
						
				// And reloads the commit list. awesome, right? :P
				this.commit_tree.load_commit_list( (string) branch_name );
			}		
		
		}
		
		private void change_repository ()
		{
			// Initializations
			string path;
			GLib.Value repo_name;
			TreeIter iter;
			TreePath tree_path;
			ListStore store = (ListStore) repositories_list.get_model();
			
			// Get the selected index in the local branchs
			int selected_branch_index = repositories_list.get_active();
			
			// Get the value
			tree_path = new Gtk.TreePath.from_indices( selected_branch_index );
			store.get_iter( out iter, tree_path);
			store.get_value( iter, 0, out repo_name );
			
			path = Configuration.Repos.get_info( (string) repo_name, "path");
			
			if( path == null )
				return;
			
			// Load the repository
			GitCore.load_repository( path );
			
			// Log into the console
			console.change_repository( (string) repo_name, path );

			// Modify all the data in the window.
			local_branch_list.reload_branch_list();
			remote_branch_list.reload_branch_list();
		}

		private void show_preferences()
		{
			preferences = new Preferences();
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
			set_default_size(650,450);
			this.create_widgets();
			this.connect_signals();
			this.show_all();
		}
		
		private void create_widgets()
		{
			// Containers
			Gtk.Box this_container = this.get_content_area() as Gtk.Box ;
			// Main container for the repository list
			Box tree_container = new Box(Gtk.Orientation.VERTICAL, 0);
			// Button containers
			Box button_tree_container = new Box(Gtk.Orientation.VERTICAL,0);
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
			
			add_button(Gtk.Stock.HELP, Gtk.ResponseType.HELP);
			add_button(Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
			
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
					aer_dialog = new RepoDialog( Status.ADDING_REPO);
					aer_dialog.show_this_dialog();
					
					int response = aer_dialog.run();
					if( response == Gtk.ResponseType.OK)
					{
						string[] g = Repos.get_groups();
						int last_repo = g.length -1;
						// Then we add this to the list.
						Gtk.ListStore model = (Gtk.ListStore) repository_list.get_model();
						TreeIter iter;
						
						model.append( out iter );
						model.set(iter, 0, g[last_repo], 1, Repos.get_info( g[last_repo], "path") );
						
					}
					break;
				case Status.EDITING_REPO:
					aer_dialog = new RepoDialog( Status.EDITING_REPO );
					aer_dialog.show_this_dialog();
					this.get_selected_repository( out name, Status.EDITING_REPO );
					aer_dialog.set_editing( name );
					
					int response = aer_dialog.run();
					if (response == Gtk.ResponseType.OK)
					{
						// Change the info in the store.
						Gtk.TreePath tree_path;
						Gtk.TreeIter iter;
						repository_list.get_cursor( out tree_path, null);
						Gtk.ListStore model = (Gtk.ListStore) repository_list.get_model();

						model.get_iter(out iter, tree_path);
						model.set(iter,0, name, 1, Repos.get_info( name, "path"));
					}
					
					break;
				case Status.REMOVING_REPO:
					this.get_selected_repository(out name, Status.REMOVING_REPO );
				
					stdout.printf("name: %s\n",name);
					if( name != null)
					{
						try
						{
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
		
		private void get_selected_repository( out string name, Status status )
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
			if (status == Status.REMOVING_REPO)
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
					//this.hide_all();
					destroy();
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
		
		private Status current_status;
		
		private Gtk.Entry t_repository_name;
		private Gtk.Entry t_repository_path;
		
		/**
		 * Consturctor.
		 * The parameter may be null because this set if we're
		 * editing or creating a repository.
		 */
		public RepoDialog ( Status status )
		{
			
			set_keep_above(true);
			this.current_status = status;
							
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
			add_button(Gtk.Stock.OK, Gtk.ResponseType.OK);
			add_button(Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
			
			// We connect some signals in a separated function
			this.connect_signals();
			
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
					
					// Add the repo to the configuration
					Repos.add_repository( t_repository_name.get_text(), t_repository_path.get_text());
					
					// Set the entries to nothing.
					t_repository_name.set_text("");
					t_repository_path.set_text("");
					
					if( current_status == Status.EDITING_REPO)
						t_repository_name.set_sensitive( true );
						
					//this.hide_all();
					destroy();
					break;
				case Gtk.ResponseType.CANCEL:
					//this.hide_all();
					destroy();
					break;
			}
		}
		
		public void show_this_dialog()
		{
			show_all();
		}
		
		public void set_editing( string repository_name)
		{
			// That the repo name it's null means that we're
			// creating a new repository form a path
			t_repository_name.set_sensitive(false);
			t_repository_name.set_text( repository_name );
			t_repository_path.set_text(Repos.get_info( repository_name, "path" ));
			
		}
	}
	
	
	
}// end of Windows namespace
