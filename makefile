NULL =

FLAGS = \
	-X -w

PACKAGES = \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg gee-1.0 \
	
ADITIONAL_PACKAGES = --vapidir ./vapi \
	--pkg libgit2 \

FILES = \
	src/main.vala \
	src/windows.vala \
	src/core.vala \
	src/configuration.vala \

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
