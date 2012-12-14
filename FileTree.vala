/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/


using Gtk;
using Gdk;

namespace Windows {


	namespace Widget {
	/**
	 * Sub class for Tree view
	 */

	public class FileTree : Gtk.TreeView {

	
		public string repo_path {
			public get;
			public set;
			default = "/home/matias/workspace/guanadoo";
		}

		public const string[] IGNORED = {
			".git",
			"node_modules"
		};

		private TreeStore store;

	 	/**
	 	 * Constructor
	 	 */

	 	public FileTree() {
	 		
	 		store = new TreeStore(2,typeof(string),typeof(string));

			this.change_dir( "/home/matias/workspace/guanadoo" );
		
			set_model( store );
		
			// The columns
			var column = new Gtk.TreeViewColumn();
			
			// File icon
			
			var pixbuf = new Gtk.CellRendererPixbuf();
			column.set_title("");
			column.pack_start(pixbuf, false);
			column.add_attribute(pixbuf,"stock-id",0);
			
			// The name of the file.
			var cell = new Gtk.CellRendererText();
			column.pack_start(cell, false);
			column.add_attribute(cell,"text",1);
			
			append_column (column);
	
			this.config();
		
	 	}
	 	
	 	// Configuration.
	 	private void config() {

			// Set the header invisible
	 		set_headers_visible( false );

			// Change the color of the tree to light grey

			uint16 bg_color = 0xffff;

	 		modify_base(
				StateType.NORMAL,
				Gdk.Color() { 
					red		= bg_color,
					green 	= bg_color,
					blue 	= bg_color
				}
			);
		
	 	}

	 	/* Just update the tree */

	 	public void change_dir( string path ) {
			File repo_dir = File.new_for_path( path );

			try {
				generate_list( repo_dir, null, new Cancellable());
			} catch ( Error e ) {
				stderr.printf("Error: %s\n", e.message);
			}
		}


		/**
		 * This method will return a hashmap<string,string>
		 *	wich first string will be the name of the file,
		 *	and the second one will be the parent folder.
		 *
		 *	If the file it's in the root folder, then the
		 *	parent will be null.
		 */


		public void generate_list (	
			File file, 
			TreeIter? parent = null, 
			Cancellable? cancellable = null 
		) throws Error {

			// Enumerator
			FileEnumerator enumerator = file.enumerate_children (
				"standard::*",
				FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
				cancellable
			);
			FileInfo info = null;
			TreeIter iter;
		
			while(cancellable.is_cancelled() == false && ((info = enumerator.next_file(cancellable)) != null )) 
			{
				// Check if not it's in the omited files.
				if( ! (info.get_name() in IGNORED ) ) {

					// Check if is a dir or a file
					if( info.get_file_type() == FileType.DIRECTORY ) {
					
						this.store.append( out iter, parent);
						this.store.set(iter, 0, STOCK_DIRECTORY, 1, info.get_name());

						File subdir = file.resolve_relative_path(info.get_name());

						this.generate_list(subdir, iter, cancellable );
					} else {
						// It's a file

						this.store.append( out iter, parent);
						this.store.set(iter, 0, STOCK_FILE, 1, info.get_name());
					}

				}
			}

			if ( cancellable.is_cancelled()) {
				throw new IOError.CANCELLED ("Operation was cancelled");
			}
		}

	} // End of FileTree class
	
	} // End of namespace Widget
}// End of namespace Window
