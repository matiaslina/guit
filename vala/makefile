OPTIONS = --pkg gtk+-2.0 --pkg webkit-1.0 --pkg gio-2.0 --pkg gee-1.0 --pkg gdk-2.0
EXEC = git-gui

all:
	valac main.vala windows.vala FileTree.vala $(OPTIONS) -o $(EXEC)

run: all
	./git-gui

clean:
	rm $(EXEC)
