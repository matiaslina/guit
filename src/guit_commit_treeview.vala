/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

using Gtk;
using GitCore;

namespace Guit.Widgets
{
	public class CommitTree : Gtk.TreeView
	{
		public CommitTree( string? branch )
		{

			this.set_headers_visible( false );

			if ( branch == null )
				branch = "master";

			load_commit_list( branch );				
			
			// Columns
			TreeViewColumn column = new TreeViewColumn();
			column.set_title("");
			
			// Config of the cells
			CellRendererText cell;
			
			cell = new CellRendererText();
			column.pack_start(cell, true);
			column.add_attribute(cell, "text", 0);

			this.append_column(column);

		}
		
		public void load_commit_list( string branch )
		{
			uint i;
			

			Gtk.TreeIter iter; 
			Gtk.ListStore store = new Gtk.ListStore(2, typeof(string), typeof(string));
			List<Structs.CommitInfo?> commit_info = GitCore.all_commits( branch );



			for( i = 0 ; i < commit_info.length(); i++)
			{
				string text = "";
				string time_str = "";
				// Time
				time_t ts = (time_t) commit_info.nth_data(i).time;
				var t = Time.gm ( ts );
				time_str = "%s %s".printf(t.format("%b %d, %Y").to_string(), t.format("%H:%M").to_string());
				
				// Author and commit
				text = "%s\t\t%s\n%s".printf(commit_info.nth_data(i).author,time_str, commit_info.nth_data(i).message);

				store.append( out iter );
				store.set(iter, 0, text);
				
				
			}
			
			this.set_model( store );

		}
	} // End of CommitTree class
}
