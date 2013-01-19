using Gtk;

namespace Console.Callback
{
	bool on_console_key_press ( Gtk.Widget source, Gdk.EventKey key )
	{
		switch ( key.keyval )
		{
			case Gdk.Key.F9:
				if ( console.get_visible () )
					console.set_visible ( false );
				else
					console.show_all();
				break;
			case Gdk.Key.Return:
				// Concatenate the previous string with the new command.
				console.new_line_from_command_line();
				break;
		}

		return false;
	}
}
