using Gtk;
using Configuration;

namespace Guit.Preferences
{
	/**
	 * Just a dialog to Add or edit the repositories on
	 * the click on some buttons. This dialog have only
	 * a name for the repo, and the path.
	 */
	
	public class RepoDialog : Gtk.Dialog
	{
		
		private Status current_status;
		
		private Gtk.Entry t_repository_name;
		private Gtk.Entry t_repository_path;
		
		/**
		 * Consturctor.
		 * The parameter may be null because this set if we're
		 * editing or creating a repository.
		 */
		public RepoDialog ( Status status )
		{
			
			set_keep_above(true);
			this.current_status = status;
							
			// Container
			Gtk.Box this_container = get_content_area() as Gtk.Box;
			
			
			// Creating some elements
			Label l_name = new Label("Name:");
			Label l_path = new Label("Path:");
			t_repository_path = new Entry();
			t_repository_name = new Entry();
			
			// Pack all in the main container
			this_container.pack_start(l_name,false, false, 0);
			this_container.pack_start(t_repository_name, true,true, 0);
			this_container.pack_start(l_path, false, false, 0);
			this_container.pack_start(t_repository_path , true, true, 0);
			
			// Adds two buttons.
			add_button(Gtk.Stock.OK, Gtk.ResponseType.OK);
			add_button(Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
			
			// We connect some signals in a separated function
			this.connect_signals();
			
		}
		
		private void connect_signals()
		{
			response.connect( on_response );
		}
		
		private void on_response(Gtk.Dialog source, int response_id)
		{
			switch( response_id )
			{
				case Gtk.ResponseType.OK:
					// Do some save information.
					
					// Add the repo to the configuration
					Repos.add_repository( t_repository_name.get_text(), t_repository_path.get_text());
					
					// Set the entries to nothing.
					t_repository_name.set_text("");
					t_repository_path.set_text("");
					
					if( current_status == Status.EDITING_REPO)
						t_repository_name.set_sensitive( true );
						
					//this.hide_all();
					break;
				case Gtk.ResponseType.CANCEL:
					//this.hide_all();
					break;
			}
		}
		
		public void show_this_dialog()
		{
			show_all();
		}
		
		public void set_editing( string repository_name)
		{
			// That the repo name it's null means that we're
			// creating a new repository form a path
			t_repository_name.set_sensitive(false);
			t_repository_name.set_text( repository_name );
			t_repository_path.set_text(Repos.get_info( repository_name, "path" ));
			
		}
	}
	
}
