/*
 * git.c
 * This file is part of Guit
 *
 * Copyright (C) 2012 - Matias Linares
 *
 * Guit is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Guit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Guit; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, 
 * Boston, MA  02110-1301  USA
 */
#include <stdio.h>
#include <git2.h>
#include "git_core.h"

int show_branches(const char* branch_name, git_branch_t type, void *payload)
{
	if( branch_name != NULL ) {
		printf("branch: %s\n", branch_name);
		return 0;
	}
	return 1;
}

void
core_retrive_all_branchs( git_repository *repo ) {
	git_branch_foreach( repo, GIT_BRANCH_LOCAL, show_branches, NULL);
}



int main ( int argc, char** argv)
{
	git_repository *repo;
	git_index *index;
	unsigned int i, ecount;
	char *dir = "/home/matias/workspace/linux-git-gui";
	char out[41];
	out[40] = '\0';
	
	if( argc > 1)
		dir = argv[1];
	if( argc > 2) {
		fprintf(stderr, "usage: showindex [<repo-dir>]\n");
		return 1;
	}
	
	if ( git_repository_open_ext(&repo, dir, 0, NULL) < 0) {
		fprintf(stderr, "Could not open repository: %s\n", dir);
		return 1;
	}
	
	git_repository_index(&index, repo);
	git_index_read( index );
	
	ecount = git_index_entrycount( index );
	if (!ecount)
		printf("Empty index\n");
		
	for (i = 0; i < ecount; i += 1)
	{
		const git_index_entry *e = git_index_get_byindex(index, i);

		git_oid_fmt(out, &e->oid);

		printf("File Path: %s\n", e->path);
		printf(" Stage: %d\n", git_index_entry_stage(e));
		printf(" Blob SHA: %s\n", out);
		printf("File Size: %d\n", (int)e->file_size);
		printf(" Device: %d\n", (int)e->dev);
		printf(" Inode: %d\n", (int)e->ino);
		printf(" UID: %d\n", (int)e->uid);
		printf(" GID: %d\n", (int)e->gid);
		printf(" ctime: %d\n", (int)e->ctime.seconds);
		printf(" mtime: %d\n", (int)e->mtime.seconds);
		printf("\n");
	}
	
	core_retrive_all_branchs(repo);
	
	git_index_free(index);
	git_repository_free(repo);
}
