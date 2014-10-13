embedded-sql-proc-system-html-interface
=======================================

An interactive, browser-based, embedded SQL system with an html front-end for the Supplier Parts Projects (SPJ) database. This project contains two systems, one which is specific to the SPJ database, and one which is a stand-alone, general purpose, SQL system. The requests for the database are submitted through the html interface via forms. The forms of the html front-ends for both systems have as their action a Pro*C CGI program. 

[part-name-project-lookup]
The first system accepts a PNAME value from the user, and prints the project records in an HTML table for projects that supply that part. 

[stand-alone-sql-system]
The second system accepts a stand-alone SQL statement that is submitted to the database and processed by the back-end CGI script invoked by the html form.