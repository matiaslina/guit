NULL =

FLAGS = \
	-X -w \

PACKAGES = \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg gee-1.0 \
	
ADITIONAL_PACKAGES = --vapidir ./vapi \
	--pkg libgit2 \

FILES = \
	src/guit.vala \
	src/guit_main_window.vala \
	src/guit_branch_combobox.vala \
	src/guit_commit_treeview.vala \
	src/guit_file_treeview.vala \
	src/guit_preferences.vala \
	src/guit_repository_combobox.vala \
	src/guit_aer_dialog.vala \
	src/git_core.vala \
	src/git_core_structures.vala \
	src/configuration.vala \
	src/console_main.vala \
	src/console_callbacks.vala \
	src/console_window.vala \
	src/utils.vala \

C_FILES = \
	src/main.c \
	src/windows.c \
	src/core.c \
	src/configuration.c \

EXEC = guit

all:
	@echo "Compiling..."
	valac $(FLAGS) $(FILES) $(PACKAGES) $(ADITIONAL_PACKAGES) -o $(EXEC)
	@echo "Done!"


get_c_code:
	valac $(FILES) $(PACKAGES) $(ADITIONAL_PACKAGES) -C

run: all
	@echo "Running"
	@echo "Debug info:"
	@./$(EXEC)
	@echo "Bye bye"

reset-config:
	@cp -f config.ini.backup repo.ini
	@echo "All configuration have been reseted."

clean:
	rm $(EXEC)

clean_c_code:
	rm $(C_FILES)
