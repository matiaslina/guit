#include <stdio.h>
#include <git2.h>

int main(int argc, char *argv[])
{
	git_repository *repo;
	char out[41];
	out[40] = '\0';

	if( argc > 1) 
		git_repository_open(&repo, argv[1]);
	else
		git_repository_open(&repo, ".");

	git_oid oid;
	char hex[] = "ee1248e47cbeb72edd88ebd729efad9190ff6bab";

	git_oid_fromstr( &oid, hex);
	/* Testing the object database */
	git_odb *odb;
	git_repository_odb( &odb, repo );

	printf("\n*Raw Object Read*\n");
	git_odb_object *obj;
	git_otype otype;
	const unsigned char *data;
	const char *str_type;
	int error;

	error = git_odb_read( &obj, odb, &oid);

	data = (const unsigned char *) git_odb_object_data( obj );
	otype = git_odb_object_type(obj);
	
	str_type = git_object_type2string( otype );
	printf("object length and type: %d, %s\n",
					(int) git_odb_object_size(obj),
					str_type);

	git_odb_object_free( obj );

	printf("\nCommit writing\n");
	git_oid tree_id, parent_id, commit_id;
	git_tree *tree;
	git_commit *parent;
	const git_signature *author, *cmtter;

	git_signature_new((git_signature **)&author, "Matias", "matias@gmial.com", 123456789, 60);
	git_signature_new((git_signature **) &cmtter, "Matias Linares","matiaslina@github.com", 987644311, 90);

	git_oid_fromstr(&tree_id, "28873d96b4e8f4e33ea30f4c682fd325f7ba56ac");
  	git_tree_lookup(&tree, repo, &tree_id);
  	git_oid_fromstr(&parent_id, "f0877d0b841d75172ec404fc9370173dfffc20d1");
  	git_commit_lookup(&parent, repo, &parent_id);
  	
  	git_commit_create_v(
		&commit_id, /* out id */
		repo,
		NULL, /* do not update the HEAD */
		author,
		cmtter,
		NULL, /* use default message encoding */
		"example commit",
		tree,
		1, parent);
		
	git_oid_fmt(out, &commit_id);
  	printf("New Commit: %s\n", out);

	git_repository_free( repo );

	return 0;
}
