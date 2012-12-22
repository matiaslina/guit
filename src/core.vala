using Git;
using Gtk;

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

			// Just for debug.
			stdout.printf("Debug: uid --> %s\n", str);
			stdout.printf("Author: %s (%s)\nMessage: %s\n", commit.author.name, commit.author.email, commit.message);

			return commit;
		}
		catch (CoreError e)
		{
			stderr.printf(e.message);
			return null;
		}
	}

	public static List<CommitInfo?>
	all_commits ()
	{
		List<CommitInfo?> commit_list = new List<CommitInfo?>();

		try
		{
			string hex_oid;
			Git.Commit commit;
			Git.object_id oid;
			GitCore.CommitInfo info;

			hex_oid = GitCore.uid("master");

			Git.object_id.from_string( out oid, hex_oid);

			current_repository.lookup_commit( out commit, oid);
			
			while( commit != null )
			{
				// Fill all the usefull info.
				info = CommitInfo() {
					message = commit.message,
					author = commit.author.name,
					email = commit.author.email,
					time = commit.time,
					offset_time = commit.time_offset
				};
				commit_list.append( info );

				oid = commit.parents.get(0);

				current_repository.lookup_commit( out commit, oid);
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


