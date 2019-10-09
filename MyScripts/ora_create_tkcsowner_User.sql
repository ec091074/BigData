
set echo on

CREATE  TABLESPACE TKCS1 DATAFILE SIZE 300M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS2 DATAFILE SIZE 300M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS3 DATAFILE SIZE 300M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS4 DATAFILE SIZE 300M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS5 DATAFILE SIZE 300M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS6 DATAFILE SIZE 30M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS7 DATAFILE SIZE 30M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS8 DATAFILE SIZE 30M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;

CREATE  TABLESPACE TKCS9 DATAFILE SIZE 30M 
 AUTOEXTEND    ON NEXT  51200K MAXSIZE  unlimited EXTENT MANAGEMENT LOCAL 
    UNIFORM SIZE 1M SEGMENT SPACE MANAGEMENT  AUTO;
create role kronosuser;
create role kronoscuser;
create role kronosruser;

-- KRONOS user
create user kronos
identified by kronos96
default tablespace tkcs3
temporary tablespace temp;

grant create public synonym, 
      create role, 
      create session, 
      create synonym, 
      drop public synonym, 
      grant any role,
      unlimited tablespace
to kronos;



-- SUPRKRON User
create user suprkron
identified by skron96
default tablespace tkcs3
temporary tablespace temp;

grant create session, 
      alter session,
      unlimited tablespace 
   to suprkron with admin option;

grant select on v_$parameter to suprkron;
grant select on sys.dba_segments to suprkron;
grant select on sys.dba_tables to suprkron;
grant select on sys.dba_indexes to suprkron;
grant select on sys.dba_synonyms to suprkron;
grant select_catalog_role to suprkron;
grant analyze any to suprkron;
grant select_catalog_role to suprkron;
grant create table, unlimited tablespace to suprkron with admin option;
grant kronosuser to suprkron;





-- KRONREAD user
create user kronread
identified by kronr96
default tablespace tkcs3
temporary tablespace temp;

grant create session, 
      unlimited tablespace 
    to kronread;

grant kronosruser to kronread;





-- TKCSOWNER (SCHEMA OWNER)
create user tkcsowner identified by tkcsowner
default tablespace tkcs3
temporary tablespace temp;

grant connect, 
      resource, 
      drop public synonym, 
      create public synonym,
      query rewrite,
      analyze any,
      alter session,
      create cluster,
      create database link,
      create sequence,
      create session,
      create synonym,
      create table,
      create view,
      unlimited tablespace
   to tkcsowner;

grant select on sys.dba_synonyms to tkcsowner;
grant select on sys.dba_segments to tkcsowner;
grant select on sys.dba_tables to tkcsowner;
grant select on sys.dba_indexes  to tkcsowner;
grant select on v_$parameter to tkcsowner;

alter profile default limit password_grace_time unlimited;
alter profile default limit password_life_time unlimited;
alter user system identified by manager;

