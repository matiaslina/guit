namespace Utils 
{
	class HashFiles 
	{
		// Attributes
		string name;
		HashFiles[]? childrens;

		/**
		 * constructor
		 */
		public HashFiles ( string name, HashFiles[]? childrens )
		{
			this.name = name;
			this.childrens = childrens;
		}
		
		public load_from_list ( List<FileInfo?> l )
		{
			string last_parent = "";
			
			// Lets sort the list.
			l.sort();
			
			for( int i = 0; i < l.length() ; i++ )
			{
				this.name = l.nth_data(i).name;
				
			}
		}
		
		/**
		 * Returns true if this is a file
		 */
		public bool is_file ()
		{
			return ( childrens == null || childrens.length == 0 );
		}
		
	}
} // end of namespace Utils
