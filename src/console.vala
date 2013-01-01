using Gtk;
using Configuration;

namespace Windows
{
	public static Console console;

	public static void create_console ()
	{
		console = new Console ();
	}

	public class Console : Gtk.Window
	{
		
		private ScrolledWindow log_container;
		private TextView log;

		private Entry command_line;

		private string repository;

		public Console ()
		{
			// Some visual preferences.
			this.title = "Git console";
			this.set_default_size( 500, 300 );
			this.set_deletable ( false );
			
			string[] active_groups = Repos.get_groups();
			
			foreach ( string g in active_groups )
			{
				if ( Repos.get_active( g ) )
				{
					this.repository = g;
					break;
				}
			}

			this.create_widgets( );
			this.connect_signals( );
		}

		private void create_widgets ()
		{
			// Main container of the console.
			Gtk.Box box = new Gtk.Box( Gtk.Orientation.VERTICAL, 1 );
			this.add( box );

			// Console log.
			log_container = new ScrolledWindow( null, null );
			log_container.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC);
			
			log = new TextView();
			
			// Gonna set some configuration on the log console. ( just visual )
			log.set_wrap_mode( Gtk.WrapMode.WORD );
			log.set_cursor_visible ( false );
			log.set_editable ( false );
			
			// pack the log info into a scrolled window.
			log_container.add ( log );

			// Where we put the commands.
			command_line = new Entry ();

			box.pack_start( log_container, true, true, 0 );
			box.pack_start( command_line, false, false, 0 );
			
			box.show_all ();
		}

		private void connect_signals ()
		{
			// On destroy.
			this.destroy.connect ( () => {
				stdout.printf("Bye. Console is out\n");
			});

			// KeyPressed
			this.key_press_event.connect ( on_key_press );

			// Text Changed
			log.size_allocate.connect ( () => {
				// Scroll the log_container to the bottom
				Adjustment adj = log_container.get_vadjustment ();
				log_container.vadjustment.value = adj.upper - adj.page_size;
			});
		}

		public void change_repository ( string name, string path )
		{
			this.repository = name;
			console.new_line ( "Changed to %s repository.".printf( name ), true );
		}

		public void toggle ()
		{
			if ( this.get_visible() )
				set_no_show_all (true);
			else
				this.show_all ();
		}

		private bool on_key_press ( Gtk.Widget source, Gdk.EventKey key )
		{
			switch ( key.keyval )
			{
				case Gdk.Key.F9:
					if ( get_visible () )
						this.set_visible ( false );
					else
						show_all();
					break;
				case Gdk.Key.Return:
					// Concatenate the previous string with the new command.
					new_line ( command_line.get_text(), true );

					write_on_log_view ();

					// Clear the input
					command_line.set_text("");
					break;
			}

			return false;
		}

		public void new_line ( string line , bool needs_linebreak = false )
		{
			string buffer_string;
			string log_text = log.buffer.text;
			if ( needs_linebreak )
				buffer_string = log_text.concat ( this.repository,"  ~> " , line, "\n" );
			else
				buffer_string = log_text.concat ( line );

			this.log.buffer.text = buffer_string;
		}

		/**
		 * Parse an input to get an array of string with
		 * the commands for the git command.
		 *
		 * ex1:
		 * 	input 	-> commit -m "Initial commit"
		 *	output 	-> { "git", "commit","-m", "\"Initial commit\"" }
		 *
		 * ex2:
		 *	input 	-> push -u origin master
		 *	output	-> { "git", "push", "-u", "origin", "master" }
		 */
		public string[] parse_input ( string input )
		{
			// Gonna make this later.
			return { "git" };	
		}		

		private void write_on_log_view ()
		{
			MainLoop loop = new MainLoop ();
			try 
			{
				string[] spawn_args = {"git"}; 
				string[] message_split = this.command_line.get_text().split(" \"");
				string[] commands_args = message_split[0].split(" ");

				foreach ( string s in commands_args)
				{
					spawn_args += s;
				}
				spawn_args += message_split[1];

				foreach ( string s in spawn_args )
				{
					stdout.printf("%s\n",s);
				}
				
				string[] spawn_env = Environ.get();
				Pid child_pid;

				int standard_input;
				int standard_output;
				int standard_error;

				Process.spawn_async_with_pipes(
						Repos.get_info( this.repository, "path" ),
						spawn_args,
						spawn_env,
						SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
						null,
						out child_pid,
						out standard_input,
						out standard_output,
						out standard_error
					);

				// Stdout
				IOChannel output = new IOChannel.unix_new ( standard_output);
				output.add_watch ( IOCondition.IN | IOCondition.HUP, ( channel, condition ) => {

						if ( condition == IOCondition.HUP )
						{
							return false;
						}

						try
						{
							string line;
							channel.read_line ( out line, null, null );

							new_line ( line );
						}
						catch ( IOChannelError e) 
						{
							stdout.printf("IOChannelError %s\n", e.message );
							return false;
						}
						catch ( ConvertError e )
						{
							stdout.printf("ConvertError: %s\n", e.message );
							return false;
						}



						return true;
				});

				// Stderr
				IOChannel error = new IOChannel.unix_new ( standard_error );
				error.add_watch ( IOCondition.IN | IOCondition.HUP, ( channel, condition ) => {
						if ( condition == IOCondition.HUP )
						{
							return false;
						}

						try
						{
							string line;
							channel.read_line ( out line, null, null );

							new_line ( line ) ;
						}
						catch ( IOChannelError e) 
						{
							stderr.printf("IOChannelError %s\n", e.message );
							return false;
						}
						catch ( ConvertError e )
						{
							stderr.printf("ConvertError: %s\n", e.message );
							return false;
						}

						return true;
				});

				ChildWatch.add( child_pid, (pid, status ) => {
						Process.close_pid ( pid );
						loop.quit();
					});
				
				loop.run();
			}
			catch ( SpawnError e )
			{
				stdout.printf("SpawnError e" );
			}
		}


	} // End of console class
}
