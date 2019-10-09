/*--------Section 1 Start---------*/

/* run as SYSTEM (or DBA) Oracle Account ...*/
/*=======================================================================================================================================================
 * Copyright 2012 Kronos Incorporated. All rights reserved.														
 * Script : ora_2_add_schema_roles.sql
 * Description –  It has been divided into three sections – 
 *    Section 1 - For creating the ia, ia_etl and ia_ext schemas and assigning different roles. This section should not be executed in case of upgrade scenario setup.  
 *                               
 *    Section 2 - Creates wfanmgr user and assigns dba role. This section should be executed in both upgrade and new scenario.
 *
 *    Section 3 - Creates wfc dblink for wfanmgr user.
 *                               
 * Revisions -  Date:	       By:	                Desc:
 *      	02/01/2012     Anjali Sud		Added Header in this script   
 *  		09/11/2013     Sachin Goel		WFM-54972- Assigned additional privileges to IA user so that we will not face the issue with MV restoration
 *  		02/12/2014     Uttam Bhattacharjee	removed Section 3
 *		11/03/2014     Ranjeet Kumar		Added the defensive coding to take care of unavailability of USERS tablespace
 * 		02/09/2015     Ranjeet Kumar		Added the code to create tablespace and then grant the unlimited quota to that tablespace
 *		04/07/2015     Suraj Kumar		Added the code for AM User  AMQUERYMGR
 *		04/21/2015     Sachin Goel		Added command for drop user AMQUERYMGR
======================================================================================================================================================= */

set echo on

spool &logdir/add_schemas_roles.log

/* drop users ... */

drop user ia cascade;
drop user ia_etl cascade;
drop user ia_ext cascade;
drop user WFANMGR cascade;
drop user WFCRPT_Unknown cascade;
drop user AMQUERYMGR cascade;

/* supply a PassWord for the IA schemas */
create user ia identified by ia;
create user ia_etl identified by ia_etl;
create user ia_ext identified by ia_ext;
create user WFANMGR identified by  kronites;
create user WFCRPT_Unknown identified by  kronites;
CREATE USER AMQUERYMGR IDENTIFIED BY kronites;

/* GRANTs */
grant connect to ia;
grant connect to ia_etl;
grant connect to ia_ext;
grant connect to WFANMGR;
grant DBA to WFANMGR;
grant connect to WFCRPT_Unknown;

grant create procedure to ia;
grant create procedure to ia_etl;
grant create procedure to ia_ext;

grant create table to ia;
grant create table to ia_ext;
grant create table to WFCRPT_Unknown;

grant create trigger to ia_etl;
grant create trigger to ia_ext;

grant create view to ia;
grant create view to ia_ext;

create role ia_sa;
create role iavw;
create role iavws;
create role iamgr;

grant analyze any to ia;
grant analyze any to ia_etl;
grant analyze any to ia_ext;

grant select any sequence to ia_etl;
grant create any sequence to ia_etl;
grant drop any sequence to ia_etl;

grant create database link to ia_etl;


grant select any sequence to ia_ext;
grant create any sequence to ia_ext;
grant drop any sequence to ia_ext;

grant create database link to ia_ext;

grant create any index to ia_etl;
grant drop any index to ia_etl;

grant create materialized view to ia;


/* set up Tablespace rights ... */
alter user ia default tablespace ia_dat01 temporary tablespace temp;
alter user ia_etl default tablespace ia_etl_dat01 temporary tablespace temp;
alter user ia_ext default tablespace ia_ext_dat01 temporary tablespace temp;
ALTER USER WFCRPT_Unknown DEFAULT TABLESPACE WFCRPT_Unknown_DAT01 TEMPORARY TABLESPACE TEMP;

alter user ia quota unlimited on IA_IDX01;
alter user ia quota unlimited on IA_IDX02;
alter user ia quota unlimited on IA_IDX03;
alter user ia quota unlimited on IA_IDX04;
alter user ia quota unlimited on IA_IDX05;
alter user ia quota unlimited on IA_IDX06;
alter user ia quota unlimited on IA_IDX07;
alter user ia quota unlimited on IA_IDX08;

alter user ia quota unlimited on IA_DAT01;
alter user ia quota unlimited on IA_DAT02;
alter user ia quota unlimited on IA_DAT03;
alter user ia quota unlimited on IA_DAT04;
alter user ia quota unlimited on IA_DAT05;
alter user ia quota unlimited on IA_DAT06;
alter user ia quota unlimited on IA_DAT07;
alter user ia quota unlimited on IA_DAT08;

alter user ia_etl quota unlimited on IA_ETL_IDX01;
alter user ia_etl quota unlimited on IA_ETL_IDX02;
alter user ia_etl quota unlimited on IA_ETL_IDX03;
alter user ia_etl quota unlimited on IA_ETL_IDX05;
alter user ia_etl quota unlimited on IA_ETL_IDX06;
alter user ia_etl quota unlimited on IA_ETL_IDX07;
alter user ia_etl quota unlimited on IA_ETL_IDX08;

alter user ia_etl quota unlimited on IA_ETL_DAT01;
alter user ia_etl quota unlimited on IA_ETL_DAT02;
alter user ia_etl quota unlimited on IA_ETL_DAT03;
alter user ia_etl quota unlimited on IA_ETL_DAT05;
alter user ia_etl quota unlimited on IA_ETL_DAT06;
alter user ia_etl quota unlimited on IA_ETL_DAT07;
alter user ia_etl quota unlimited on IA_ETL_DAT08;

alter user ia_ext quota unlimited on IA_EXT_IDX01;
alter user ia_ext quota unlimited on IA_EXT_DAT01;


ALTER USER WFCRPT_Unknown QUOTA UNLIMITED ON WFCRPT_Unknown_DAT01;

/* create a new user for adhoc query AMQUERYMGR  */


alter user AMQUERYMGR default tablespace IA_DAT01 temporary tablespace temp;

GRANT "CONNECT" TO AMQUERYMGR ;
ALTER USER AMQUERYMGR DEFAULT ROLE "CONNECT";
GRANT CREATE ANY SYNONYM TO AMQUERYMGR ;
GRANT CREATE ANY VIEW TO AMQUERYMGR ;



DECLARE
V_CNT NUMBER;
BEGIN
SELECT COUNT(*) INTO V_CNT FROM ALL_SYNONYMS WHERE SYNONYM_NAME='R_MSTR_CRITERIA' AND OWNER = 'WFCRPT_UNKNOWN';
 IF V_CNT=0 THEN
    EXECUTE IMMEDIATE 'CREATE SYNONYM WFCRPT_Unknown.R_MSTR_CRITERIA FOR IA.R_MSTR_CRITERIA';
 END IF;
END;
/
/*--------Section 1 End---------*/
/ 
spool off
