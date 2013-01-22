using GitCore.Structs;

namespace Utils 
{
	public class HashFiles 
	{
		// Attributes
		public string name{ public get; private set;}
		public List<HashFiles?> childrens;

		/**
		 * constructor
		 */
		public HashFiles ( string name )
		{
			this.name = name;
			this.childrens = new List<HashFiles?>();
		}
		
		/**
		 * Just like Glib.List.lookup() but with the diference that
		 * this method do it recursibly.
		 */
		 public HashFiles? lookup_r ( string n, List<HashFiles?>? l )
		 {
		 
		 	// Check if the name that we are searching is this. in this way,
		 	// we avoid all the other things.
		 	if ( this.name == n )
		 		return this;
		 	HashFiles? finded;
		 	
		 	// Lookup for the key wherever we need, toplevel or in the list 
		 	if ( l == null )
		 		finded = find_in_hashfile_list ( childrens, n );
		 	else
		 		finded = find_in_hashfile_list ( l, n );
		 	
		 	// if we didnt find anything, then we begin the recursion.
		 	if ( finded == null )
		 	{
		 		for( uint i = 0; i < l.length() ; i++ )
		 		{
		 			HashFiles hf = l.nth_data(i);
		 			if ( ! hf.is_file() )
		 				return lookup_r ( n, hf.childrens );
		 		}
		 		
		 	}
		 	else
		 		return finded;
		 	
		 	return null;
		 }
				
		/**
		 * Returns true if this is a file
		 */
		public bool is_file ()
		{
			return childrens.length() == 0;
		}
		
		public void debug( string? tab = "|" )
		{
			stdout.printf("%s%s\n", tab, this.name);
			
			string new_tab = tab;
			
			childrens.foreach((hf) => {
				if( ! hf.is_file() )
					new_tab = tab.concat( "\t");
				hf.debug( new_tab );
				stdout.printf("\n");
			});
		}
		
	}
	
	HashFiles? find_in_hashfile_list ( List<HashFiles?> list, string what )
	{
		for( uint i = 0; i < list.length() ; i++ )
		{
			HashFiles hf = list.nth_data(i);
			if ( hf.name == what )
				return hf;
		}
		
		return null;
	}
	
	public HashFiles create_hashfile_tree ( GitFileList file_list )
	{
		// Create a hash_files to the root.
		string parent = "";
		uint parent_length = 0;
		HashFiles hash_files = new HashFiles( parent );
		HashFiles aux,children;
		GitFileInfo info;
		
		
		// Sort the list.
		file_list.sort();
		
		for ( uint i = 0; i < file_list.files.length() -1 ; i++ )
		{
			info = file_list.files.nth_data(i);
			children = new HashFiles( info.name );
			
			parent_length = info.parent.length;
			parent = parent[ 0:parent_length - 1 ];
			aux = hash_files.lookup_r ( parent , null );
			
			if ( aux == null )
				hash_files.childrens.append( children );
			else
				aux.childrens.append( children );
		}
		
		hash_files.debug();
		
		return hash_files;
		
	}
	
	public int intcmp (int a, int b)
	{
		return (int) (a > b) - (int) (a < b);
	}
	
} // end of namespace Utils
