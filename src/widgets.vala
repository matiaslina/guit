/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using Pango;
using Configuration;
using GitCore;

namespace Widget 
{
	
	public class BranchList : Gtk.ComboBox 
	{

		private Git.BranchType branch_type;
		private ListStore store;

		public BranchList( Git.BranchType? t = null ) 
		{
			if ( t == null )
				this.branch_type = Git.BranchType.LOCAL;
			else
				this.branch_type = t;

			store = new ListStore(1, typeof(string) );
			this.set_model(store);
			
			Gtk.CellRendererText cell = new CellRendererText();
			this.pack_start(cell, true);
			this.add_attribute(cell, "text", 0);
			
			
			// Get all local branches
			if( this.branch_type == Git.BranchType.LOCAL)
				GitCore.for_local_branches( fill_store );
			else if ( this.branch_type == Git.BranchType.REMOTE )
				GitCore.for_remotes_branches( fill_store );
				
			this.active = 0;
	
		}

		public void reload_branch_list()
		{
			this.clear_list();
			if( this.branch_type == Git.BranchType.LOCAL)
				GitCore.for_local_branches( fill_store );
			else if ( this.branch_type == Git.BranchType.REMOTE )
				GitCore.for_remotes_branches( fill_store );
			this.active = 0;
		}
		
		public string get_selected_branch ()
		{
			TreeIter iter;
			Value val;
			
			this.get_active_iter ( out iter );
			this.store.get_value(iter, 0, out val);
			
			return (string) val;
		}
		
		private void clear_list()
		{
			store.clear();
		}

		// The delegate
		private void fill_store( string g )
		{
			TreeIter iter;

			store.append( out iter );
			store.set( iter, 0 , g);
	
			this.set_model( store );
		}
		


	} // End of BranchList class

	public class CommitTree : Gtk.TreeView
	{
		public CommitTree( string? branch )
		{

			this.set_headers_visible( false );

			if ( branch == null )
				branch = "master";

			load_commit_list( branch );				
			
			// Columns
			TreeViewColumn column = new TreeViewColumn();
			column.set_title("");
			
			// Config of the cells
			CellRendererText cell;
			
			cell = new CellRendererText();
			column.pack_start(cell, true);
			column.add_attribute(cell, "text", 0);

			this.append_column(column);

		}
		
		public void load_commit_list( string branch )
		{
			uint i;
			

			Gtk.TreeIter iter; 
			Gtk.ListStore store = new Gtk.ListStore(2, typeof(string), typeof(string));
			List<CommitInfo?> commit_info = GitCore.all_commits( branch );



			for( i = 0 ; i < commit_info.length(); i++)
			{
				string text = "";
				string time_str = "";
				// Time
				time_t ts = (time_t) commit_info.nth_data(i).time;
				var t = Time.gm ( ts );
				time_str = "%s %s".printf(t.format("%b %d, %Y").to_string(), t.format("%H:%M").to_string());
				
				// Author and commit
				text = "%s\t\t%s\n%s".printf(commit_info.nth_data(i).author,time_str, commit_info.nth_data(i).message);

				store.append( out iter );
				store.set(iter, 0, text);
				
				
			}
			
			this.set_model( store );

		}
	} // End of CommitTree class

	public class CommitFileTree : Gtk.TreeView
	{
		private TreeStore store;
		public weak string last_branch;
		
		public CommitFileTree ()
		{
			// Initialize the treestore
			this.store = new TreeStore (2, typeof(string), typeof(string) );

			// Set the model.
			set_model ( this.store );
			
			// Set the mixed_column with a pixbuf and a string
			// This is for the icon and the name of the file
			TreeViewColumn mixed_column = new TreeViewColumn();
			mixed_column.set_title( "Files" );

			var pixbuf_cell = new CellRendererPixbuf();
			var text_cell = new CellRendererText ();
			
			mixed_column.pack_start( pixbuf_cell, false );
			mixed_column.pack_start ( text_cell, true );

			mixed_column.add_attribute( pixbuf_cell, "stock-id", 0 );
			mixed_column.add_attribute( text_cell, "text", 1);

			append_column( mixed_column );

			this.visual_config ();

		}

		private void visual_config ()
		{
			uint16 background_color = 0x00AA;

			this.modify_base (
				StateType.NORMAL,
				Gdk.Color () 
				{
					red = background_color,
					green = background_color,
					blue = background_color
				}
			);
		}
		
		public void load_nth_file_tree ( uint depth, string branch )
		{
			// We clear the file tree.
			this.last_branch = branch;
			TreeIter parent = TreeIter(), child;
			string parent_name = "";
			string pixbuf_name;
			
			this.store.clear();

			// Set the last index to this.
			
			GitCore.FilesMap map = new FilesMap();
			map.load_map(depth , branch );
			
			for( int i = 0; i < map.files.length() - 1; i++ )
			{
				if ( map.files.nth_data(i).parent == "" )
				{
					this.store.append( out child, null );
						
				}
				else 
				{
					this.store.append( out child, parent );
				}

				if ( map.files.nth_data(i).is_dir )
				{
					parent_name = map.files.nth_data(i).parent + "/";
					parent = child;
					pixbuf_name = Stock.DIRECTORY;
				}
				else
					pixbuf_name = Stock.FILE;
				
				this.store.set ( child,0, pixbuf_name, 1, map.files.nth_data(i).name , -1);
			}	

			//set_model( this.store );
		}
	}	
	
	public class RepositoriesList : Gtk.ComboBox
	{
		public unowned string selected_repository;
		
		public RepositoriesList ()
		{
			// The columns
			CellRendererText cell;
			
			cell = new CellRendererText();
			this.pack_start(cell, true);
			this.add_attribute(cell, "text", 0);
			
			load_repo_list();
		}
		
		public void load_repo_list()
		{
			string[] repositories = Configuration.Repos.get_groups();
			ListStore store = new ListStore(1, typeof(string));
			TreeIter iter;
			int p = 0;
			bool already_taken = false;
			
			foreach( unowned string name in repositories )
			{
				store.append( out iter );
				store.set( iter, 0 , name);
				
				if( Configuration.Repos.get_active( name ) )
				{
					already_taken = true;
					this.selected_repository = name;
				}	
				if ( ! already_taken )
					p++;
				
			}
			
			this.set_model( store );
			this.active = p;
		}

		public void add_new_repository( string name )
		{
			TreeIter iter;
			ListStore store = (ListStore) this.get_model();
			
			store.append( out iter );
			store.set( iter, 0, name );
		}

		public void remove_repository( string name )
		{
			TreeIter iter;
			uint i = 0;
			TreePath path = new TreePath.from_indices(i);
			ListStore store = (ListStore) this.get_model();

			while ( store.get_iter( out iter, path ) )
			{
				Value val;
				store.get_value( iter, 0, out val );

				if ( ((string) val) == name )
				{
					store.remove( iter );
					break;
				}
				i++;
				path = new TreePath.from_indices(i);
			}
		}
	} // End of RepositoriesList

}// End of Widgets namespace
