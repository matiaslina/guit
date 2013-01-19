/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using GitCore;

namespace Guit.Widgets
{
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
			
			// We clear the store.
			this.store.clear();

			// Set the last index to this.
			
			GitCore.FilesMap map = new FilesMap();
			map.load_list(depth , branch );
			
			// will iterate over all the files.
			for( int i = 0; i < map.files.length() - 1; i++ )
			{
				// If the file has no parent, then we set this on the
				// on the first leaf of the tree. if has, then we append
				// the file to that parent.
				if ( map.files.nth_data(i).parent == "" )
				{
					this.store.append( out child, null );		
				}
				else 
				{
					this.store.append( out child, parent );
				}

				// If the file is a directory.
				if ( map.files.nth_data(i).is_dir )
				{
					// set the parent name to the parent plus '/' 
					// ex:  parent  -> some_directory/subdir
					//		=> some_directory/subdir/
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

}
