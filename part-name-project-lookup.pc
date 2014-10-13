/* Author: Christopher Anzalone */
/* Project: embedded-sql-proc-system-html-interface */
/* File: part-name-project-lookup.pc */

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "querystringoracle.c"

exec sql include sqlca;

main()
{
	exec sql begin declare section;
	VARCHAR jnum[6], jname[21], city[11];
	int status;
	VARCHAR pNameInput[21];
	VARCHAR user[21], pass[20];
	exec sql end declare section;

	int i;
	int icontentlength;
	char * method, * contentlength;

	//exec sql declare xs cursor for
	//select * from s where city = :rcity; 
		 
	exec sql declare xs cursor for
		select distinct j.* from j, p spj where p.pname = :pNameInput
			and spj.j#=j.j# and spj.p# = p.p#;

	/* Set Oracle environment variables.  The below function is
	contained in querystringoracle.c. */
	SetOrclEvars();

	strcpy(user.arr,"user");
	/* Use your UNIX username. */

	strcpy(pass.arr,"pass");
	/* Use your UNIX password. */

	user.len=strlen(user.arr);
	pass.len=strlen(pass.arr);

	/* connect to Oracle */
	exec sql connect :user identified by :pass;

	/* if can't connect, get out with error message */
	if(sqlca.sqlcode !=0)
	{ 
		printf("Content-type: text/plain\n\n");
		printf("Sorry, cannot connect to server, pgm aborted \n");
		exit(1);
	}

	/* do get or post */
	method=getenv("REQUEST_METHOD");
	if (strcmp(method,"POST")==0)
	{
		contentlength=getenv("CONTENT_LENGTH");
		sscanf(contentlength, "%d", &icontentlength);
		glInput=malloc(icontentlength+1);
		for (i=0; i<icontentlength; i++)
		{ 
			glInput[i]=getchar(); 
		}
		glInput[icontentlength]=0;
	}
	else 
	{
		glInput=getenv("QUERY_STRING");
	}
		
	glLength=strlen(glInput);

	//FindStringFor("city", rcity.arr
	FindStringFor("pNameInput", pname.arr);
  
	//rcity.len = strlen(rcity.arr);
	pNameInput.len = strlen(pNameInput.arr);

	/* generate HTML output with selected records in HTML table */
	printf("Content-type: text/html\n\n");
	printf("<html>\n");
	printf("<head>\n");
	printf("<title> Print Selected Job Records </title>\n");
	printf("</head>\n");
	printf("<body>\n");
	printf("<h1> SELECTED Job RECORDS </h1>\n");
	printf("    <table border=\"1\">\n");
	/* output header record for HTML table */
	printf("      <tr>\n");
	printf("        <th> JNUM </th>\n");
	printf("        <th> JNAME </th>\n");
	printf("        <th> CITY </th>\n");
	printf("      </tr>\n");
	
	exec sql open xs;
	for(;;)
	{
		exec sql fetch xs into :jnum, :jname, :city;
		if(sqlca.sqlcode !=0) break;
		jnum.arr[jnum.len] = 0;
		jname.arr[jname.len] = 0;
		city.arr[city.len] = 0;
		
		/* Print current data record to html table */
		printf("<tr>\n");
		printf("<td> %s </td>\n", jnum.arr);
		printf("<td> %s </td>\n", jname.arr);
		printf("<td> %s </td>\n", city.arr);
		printf("</tr>\n");
	}
	exec sql close xs;

	printf("</table>\n");

	/* Return to Part Name -> Project Lookup form */
	printf("<p>\n");
	printf("  <a href=\n");
	printf(
	"    \"part-name-project-lookup.html\">\n");
	printf("     click here to select again\n");
	printf("  </a>\n");
	printf("</p>\n");

	printf("</body>\n");
	printf("</html>\n");

}
