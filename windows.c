/* windows.c generated by valac, the Vala compiler
 * generated from windows.vala, do not modify */

/*
	@author: Matias Linares
	@email: matiaslina@gmail.com
*/

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>
#include <webkit/webkit.h>
#include <gio/gio.h>
#include <stdio.h>

#define _g_free0(var) (var = (g_free (var), NULL))

#define WINDOWS_TYPE_MAIN_WINDOW (windows_main_window_get_type ())
#define WINDOWS_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), WINDOWS_TYPE_MAIN_WINDOW, WindowsMainWindow))
#define WINDOWS_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), WINDOWS_TYPE_MAIN_WINDOW, WindowsMainWindowClass))
#define WINDOWS_IS_MAIN_WINDOW(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), WINDOWS_TYPE_MAIN_WINDOW))
#define WINDOWS_IS_MAIN_WINDOW_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), WINDOWS_TYPE_MAIN_WINDOW))
#define WINDOWS_MAIN_WINDOW_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), WINDOWS_TYPE_MAIN_WINDOW, WindowsMainWindowClass))

typedef struct _WindowsMainWindow WindowsMainWindow;
typedef struct _WindowsMainWindowClass WindowsMainWindowClass;
typedef struct _WindowsMainWindowPrivate WindowsMainWindowPrivate;

#define WINDOWS_WIDGET_TYPE_FILE_TREE (windows_widget_file_tree_get_type ())
#define WINDOWS_WIDGET_FILE_TREE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), WINDOWS_WIDGET_TYPE_FILE_TREE, WindowsWidgetFileTree))
#define WINDOWS_WIDGET_FILE_TREE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), WINDOWS_WIDGET_TYPE_FILE_TREE, WindowsWidgetFileTreeClass))
#define WINDOWS_WIDGET_IS_FILE_TREE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), WINDOWS_WIDGET_TYPE_FILE_TREE))
#define WINDOWS_WIDGET_IS_FILE_TREE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), WINDOWS_WIDGET_TYPE_FILE_TREE))
#define WINDOWS_WIDGET_FILE_TREE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), WINDOWS_WIDGET_TYPE_FILE_TREE, WindowsWidgetFileTreeClass))

typedef struct _WindowsWidgetFileTree WindowsWidgetFileTree;
typedef struct _WindowsWidgetFileTreeClass WindowsWidgetFileTreeClass;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _gtk_tree_path_free0(var) ((var == NULL) ? NULL : (var = (gtk_tree_path_free (var), NULL)))
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))

#define WINDOWS_TYPE_PREFERENCES (windows_preferences_get_type ())
#define WINDOWS_PREFERENCES(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), WINDOWS_TYPE_PREFERENCES, WindowsPreferences))
#define WINDOWS_PREFERENCES_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), WINDOWS_TYPE_PREFERENCES, WindowsPreferencesClass))
#define WINDOWS_IS_PREFERENCES(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), WINDOWS_TYPE_PREFERENCES))
#define WINDOWS_IS_PREFERENCES_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), WINDOWS_TYPE_PREFERENCES))
#define WINDOWS_PREFERENCES_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), WINDOWS_TYPE_PREFERENCES, WindowsPreferencesClass))

typedef struct _WindowsPreferences WindowsPreferences;
typedef struct _WindowsPreferencesClass WindowsPreferencesClass;
typedef struct _WindowsPreferencesPrivate WindowsPreferencesPrivate;

struct _WindowsMainWindow {
	GtkWindow parent_instance;
	WindowsMainWindowPrivate * priv;
};

struct _WindowsMainWindowClass {
	GtkWindowClass parent_class;
};

struct _WindowsMainWindowPrivate {
	GtkVBox* main_box;
	GtkHPaned* main_pane;
	GtkMenuBar* bar;
	GtkMenuItem* file_menu;
	GtkMenuItem* exit_menu;
	GtkVBox* tree_view_container;
	GtkLabel* tree_view_title;
	GtkScrolledWindow* scrolled_window_files;
	WindowsWidgetFileTree* tree_view;
	GtkScrolledWindow* scrolled_window_webview;
	WebKitWebView* web_view;
};

struct _WindowsPreferences {
	GtkDialog parent_instance;
	WindowsPreferencesPrivate * priv;
};

struct _WindowsPreferencesClass {
	GtkDialogClass parent_class;
};

