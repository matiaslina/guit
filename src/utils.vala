namespace Utils 
{
	class HashFiles 
	{
		// Attributes
		public string name;
		public HashFiles[]? childrens;

		/**
		 * constructor
		 */
		public HashFiles ( string name, HashFiles[]? childrens )
		{
			this.name = name;
			this.childrens = childrens;
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
