/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using Pango;

using Configuration;
using GitCore;
using Console;

using Guit.Widgets;

namespace Guit {

	// what we are doing
	public enum Status 
	{
		EDITING_REPO = 0,
		ADDING_REPO,
		REMOVING_REPO,
		NONE,
	}

	public class MainWindow : Gtk.Window {
				
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
		private RepositoriesList repositories_list;
		private BranchList local_branch_list;
		private Button do_pull;
		private Button do_push;
		private BranchList remote_branch_list;
		private Button do_commit;

		// Commit tree
		private ScrolledWindow commit_tree_container;
		private CommitTree commit_tree;
	
		// File tree for every commit
		private Box right_container;
		private ScrolledWindow commit_files_tree_container;
		private CommitFileTree commit_files_tree;
			
		// Dialogs
		private Preferences.Preferences preferences;
		
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
		
			this.title = "Guit";
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
			
			// When the user change a value in this comboboxes.
			this.local_branch_list.changed.connect( this.change_commit_list );
			this.repositories_list.changed.connect( this.change_repository );
			
			Repos.add.connect(( t, name ) => {
					this.repositories_list.add_new_repository( name );
			});

			Repos.remove.connect((t, name) => {
					this.repositories_list.remove_repository( name );
			});

			// If there's a click in the commit list.
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
			preferences = new Preferences.Preferences();
		}
		
		private void close_window()
		{
			Gtk.main_quit(); 
		} 

	} // End of class Main Window

}// end of Windows namespace
