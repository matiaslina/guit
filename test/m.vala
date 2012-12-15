using Git;

public static int main( string []args )
{
	// Inicializaciones
	Repository repo;
	Git.Index index;
	uint ecount;
	// Abrimos el repositorio
	Repository.open(out repo,"/home/matias/workspace/linux-git-gui");
	
	// mostramos el path
	string path = repo.path;
	stdout.printf("%s\n",path);
	
	repo.get_index(out index);
	
	ecount = index.count;
	
	stdout.printf("%lu\n", ecount);
	
	for(int i = 0; i < ecount; ++i)
	{
		unowned IndexEntry e = index.get(i);
		
		// Mostramos el path de todos los archivos.
		stdout.printf("path: %s\n", e.path);
	}
	
	return 0;
}
