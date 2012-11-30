using Gtk;
using Gdk;

namespace Windows {

/**
 * Sub class for Tree view
 */

public class FileTree : Gtk.TreeView {

	
	public string repo_path {
		public get;
		public set;
		default = "/home/matias/guanadoo";
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

		this.change_dir( "/home/matias/guanadoo" );
		
		set_model( store );
		
		// File icon
		var pixbuf = new Gtk.CellRendererPixbuf();
		var column = new Gtk.TreeViewColumn();
		column.set_title("");
		column.pack_start(pixbuf, false);
		column.add_attribute(pixbuf,"stock-id",0);
		append_column (column);
		
		// File name
		Gtk.CellRenderer cell = new Gtk.CellRendererText();
		insert_column_with_attributes(-1,"", cell, "text", 1);
	
		this.config();
		
 	}
 	
 	// Configuration.
 	private void config() {

		// Set the header invisible
 		set_headers_visible( false );

		// Change the color of the tree to light grey

		uint16 bg_color = 0xEEAA;

 		modify_base(
			StateType.NORMAL,
			Gdk.Color() { 
				red		= bg_color,
				green 	= bg_color,
				blue 	= bg_color
			}
		);
		
		stdout.printf("%i\n", uint16.MAX);
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

}

}
