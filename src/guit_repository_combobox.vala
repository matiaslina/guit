/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;

namespace Guit.Widgets
{
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
	}
}
