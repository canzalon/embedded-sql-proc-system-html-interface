/* Author: Christopher Anzalone*/
/* Project: embedded-sql-proc-system-html-interface */
/* File: stand-alone-sql-system.pc */

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<sqlcpr.h>
#include "querystringoracle.c"
#include "specialcharacters.c" 

exec sql include sqlca;

back()
{
printf("<p>\n");
printf("  <a href=\n");
printf(
  "    \"/stand-alone-sql-system.html\">\n");
printf("     [CLICK HERE TO REDO]\n");
printf("  </a>\n");
printf("</p>\n");

printf("<p>\n");
printf("  <a href=\n");
printf(
  "    \"/embedded-sql-proc-system-html-interface.html\">\n");
printf("     [RETURN TO MAIN MENU]\n");
printf("  </a>\n");
printf("</p>\n");

printf("</body>\n");
printf("</html>\n");

exit(0);
}


main()
{
exec sql begin declare section;
char stmt1[257];

  VARCHAR user[20], pass[20]; 
int ivalue;
char values[257];
int type;
int n;
int size;
char name[30];

exec sql end declare section;

int i;
int types[100];
int len;
char names[100][30];
int icontentlength;
char * method, * contentlength;

  /*querystringoracle.c (Set Oracle environment variables) */
SetOrclEvars();

  /* do get or post */
method=getenv("REQUEST_METHOD");
if (strcmp(method,"POST")==0)
  {
	contentlength=getenv("CONTENT_LENGTH");
	sscanf(contentlength, "%d", &icontentlength);
	glInput=malloc(icontentlength+1);
	for (i=0; i<icontentlength; i++)
	{ glInput[i]=getchar(); }
	glInput[icontentlength]=0;
  }
else glInput=getenv("QUERY_STRING");

glLength=strlen(glInput);
fixStatement(glInput); // call functon to correct string

FindStringFor("username", user.arr);
user.len = strlen(user.arr);
FindStringFor("password", pass.arr);
pass.len = strlen(pass.arr);
FindStringFor("stmt",stmt1);

  /* Generate HTML output */
printf("Content-type: text/html\n\n");
printf("<html>\n");
printf("<head>\n");
printf("<title> Results </title>\n");
printf("</head>\n");
printf("<body>\n");

  /* Connect to server */
exec sql connect :user identified by :pass;
if(sqlca.sqlcode != 0)
   { 
	sqlca.sqlerrm.sqlerrmc[sqlca.sqlerrm.sqlerrml]=0;
	printf("<h1>err = %s</h1>\n", sqlca.sqlerrm.sqlerrmc);
	back();
   }
	printf("<h1> Statement: %s </h1>\n",stmt1); 

//if statement: for choosing if string is select statement...
if (!(stmt1[0] == 's' || stmt1[0] == 'S') )
  {

	exec sql execute immediate :stmt1;
	if(sqlca.sqlcode != 0)
	{ 
	sqlca.sqlerrm.sqlerrmc[sqlca.sqlerrm.sqlerrml]=0;
	printf("<h1>err = %s</h1>\n", sqlca.sqlerrm.sqlerrmc);
	}
	else
	{
	exec sql commit;
	printf("<h1>SQL STATEMENT WAS SUCCESSFULLY EXECUTED</h1>\n");
	}
	back();
  }
//else: its a select statement...
else
  {
	  /* Prepare select statement,
	declare cursor for select statement */
	exec sql prepare st from :stmt1;
	if(sqlca.sqlcode != 0)
		{ 
	printf
	("<h1> BAB TABLE NAME OR BAD FIELDNAME, RETRIEVE: TERMINATED..</h1>\n"); /* Print Oracle Error  */
	back();
		}
	exec sql declare xs cursor for st;

		/* Space allocation: list descriptor desc,
	describes the select statement into the desc */
	exec sql allocate descriptor 'desc';
	exec sql describe output st using descriptor 'desc';

		/* number of fields in statement */ 
	exec sql get descriptor 'desc' :n = count;

		/* Copy the fields */
	for (i=1; i<= n; i++)
	{
		exec sql get descriptor 'desc' 
		value :i :type = type, :name = name;

		/* Change NUMBER to INTEGER; set size */
		if (type==2)
		{
			type=3; size = 4;
			exec sql set descriptor 'desc' 
			value :i type=:type, length = :size;
		}
		types[i] = type; 
		strcpy(names[i], name);
	}

	exec sql open xs;

	/* generate HTML table with selected records*/

	printf("    <table border=\"1\">\n");
	/* Output header record for HTML table */
	printf("<tr>\n");
	for (i=1; i<=n; i++) 
	{ printf("<th>%s</th>\n", names[i]); }
	printf("</tr>\n");

	/* Output data records for HTML table */
	for(;;)
	{ exec sql fetch xs into descriptor 'desc';

	if(sqlca.sqlcode != 0) { break; }
		/* Output data record for HTML table */
	printf("<tr>\n");

	for (i=1; i<= n; i++)
	{ switch(types[i])
	{ case 1: exec sql get descriptor 'desc' 
	value :i :values = data, :len = length;
	values[len] = 0;
	printf("<td> %s </td>\n", values);
	break;
	case 3: exec sql get descriptor 'desc' 
	value :i :ivalue = data;
	sprintf(values, "%d", ivalue);
	printf("<td> %s </td>\n", values);
	break;
				}
			}
	printf("</tr>\n");
		}

	printf("</table>\n");

	back();

	exec sql deallocate descriptor 'desc';
	}//end of code for select statement...

  }
