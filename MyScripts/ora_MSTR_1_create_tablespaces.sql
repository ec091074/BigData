-- 1. Replace the items in angle brackets including the brackets.
-- 2. Run this script as user SYS user
/* ===================================================================================================================================
	* Copyright 2011 Kronos Incorporated. All rights reserved.
	* Script : Create Table spaces for MSTR DB.
	* Description : Script to Create Tablespaces for MSTR DB. Provide with the the DB Name.

	* Example : Replace Angle brackets (<Database_Name/TableSpace_Name>) with Database/Table space name.
	* CREATE Tablespace "ReportMDDB_DAT01"   -- Assuming MSTR DB's tablespace to be named as ReportMDDB_DAT01, replace subsequent <Database_Name> or  <TableSpace_Name>too in the script similarly.
.  	  
	* Written By: M. Gupta
	* 	Date: 06/13/2011
	* 	Revisions -  Date:	   By:	          Desc:
====================================================================================================================================== */


CREATE TABLESPACE "MSTRDB_DAT01" -- Provide Tablespace Name, Leave double quotes as is.
	 DATAFILE SIZE 2097152000 AUTOEXTEND ON NEXT 128000 MAXSIZE UNLIMITED  --  Provide Database Name, Tablespace Name
	 BLOCKSIZE 8192 
	 LOGGING 
	 ONLINE 
	 EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
	 SEGMENT SPACE MANAGEMENT MANUAL;

CREATE TABLESPACE "MSTRDB_IDX01"	-- Provide Tablespace Name, Leave double quotes as is.
	 DATAFILE SIZE 28508160 AUTOEXTEND ON NEXT 1 MAXSIZE UNLIMITED --  Provide Database Name, Tablespace Name
	 BLOCKSIZE 8192 
	 LOGGING 
	 ONLINE 
	 EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
	 SEGMENT SPACE MANAGEMENT MANUAL;