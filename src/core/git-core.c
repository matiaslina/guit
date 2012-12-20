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

int main ( int argc, char** argv)
{
	git_repository *repo;
	git_repository_open(&repo, "/home/matias/workspace/linux-git-gui/.git");
	
	git_commit *commit;
	git_oid oid3;
	
	
	unsigned char *data;
	const char *str_type;
	int error;
	char *out;

	git_oid_fromstr(&oid3, "802866f810fe5400a43d8b7dca521eeca9bf1c53");

	error = git_commit_lookup(&commit, repo, &oid3);

	const git_signature *author, *cmtter;
	const char *message, *message_short;
	time_t ctime;
	unsigned int parents, p;

	message  = git_commit_message(commit);
	author   = git_commit_author(commit);
	cmtter   = git_commit_committer(commit);
	ctime    = git_commit_time(commit);

	printf("Author: %s (%s)\n", author->name, author->email);

	parents  = git_commit_parentcount(commit);
	for (p = 0;p < parents;p++) {
	  git_commit *parent;
	  git_commit_parent(&parent, commit, p);
	  git_oid_fmt(out, git_commit_id(parent));
	  printf("Parent: %s\n", out);
	  git_commit_free(parent);
	}

	git_commit_free(commit);
	git_repository_free(repo);

}
