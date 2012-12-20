using Git;
using Gtk;

namespace GitCore {

	errordomain InvalidRepositoryError
	{
		INVALID_REPO_PATH,
	}
	
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

	public static Commit?
	last_commit ()
	{
		try
		{
			string str = GitCore.uid("master");
			uint parents, p;

			Git.Commit commit;
			Git.object_id oid;

			Git.object_id.from_string( out oid, str);

			current_repository.lookup_commit( out commit, oid);

			// Just for debug.
			stdout.printf("Debug: uid --> %s\n", str);
			stdout.printf("Author: %s (%s)\nMessage: %s\n", commit.author.name, commit.author.email, commit.message);

			return commit;
		}
		catch (InvalidRepositoryError e)
		{
			stderr.printf(e.message);
			return null;
		}

		
	}

	private string? 
	uid (string branch) throws InvalidRepositoryError
	{
		string uid;
		string path_to_branch_file = "%s/refs/heads/%s".printf(current_repository.path,branch);
		try
		{
			FileUtils.get_contents( path_to_branch_file, out uid, null );
		}
		catch ( FileError e)
		{
			stderr.printf("Cannot take the HEAD uid form file %s\n", path_to_branch_file);
			throw new InvalidRepositoryError.INVALID_REPO_PATH(e.message);
		}

		return uid;
	}
	
}


