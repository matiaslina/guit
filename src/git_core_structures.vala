namespace GitCore.Structs
{
	errordomain CoreError
	{
		INVALID_REPO_PATH,
		NULL_COMMIT,
		NULL_TREE,
	}
	/**
	 * StringIterator. This delegate takes a string
	 * to iter over some list, array, or somethings
	 * like that.
	 */
	public delegate void StringIterator( string s );
	public delegate void TreeIterator ( GitFileInfo i );

	//Struct with the info of the commit.
	public struct CommitInfo
	{
		public Git.object_id ci_id;
		public string message;
		public string author;
		public string email;
		public int64 time;
		public int offset_time;
	}
	
	public struct GitFileInfo
	{
		public string parent;
		public string name;
		public bool is_dir;
	}
	
	public class GitFileList
	{
		public List<GitFileInfo?> files;
		
		/**
		 * Constructor
		 */
		public GitFileList ()
		{
			files 	= new List<GitFileInfo?>();
		}

		private void clear_list ()
		{
			this.files = null;
			this.files = new List<GitFileInfo?>();
		}

		public void load_list( uint depth, string branch )
		{
			this.clear_list();
			foreach_file_in_tree( depth, branch, ( info ) => {
					this.files.append( info );
				}
			);
			//debug_list();
		}
		
		public void sort()
		{
			this.files.sort( parentcmp );
		}
		
		/**
		 * Function that compares the parents to sort the list.
		 */
		private CompareFunc<GitFileInfo?> parentcmp = ( a, b ) => {
			return Utils.intcmp( a.parent.length, b.parent.length );
		};
			

		/**
		 * Just a function for debug the list
		 */
		public void debug_list () 
		{
			this.files.foreach ( ( info ) => {
				stdout.printf ( "parent: %s\n name: %s\n", info.parent, info.name );
			});
		}	
	}

}
