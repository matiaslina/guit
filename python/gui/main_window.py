# Imports
import pygtk
pygtk.require('2.0')
import gtk, os
import webkit

# For config file
import lib.config as config
# Render the markdown on the webview
import markdown


# Constants
GIT_REPO = "/home/matias/guanadoo"

def delete_event(widget,event,data=None):
	gtk.main_quit()
	return False

class MainWindow:
	"""Main window for app"""
	def __init__(self):
		
		self._Gui()
		self._Connecting()
		print self._Validations()
			
	def _Gui(self):

		# Window attributes
		
		self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		self.window.set_title("Git Gui")
		self.window.set_size_request(640,480)
		
		# menu container
		self.menu_container = gtk.VBox(False , 0)
		
		# ---------- Menu --------------------- #
		mb = gtk.MenuBar()
		
		filemenu = gtk.Menu()
		filem = gtk.MenuItem("File")
		filem.set_submenu(filemenu)
		
		self.preferences = gtk.MenuItem("Preferences")
		filemenu.append(self.preferences)
		
		separator = gtk.SeparatorMenuItem()
		filemenu.append(separator)
		
		self.exit = gtk.MenuItem("Exit")
		filemenu.append(self.exit)
		
		mb.append(filem)
			
		
		# Main container
		self.main_horizontal_box = gtk.HBox(False, 0)

		# Webview
		self.webview = webkit.WebView()

		# Buttons container
		self.button_box = gtk.VBox(False, 0)

		# Buttons
		self.view_readme_btn = gtk.Button("View readme")
		self.view_licence_btn = gtk.Button("View licence")
		self.view_todo_btn = gtk.Button("View to do")

		
		# Packaging
		self.button_box.pack_start(self.view_readme_btn,False,False,0)
		self.button_box.pack_start(self.view_licence_btn,False,True,0)
		self.button_box.pack_start(self.view_todo_btn,False,True,0)
		
		self.main_horizontal_box.pack_start(self.button_box,True,True,0)
		self.main_horizontal_box.pack_start(self.webview,True,True,0)
		self.menu_container.pack_start(mb, False, False,0)
		self.menu_container.pack_start(self.main_horizontal_box,False,False,0)
		self.window.add(self.menu_container)

		self.window.show_all()

	def _Connecting(self):
		# Closing the window
		self.window.connect("delete_event", delete_event)
		
		# Exit button
		self.exit.connect("activate", gtk.main_quit)
		
		self.view_readme_btn.connect('clicked', self._load_file_on_webview, 'readme')
		self.view_licence_btn.connect('clicked',self._load_file_on_webview, 'licence')	
		
	def _Validations(self):
		conf_files = config.get_existing_static_files()
		
		for f in conf_files:
			exists = file_exist(f)
			
			if (f == 'README') and (not exists):
				self.view_readme_btn.set_sensitive(False)
			elif (f == 'LICENCE') and (not exists):
				self.view_licence_btn.set_sensitive(False)
			elif (f == 'TODO') and (not exists):
				self.view_todo_btn.set_sensitive(False)
				
		
		
		
	def _load_file_on_webview(self, widget,data=None):
		exists, html = get_html_from_file(data)
		if exists:
			self.webview.load_html_string( html, 'file:///' )
				
				
#---------------------------------------#
#			Just remove this 			#
#---------------------------------------#

def get_html_from_file( archive ):
	try:
		# get the archive from conf
		conf_file = config.get_configuration('StaticFiles', archive )
	
		# get a list for possibles archives.
		files = [ f for f in os.listdir(GIT_REPO) if f.startswith(conf_file)]
		if len(files) > 0:
			with open(GIT_REPO + '/' + files[0], 'r') as f: 
				html = (True, markdown.markdown(f.read()))
		else:
			html = (False, '')
	# 
	except:
		html = '<p>Error: {0} doesnt set in configuration file</p>'	
	
	return html

def file_exist(archive):
	
	try:
		files = [f for f in os.listdir(GIT_REPO) if f.startswith(archive)]
		if len(files) > 0:
			return True
	except:
		print "Error: {0} doesn't exist in conf file'".format(archive)
	
	return False

if __name__ == '__main__':
	MainWindow()
	gtk.main()
