PACKAGES = \
	--pkg gtk+-2.0 \
	--pkg webkit-1.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg gdk-2.0 \
	
ADITIONAL_PACKAGES = --vapidir ./vapi \
	--pkg libgit2 \

EXEC = git-gui

all:
	@echo "Compiling..."
	valac main.vala windows.vala FileTree.vala $(PACKAGES) $(ADITIONAL_PACKAGES) -o $(EXEC)
	@echo "Done!"


get_code:
	valac main.vala windows.vala FileTree.vala $(OPTIONS) -C

run: all
	@echo " "
	@echo "Running"
	@./git-gui
	@echo "Bye bye"

clean:
	rm $(EXEC)