struct _WindowsPreferencesPrivate {
	GtkEntry* repo_dir;
};


static gpointer windows_main_window_parent_class = NULL;
static gpointer windows_preferences_parent_class = NULL;

char* windows_crearDom (const char* code);
GType windows_main_window_get_type (void);
GType windows_widget_file_tree_get_type (void);
#define WINDOWS_MAIN_WINDOW_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), WINDOWS_TYPE_MAIN_WINDOW, WindowsMainWindowPrivate))
enum  {
	WINDOWS_MAIN_WINDOW_DUMMY_PROPERTY
};
#define WINDOWS_MAIN_WINDOW_TITLE "Git Gui"
static void windows_main_window_create_widgets (WindowsMainWindow* self);
static void windows_main_window_connect_signals (WindowsMainWindow* self);
WindowsMainWindow* windows_main_window_new (void);
WindowsMainWindow* windows_main_window_construct (GType object_type);
WindowsWidgetFileTree* windows_widget_file_tree_new (void);
WindowsWidgetFileTree* windows_widget_file_tree_construct (GType object_type);
static void _gtk_main_quit_gtk_object_destroy (GtkObject* _sender, gpointer self);
static void _gtk_main_quit_gtk_menu_item_activate (GtkMenuItem* _sender, gpointer self);
void windows_main_window_load_file_in_webview (WindowsMainWindow* self);
static void _windows_main_window_load_file_in_webview_gtk_tree_view_cursor_changed (GtkTreeView* _sender, gpointer self);
const char* windows_widget_file_tree_get_repo_path (WindowsWidgetFileTree* self);
static char* windows_main_window_get_selected_path (WindowsMainWindow* self);
static void windows_main_window_finalize (GObject* obj);
GType windows_preferences_get_type (void);
#define WINDOWS_PREFERENCES_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), WINDOWS_TYPE_PREFERENCES, WindowsPreferencesPrivate))
enum  {
	WINDOWS_PREFERENCES_DUMMY_PROPERTY
};
WindowsPreferences* windows_preferences_new (void);
WindowsPreferences* windows_preferences_construct (GType object_type);
static void windows_preferences_finalize (GObject* obj);
static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func);
static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func);
static gint _vala_array_length (gpointer array);



char* windows_crearDom (const char* code) {
	char* result = NULL;
	char* _tmp0_;
	char* _tmp1_;
	g_return_val_if_fail (code != NULL, NULL);
	result = (_tmp1_ = g_strconcat (_tmp0_ = g_strconcat ("\n" \
"\t\t\t<html>\n" \
"\t\t\t<head>\n" \
"\t\t\t<meta http-equiv=\"Content-type\" content=\"text/html; charset=u" \
"tf-8\" />\n" \
"\t\t\t<link href=\"/home/matias/workspace/linux-git-gui/vala/webview-c" \
"ontent/prettify/prettify.css\" type=\"text/css\" rel=\"stylesheet\" />" \
"\n" \
"\t\t\t<script type=\"text/javascript\" src=\"/home/matias/workspace/li" \
"nux-git-gui/vala/webview-content/prettify/prettify.js\"></script>\n" \
"\t\t\t<script type=\"text/javascript\"></script>\n" \
"\t\t\t</head>\n" \
"\t\t\t<body onload=\"prettyPrint();\">\n" \
"\t\t\t<pre id=\"myCode\" class=\"prettyprint\">", code, NULL), "</pre>\n\t\t\t</body>\n\t\t\t</html>\n\t\t\t", NULL), _g_free0 (_tmp0_), _tmp1_);
	return result;
}


WindowsMainWindow* windows_main_window_construct (GType object_type) {
	WindowsMainWindow * self;
	self = g_object_newv (object_type, 0, NULL);
	gtk_window_set_default_size ((GtkWindow*) self, 800, 600);
	windows_main_window_create_widgets (self);
	windows_main_window_connect_signals (self);
	gtk_widget_show_all ((GtkWidget*) self);
	return self;
}


WindowsMainWindow* windows_main_window_new (void) {
	return windows_main_window_construct (WINDOWS_TYPE_MAIN_WINDOW);
}


