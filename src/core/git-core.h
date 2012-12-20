#ifndef __GIT_CORE_H__
	#define __GIT_CORE_H__
	#include <stdio.h>
	#include <git2.h>


void core_retrive_all_branchs( git_repository *repo);
int show_branches(const char* branch_name, git_branch_t type, void *payload);

#endif
