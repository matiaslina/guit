all:
	gcc commits.c `pkg-config --libs --cflags libgit2` -o commit