static void windows_main_window_create_widgets (WindowsMainWindow* self) {
	GtkMenuBar* _tmp0_;
	GtkMenuItem* _tmp1_;
	GtkMenu* file_submenu;
	GtkMenuItem* _tmp2_;
	GtkVBox* _tmp3_;
	GtkHPaned* _tmp4_;
	GtkScrolledWindow* _tmp5_;
	GtkVBox* _tmp6_;
	GtkScrolledWindow* _tmp7_;
	GtkLabel* _tmp8_;
	WindowsWidgetFileTree* _tmp9_;
	WebKitWebView* _tmp10_;
	g_return_if_fail (self != NULL);
	gtk_window_set_title ((GtkWindow*) self, WINDOWS_MAIN_WINDOW_TITLE);
	g_object_set ((GtkWindow*) self, "window-position", GTK_WIN_POS_CENTER, NULL);
	gtk_container_set_border_width ((GtkContainer*) self, (guint) 0);
	self->priv->bar = (_tmp0_ = g_object_ref_sink ((GtkMenuBar*) gtk_menu_bar_new ()), _g_object_unref0 (self->priv->bar), _tmp0_);
	self->priv->file_menu = (_tmp1_ = g_object_ref_sink ((GtkMenuItem*) gtk_menu_item_new_with_label ("File")), _g_object_unref0 (self->priv->file_menu), _tmp1_);
	gtk_container_add ((GtkContainer*) self->priv->bar, (GtkWidget*) self->priv->file_menu);
	file_submenu = g_object_ref_sink ((GtkMenu*) gtk_menu_new ());
	gtk_menu_item_set_submenu (self->priv->file_menu, (GtkWidget*) file_submenu);
	self->priv->exit_menu = (_tmp2_ = g_object_ref_sink ((GtkMenuItem*) gtk_menu_item_new_with_label ("Exit")), _g_object_unref0 (self->priv->exit_menu), _tmp2_);
	gtk_container_add ((GtkContainer*) file_submenu, (GtkWidget*) self->priv->exit_menu);
	self->priv->main_box = (_tmp3_ = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 0)), _g_object_unref0 (self->priv->main_box), _tmp3_);
	self->priv->main_pane = (_tmp4_ = g_object_ref_sink ((GtkHPaned*) gtk_hpaned_new ()), _g_object_unref0 (self->priv->main_pane), _tmp4_);
	gtk_paned_set_position ((GtkPaned*) self->priv->main_pane, 200);
	self->priv->scrolled_window_files = (_tmp5_ = g_object_ref_sink ((GtkScrolledWindow*) gtk_scrolled_window_new (NULL, NULL)), _g_object_unref0 (self->priv->scrolled_window_files), _tmp5_);
	gtk_scrolled_window_set_policy (self->priv->scrolled_window_files, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
	self->priv->tree_view_container = (_tmp6_ = g_object_ref_sink ((GtkVBox*) gtk_vbox_new (FALSE, 3)), _g_object_unref0 (self->priv->tree_view_container), _tmp6_);
	self->priv->scrolled_window_webview = (_tmp7_ = g_object_ref_sink ((GtkScrolledWindow*) gtk_scrolled_window_new (NULL, NULL)), _g_object_unref0 (self->priv->scrolled_window_webview), _tmp7_);
	gtk_scrolled_window_set_policy (self->priv->scrolled_window_webview, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
	self->priv->tree_view_title = (_tmp8_ = g_object_ref_sink ((GtkLabel*) gtk_label_new_with_mnemonic ("Files.")), _g_object_unref0 (self->priv->tree_view_title), _tmp8_);
	self->priv->tree_view = (_tmp9_ = g_object_ref_sink (windows_widget_file_tree_new ()), _g_object_unref0 (self->priv->tree_view), _tmp9_);
	gtk_container_add ((GtkContainer*) self->priv->scrolled_window_files, (GtkWidget*) self->priv->tree_view);
	gtk_box_pack_start ((GtkBox*) self->priv->tree_view_container, (GtkWidget*) self->priv->tree_view_title, FALSE, FALSE, (guint) 3);
	gtk_box_pack_start ((GtkBox*) self->priv->tree_view_container, (GtkWidget*) self->priv->scrolled_window_files, TRUE, TRUE, (guint) 0);
	self->priv->web_view = (_tmp10_ = g_object_ref_sink ((WebKitWebView*) webkit_web_view_new ()), _g_object_unref0 (self->priv->web_view), _tmp10_);
	gtk_container_add ((GtkContainer*) self->priv->scrolled_window_webview, (GtkWidget*) self->priv->web_view);
	gtk_paned_pack1 ((GtkPaned*) self->priv->main_pane, (GtkWidget*) self->priv->tree_view_container, TRUE, FALSE);
	gtk_paned_pack2 ((GtkPaned*) self->priv->main_pane, (GtkWidget*) self->priv->scrolled_window_webview, TRUE, TRUE);
	gtk_box_pack_start ((GtkBox*) self->priv->main_box, (GtkWidget*) self->priv->bar, FALSE, FALSE, (guint) 0);
	gtk_box_pack_start ((GtkBox*) self->priv->main_box, (GtkWidget*) self->priv->main_pane, TRUE, TRUE, (guint) 0);
	gtk_container_add ((GtkContainer*) self, (GtkWidget*) self->priv->main_box);
	_g_object_unref0 (file_submenu);
}


static void _gtk_main_quit_gtk_object_destroy (GtkObject* _sender, gpointer self) {
	gtk_main_quit ();
}


static void _gtk_main_quit_gtk_menu_item_activate (GtkMenuItem* _sender, gpointer self) {
	gtk_main_quit ();
}


static void _windows_main_window_load_file_in_webview_gtk_tree_view_cursor_changed (GtkTreeView* _sender, gpointer self) {
	windows_main_window_load_file_in_webview (self);
}


static void windows_main_window_connect_signals (WindowsMainWindow* self) {
	g_return_if_fail (self != NULL);
	g_signal_connect ((GtkObject*) self, "destroy", (GCallback) _gtk_main_quit_gtk_object_destroy, NULL);
	g_signal_connect (self->priv->exit_menu, "activate", (GCallback) _gtk_main_quit_gtk_menu_item_activate, NULL);
	g_signal_connect_object ((GtkTreeView*) self->priv->tree_view, "cursor-changed", (GCallback) _windows_main_window_load_file_in_webview_gtk_tree_view_cursor_changed, self, 0);
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static char* windows_main_window_get_selected_path (WindowsMainWindow* self) {
	char* result = NULL;
	char* path;
	GtkTreePath* tree_path;
	GtkTreePath* _tmp1_;
	GtkTreePath* _tmp0_ = NULL;
	GtkTreeModel* model;
	char** _tmp3_;
	gint _path_items_size_;
	gint path_items_length1;
	char** _tmp2_;
	char** path_items;
	g_return_val_if_fail (self != NULL, NULL);
	path = g_strdup (windows_widget_file_tree_get_repo_path (self->priv->tree_view));
	tree_path = NULL;
	gtk_tree_view_get_cursor ((GtkTreeView*) self->priv->tree_view, &_tmp0_, NULL);
	tree_path = (_tmp1_ = _tmp0_, _gtk_tree_path_free0 (tree_path), _tmp1_);
	model = _g_object_ref0 (gtk_tree_view_get_model ((GtkTreeView*) self->priv->tree_view));
	path_items = (_tmp3_ = _tmp2_ = g_strsplit (gtk_tree_path_to_string (tree_path), ":", 0), path_items_length1 = _vala_array_length (_tmp2_), _path_items_size_ = path_items_length1, _tmp3_);
	{
		gint i;
		i = 0;
		{
			gboolean _tmp4_;
			_tmp4_ = TRUE;
			while (TRUE) {
				GValue val = {0};
				GtkTreeIter iter = {0};
				char* string_path;
				GtkTreePath* aux_tree_path;
				GValue _tmp9_;
				GValue _tmp8_ = {0};
				char* _tmp11_;
				char* _tmp10_;
				if (!_tmp4_) {
					i++;
				}
				_tmp4_ = FALSE;
				if (!(i < path_items_length1)) {
					break;
				}
				string_path = g_strdup ("");
				{
					gint j;
					j = 0;
					{
						gboolean _tmp5_;
						_tmp5_ = TRUE;
						while (TRUE) {
							char* _tmp6_;
							if (!_tmp5_) {
								j++;
							}
							_tmp5_ = FALSE;
							if (!(j <= i)) {
								break;
							}
							string_path = (_tmp6_ = g_strconcat (string_path, path_items[j], NULL), _g_free0 (string_path), _tmp6_);
							if (j != i) {
								char* _tmp7_;
								string_path = (_tmp7_ = g_strconcat (string_path, ":", NULL), _g_free0 (string_path), _tmp7_);
							}
						}
					}
				}
				aux_tree_path = gtk_tree_path_new_from_string (string_path);
				gtk_tree_model_get_iter (model, &iter, aux_tree_path);
				gtk_tree_model_get_value (model, &iter, 1, &_tmp8_);
				val = (_tmp9_ = _tmp8_, G_IS_VALUE (&val) ? (g_value_unset (&val), NULL) : NULL, _tmp9_);
				path = (_tmp11_ = g_strconcat (path, _tmp10_ = g_strconcat ("/", g_value_get_string (&val), NULL), NULL), _g_free0 (path), _tmp11_);
				_g_free0 (_tmp10_);
				G_IS_VALUE (&val) ? (g_value_unset (&val), NULL) : NULL;
				_g_free0 (string_path);
				_gtk_tree_path_free0 (aux_tree_path);
			}
		}
	}
	result = path;
	_gtk_tree_path_free0 (tree_path);
	_g_object_unref0 (model);
	path_items = (_vala_array_free (path_items, path_items_length1, (GDestroyNotify) g_free), NULL);
	return result;
}


void windows_main_window_load_file_in_webview (WindowsMainWindow* self) {
	GError * _inner_error_;
	GCancellable* cancellable;
	char* code;
	char* _tmp11_;
	g_return_if_fail (self != NULL);
	_inner_error_ = NULL;
	cancellable = NULL;
	code = g_strdup ("");
	{
		char* _tmp0_;
		GFile* _tmp1_;
		GFile* file;
		file = (_tmp1_ = g_file_new_for_path (_tmp0_ = windows_main_window_get_selected_path (self)), _g_free0 (_tmp0_), _tmp1_);
		if (g_file_query_exists (file, cancellable)) {
			char* line;
			gsize s = 0UL;
			GFileInputStream* _tmp2_;
			GFileInputStream* _tmp3_;
			GDataInputStream* _tmp4_;
			GDataInputStream* dis;
			line = g_strdup ("");
			_tmp2_ = g_file_read (file, NULL, &_inner_error_);
			if (_inner_error_ != NULL) {
				_g_free0 (line);
				_g_object_unref0 (file);
				goto __catch0_g_error;
			}
			dis = (_tmp4_ = g_data_input_stream_new ((GInputStream*) (_tmp3_ = _tmp2_)), _g_object_unref0 (_tmp3_), _tmp4_);
			while (TRUE) {
				gboolean _tmp5_ = FALSE;
				char* _tmp9_;
				char* _tmp8_;
				if (g_cancellable_is_cancelled (cancellable) == FALSE) {
					char* _tmp6_;
					char* _tmp7_;
					_tmp6_ = g_data_input_stream_read_line (dis, &s, cancellable, &_inner_error_);
					if (_inner_error_ != NULL) {
						_g_free0 (line);
						_g_object_unref0 (dis);
						_g_object_unref0 (file);
						goto __catch0_g_error;
					}
					_tmp5_ = (line = (_tmp7_ = _tmp6_, _g_free0 (line), _tmp7_)) != NULL;
				} else {
					_tmp5_ = FALSE;
				}
				if (!_tmp5_) {
					break;
				}
				code = (_tmp9_ = g_strconcat (code, _tmp8_ = g_strconcat (line, "\n", NULL), NULL), _g_free0 (code), _tmp9_);
				_g_free0 (_tmp8_);
			}
			_g_free0 (line);
			_g_object_unref0 (dis);
		}
		_g_object_unref0 (file);
	}
	goto __finally0;
	__catch0_g_error:
	{
		GError * e;
		e = _inner_error_;
		_inner_error_ = NULL;
		{
			char* _tmp10_;
			fprintf (stderr, "%s", _tmp10_ = g_strconcat ("Error: ", e->message, NULL));
			_g_free0 (_tmp10_);
			_g_error_free0 (e);
		}
	}
	__finally0:
	if (_inner_error_ != NULL) {
		_g_object_unref0 (cancellable);
		_g_free0 (code);
		g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
		g_clear_error (&_inner_error_);
		return;
	}
	webkit_web_view_load_html_string (self->priv->web_view, _tmp11_ = windows_crearDom (code), "file:///");
	_g_free0 (_tmp11_);
	_g_object_unref0 (cancellable);
	_g_free0 (code);
}


static void windows_main_window_class_init (WindowsMainWindowClass * klass) {
	windows_main_window_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (WindowsMainWindowPrivate));
	G_OBJECT_CLASS (klass)->finalize = windows_main_window_finalize;
}


static void windows_main_window_instance_init (WindowsMainWindow * self) {
	self->priv = WINDOWS_MAIN_WINDOW_GET_PRIVATE (self);
}


static void windows_main_window_finalize (GObject* obj) {
	WindowsMainWindow * self;
	self = WINDOWS_MAIN_WINDOW (obj);
	_g_object_unref0 (self->priv->main_box);
	_g_object_unref0 (self->priv->main_pane);
	_g_object_unref0 (self->priv->bar);
	_g_object_unref0 (self->priv->file_menu);
	_g_object_unref0 (self->priv->exit_menu);
	_g_object_unref0 (self->priv->tree_view_container);
	_g_object_unref0 (self->priv->tree_view_title);
	_g_object_unref0 (self->priv->scrolled_window_files);
	_g_object_unref0 (self->priv->tree_view);
	_g_object_unref0 (self->priv->scrolled_window_webview);
	_g_object_unref0 (self->priv->web_view);
	G_OBJECT_CLASS (windows_main_window_parent_class)->finalize (obj);
}


GType windows_main_window_get_type (void) {
	static volatile gsize windows_main_window_type_id__volatile = 0;
	if (g_once_init_enter (&windows_main_window_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (WindowsMainWindowClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) windows_main_window_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (WindowsMainWindow), 0, (GInstanceInitFunc) windows_main_window_instance_init, NULL };
		GType windows_main_window_type_id;
		windows_main_window_type_id = g_type_register_static (GTK_TYPE_WINDOW, "WindowsMainWindow", &g_define_type_info, 0);
		g_once_init_leave (&windows_main_window_type_id__volatile, windows_main_window_type_id);
	}
	return windows_main_window_type_id__volatile;
}


WindowsPreferences* windows_preferences_construct (GType object_type) {
	WindowsPreferences * self;
	self = g_object_newv (object_type, 0, NULL);
	return self;
}


WindowsPreferences* windows_preferences_new (void) {
	return windows_preferences_construct (WINDOWS_TYPE_PREFERENCES);
}


static void windows_preferences_class_init (WindowsPreferencesClass * klass) {
	windows_preferences_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (WindowsPreferencesPrivate));
	G_OBJECT_CLASS (klass)->finalize = windows_preferences_finalize;
}


