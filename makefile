PACKAGES = \
	--pkg gtk+-2.0 \
	--pkg webkit-1.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg gdk-2.0 \
	
ADITIONAL_PACKAGES = --vapidir ./vapi \
	--pkg libgit2 \

FILES = \
	src/main.vala \
	src/windows.vala \
	src/FileTree.vala \
	src/configuration.vala \

EXEC = guit

all:
	@echo "Compiling..."
	valac $(FILES) $(PACKAGES) $(ADITIONAL_PACKAGES) -o $(EXEC)
	@echo "Done!"


get_c_code:
	valac main.vala windows.vala FileTree.vala $(OPTIONS) -C

run: all
	@echo " "
	@echo "Running"
	@./$(EXEC)
	@echo "Bye bye"

reset-config:
	@cp -f config.ini.backup repo.ini
	@echo "All configuration have been reseted."

clean:
	rm $(EXEC)
