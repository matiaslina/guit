
using Gtk;
using Configuration;

namespace Guit.Preferences
{
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
			
			for( int i=0 ; i < Repos.get_groups().length; i++)
			{
				// Here is the error.
				string key = Repos.get_groups()[i];
				string val = Repos.get_info( key, "path");
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

						// Send a signal that the repo has been added.
						Repos.add( g[last_repo] );
					}

					// Destroy the dialog
					aer_dialog.destroy();
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
					// Send a signal that a repo has been modified.
					//Repos.modify( old_name, new_name );
					
					// Destroy the dialog
					aer_dialog.destroy();
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

					// Send a signal that the a repo has been removed
					Repos.remove( name );
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
}
