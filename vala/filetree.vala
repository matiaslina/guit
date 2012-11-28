
namespace Windows {

public class FileTree : Gtk.TreeView {
	
	// The path that points the tree.
	public string repo_path { get; set; default = "/home/matias/guanadoo" ;}
	
	private FileMap files;
	
	public FileTree() {
		stdout.printf("%s\n", this.repo_path);
		files = new FileMap(this.repo_path);
		
	}

} // End of class FileTree

private class FileMap {
	
	public Gee.HashMap<string,string> file_map;
	
	// Dirs ignored. this will be removed after do the config.
	private Gee.ArrayList<string> ignored;
	
	public FileMap (string path) {
		
		this.file_map = new Gee.HashMap<string,string>();
		
		// Setting up the ignored list
		this.ignored = new Gee.ArrayList<string>();
		this.ignored.add(".git");
		this.ignored.add("node_modules");
		
		// Setting the repo_file
		File repo_dir = File.new_for_path(path);
		try {
			this.generate_list( repo_dir , "" , new Cancellable());
		} catch (Error e) {
			stdout.printf ("Error: %s\n", e.message);
		}
	}
	
	/**
	 * This method will return a hashmap<string,string>
	 *	wich first string will be the name of the file,
	 *	and the second one will be the parent folder.
	 *
	 *	If the file it's in the root folder, then the
	 *	paretn will be null.
	 */
	
	private void generate_list (File file,string? parent = null, Cancellable? cancellable = null) throws Error {
		
		// The enumerator of files.
		FileEnumerator enumerator = file.enumerate_children (
			"standard::*",
			FileQueryInfoFlags.NOFOLLOW_SYMLINKS, 
			cancellable
		);
		
		// Info of the file
		FileInfo info = null;
		
		// meanwhile anyone cancelled the operation or
		// the next file exists, we will take the file name
		while(cancellable.is_cancelled() == false && ((info = enumerator.next_file(cancellable)) != null)) {
			
			// check if the file isn't in the files omited.
			if( ! this.ignored.contains(info.get_name()) ) {
				
				// Check if is a dir or a file
				if( info.get_file_type () == FileType.DIRECTORY ) {
					// get the subdir.
					File subdir = file.resolve_relative_path (info.get_name ());
					
					// add the subdir to the hashmap
					this.file_map[info.get_name()] = parent;
					stdout.printf ("Added folder %s with the parent %s\n",info.get_name(), parent);
					
					generate_list (subdir, info.get_name(), cancellable);
				} else {
					this.file_map.set( info.get_name(), parent);
					stdout.printf( "Added file %s with parent %s\n", info.get_name(), parent);
				}
			}
		}
		
		// Throw error if the operation is cancelled
		if (cancellable.is_cancelled()) {
			throw new IOError.CANCELLED ("Operation was cancelled");
		}
		
	} // End of generate_list()

}

}
