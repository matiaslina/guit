using Git;
using Gtk;

namespace GitCore {
	
	public delegate void StringIterator( string s);

	// One instance for the repository.
	private static Git.Repository current_repository;
	
	
	public static void load_repository( string path ) 
	{
		Git.Repository.open( out current_repository , path );
	}
	
	public static void for_local_branches( StringIterator f)
	{
		
		current_repository.for_each_branch( BranchType.LOCAL, (branch_name, type) => {
			if ( branch_name == null)
				return 1;
			f( branch_name );
			return 0;
		});
	}
	
}


