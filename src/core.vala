using Git;

namespace GitCore {

	errordomain CoreError
	{
		INVALID_REPO_PATH,
		NULL_COMMIT,
	}
	/**
	 * StringIterator. This delegate takes a string
	 * to iter over some list, array, or somethings
	 * like that.
	 */
	public delegate void StringIterator( string s );

	//Struct with the info of the commit.
	public struct CommitInfo
	{
		public string message;
		public string author;
		public string email;
		public int64 time;
		public int offset_time;
	}

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

	public static Commit?
	last_commit ()
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

	public static List<CommitInfo?>
	all_commits ( string branch )
	{
		List<CommitInfo?> commit_list = new List<CommitInfo?>();

		try
		{
			// Initialization
			string hex_oid;
			Git.Commit commit;
			Git.object_id oid;
			GitCore.CommitInfo info;

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
	private string? 
	uid (string branch) throws CoreError
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
	
}

