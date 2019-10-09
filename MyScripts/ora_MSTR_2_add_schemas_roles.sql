/* run as SYSTEM (or DBA) Oracle Account ...*/
/* ===========================================================================================================================================================	
	* Copyright 2011 Kronos Incorporated. All rights reserved.
	* Script : Create WFCMD for MSTR DB

	* Description : Provide the password for WFCMD by replacing <Password> with actual password.
	* Provide with the Database Name in place of <Database_Name> for MSTR DB which was created before running this script.
	* Provide with the tablespace Name in place of "<TableSpace_Name>" for MSTR DB.
	* Use the same tablespace name which was created in script ora_mstr_1_create_tablespaces.sql

	* Example :
	* NOTE : Run this script ONLY on MSTR DB
	* Written By: M. Gupta
	* Date: 06/16/2011
	* Revisions -  Date:	   By:	          Desc:
	* 				01/31/2012: Sachin Goel - PAR- WFM-39469 -Assigned tablespaces to the user WFCMD
    *04/25/2013 :jyoti Verma        WFM-40080 :Making db scripts consistent while passing or replacing the variables like password etc.... 
	* 06/16/2015 : Sankalp Verma	WFAN-1687 - Added Grant to give unlimited tablespace rights

=============================================================================================================================================================== */
SET ECHO ON

define logdir=<Directory path>
define pw=kronites

spool &logdir\add_schemas_roles.log

/* supply a PassWord for the IA schemas */
CREATE USER WFCMD IDENTIFIED BY &PW
/

/* GRANTs */
GRANT CONNECT TO WFCMD
/

/* Allocate to resource role */
 GRANT RESOURCE TO WFCMD
/
/* set up Tablespace rights  */

Alter user wfcmd default tablespace "MSTRDB_DAT01" temporary tablespace temp 
/
Alter user wfcmd quota unlimited on "MSTRDB_IDX01"
/
Alter user wfcmd quota unlimited on "MSTRDB_DAT01"
/
spool off