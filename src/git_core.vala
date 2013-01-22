using Git;
using Utils;

using GitCore.Structs;

namespace GitCore {

	

	// One instance for the repository.
	private static Git.Repository current_repository;
	
	
	public static void load_repository( string path ) 
	{
		Git.Repository.open( out current_repository , path );
	}
	
	/**
	 * Retrive all the local branches from the repository.
	 */
	public static void for_local_branches( StringIterator f)
	{
		// Iteration over all the local branches
		current_repository.for_each_branch( BranchType.LOCAL, (branch_name, type) => {
			if ( branch_name == null)
				return 1;
			f( branch_name );
			return 0;
		});
	}

	/**
	 * Same as above. the only diference it's that this
	 * iterate over all the remote branches.
	 */
	public static void for_remotes_branches( StringIterator f)
	{
		current_repository.for_each_branch( BranchType.REMOTE, (branch_name, type) => {
			if ( branch_name == null)
				return 0;
			f(branch_name);
			return 0;
		});
	}

	/**
	 * Return the last commit.
	 */

	public static Commit? last_commit ()
	{
		try
		{
			Git.Commit commit;
			Git.object_id oid;

			// get the oid fromthe file.
			string str = GitCore.uid("master");		

			Git.object_id.from_string( out oid, str);

			current_repository.lookup_commit( out commit, oid);
			
			return commit;
		}
		catch (CoreError e)
		{
			stderr.printf(e.message);
			return null;
		}
	}

	public static List<CommitInfo?> all_commits ( string branch )
	{
		List<CommitInfo?> commit_list = new List<CommitInfo?>();

		try
		{
			// Initialization
			string hex_oid;
			Git.Commit commit;
			Git.object_id oid;
			Structs.CommitInfo info;

			// Getting the string oid from the branch passed by parameter.
			hex_oid = GitCore.uid( branch );

			// Get the object_id
			Git.object_id.from_string( out oid, hex_oid);

			// Out the last commit.
			current_repository.lookup_commit( out commit, oid);
			
			// If it's nulls, then there are no more
			// Commits
			while( commit != null )
			{
				// Fill all the info into the struct.
				info = CommitInfo() {
					ci_id = commit.id,
					message = commit.message,
					author = commit.author.name,
					email = commit.author.email,
					time = commit.time,
					offset_time = commit.time_offset
				};

				commit_list.append( info );

				// Lookup for the next commit.
				commit.parents.lookup( out commit, 0);
			}

		} 
		catch( CoreError e) 
		{
			stderr.printf(e.message);
		}

		return commit_list;
	}

	/**
	 * Retrive the oid from the head.
	 */
	private string? uid (string branch) throws CoreError
	{

		// Some initialization

		string uid;
		string path_to_branch_file = "%s/refs/heads/%s".printf(current_repository.path,branch);
		try
		{
			FileUtils.get_contents( path_to_branch_file, out uid, null );
		}
		catch ( FileError e)
		{
			stderr.printf("Cannot take the HEAD uid form file %s\n", path_to_branch_file);
			throw new CoreError.INVALID_REPO_PATH(e.message);
		}	

		return uid;
	}
	
	/**
	 * Get the n three of the brach passed by parameter.
	 */
	private void get_nth_tree( out Git.Tree tree, ref uint depth, string branch )
	{
		Commit commit;
	
		// Get the commit list from the branch passed from parameter.
		List<CommitInfo?> commit_info = all_commits( branch );
		
		// this variable d must be an existing index of commit info.
		if( depth >= commit_info.length() )
			depth = commit_info.length() - 1 ;
		else if ( depth < 0 )
			depth = 0;
		
		assert( 0 <= depth && depth < commit_info.length() );
		
		// Get the oid of the commit to lookup
		Git.object_id commit_oid = commit_info.nth_data( depth ).ci_id;
		
		// lookup the commit
		current_repository.lookup_commit( out commit, commit_oid);
		
		// Get the tree
		commit.lookup_tree( out tree );
	}
	
	public static void foreach_file_in_tree( uint depth, string branch, TreeIterator t )
	{
		Git.Tree tree;
		get_nth_tree( out tree, ref depth, branch);
		
		tree.walk( Git.WalkMode.PRE, (r, e) => {
			GitFileInfo info = GitFileInfo() {
				parent = r,
				name = e.name,
				is_dir = e.attributes.is_dir()
			};
			
			t( info );
			return 0;
		});
	}
}// End of namespace GitCore
