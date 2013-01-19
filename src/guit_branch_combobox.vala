/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;

namespace Guit.Widgets
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
		

	}
}