static void windows_preferences_instance_init (WindowsPreferences * self) {
	self->priv = WINDOWS_PREFERENCES_GET_PRIVATE (self);
}


static void windows_preferences_finalize (GObject* obj) {
	WindowsPreferences * self;
	self = WINDOWS_PREFERENCES (obj);
	_g_object_unref0 (self->priv->repo_dir);
	G_OBJECT_CLASS (windows_preferences_parent_class)->finalize (obj);
}


GType windows_preferences_get_type (void) {
	static volatile gsize windows_preferences_type_id__volatile = 0;
	if (g_once_init_enter (&windows_preferences_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (WindowsPreferencesClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) windows_preferences_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (WindowsPreferences), 0, (GInstanceInitFunc) windows_preferences_instance_init, NULL };
		GType windows_preferences_type_id;
		windows_preferences_type_id = g_type_register_static (GTK_TYPE_DIALOG, "WindowsPreferences", &g_define_type_info, 0);
		g_once_init_leave (&windows_preferences_type_id__volatile, windows_preferences_type_id);
	}
	return windows_preferences_type_id__volatile;
}


static void _vala_array_destroy (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	if ((array != NULL) && (destroy_func != NULL)) {
		int i;
		for (i = 0; i < array_length; i = i + 1) {
			if (((gpointer*) array)[i] != NULL) {
				destroy_func (((gpointer*) array)[i]);
			}
		}
	}
}


static void _vala_array_free (gpointer array, gint array_length, GDestroyNotify destroy_func) {
	_vala_array_destroy (array, array_length, destroy_func);
	g_free (array);
}


static gint _vala_array_length (gpointer array) {
	int length;
	length = 0;
	if (array) {
		while (((gpointer*) array)[length]) {
			length++;
		}
	}
	return length;
}




