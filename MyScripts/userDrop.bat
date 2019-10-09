echo off
REM ### Batch Script to import DB in Oracle DataBase ####
REM ###Scripts Started###

REM ###To use a different character (the exclamation mark) to expand environment variables at execution time###
setlocal EnableDelayedExpansion






set dropuser=dropuser.log
if exist dropuser del dropuser

:: ###Calling Properties Files and set the variables###
for /F  "tokens=1* delims==" %%A in (myProperties.properties) do (
	if "%%A"=="DB_IMPORT" set DB_IMPORT=%%B
	if "%%A"=="DUMP_PATH_WFC" set source_Path_wfc=%%B
	if "%%A"=="DUMP_PATH_WFAN" set source_Path_wfan=%%B
	if "%%A"=="DUMP_DIR" set destPath=%%B
	if "%%A"=="WFC_USER" set WFC_USER=%%B
	if "%%A"=="WFC_PASSWORD" set WFC_PASSWORD=%%B
	if "%%A"=="WFC_SID" set WFC_SID=%%B
	if "%%A"=="WFC_SCHEMA" set WFC_SCHEMA=%%B
	if "%%A"=="WFAN_USER" set WFAN_USER=%%B
	if "%%A"=="WFAN_PASSWORD" set WFAN_PASSWORD=%%B
	if "%%A"=="WFAN_SID" set WFAN_SID=%%B
	if "%%A"=="WFAN_SCHEMA" set WFAN_SCHEMA=%%B
)


@echo @ora_delete_tkcsowner_user.sql | sqlplus -s sys/%WFC_PASSWORD%@%WFC_SID% as sysdba>>dropuser
for /F  "tokens=1* delims==" %%A in (dropuser)  do (	
set DATA=%%A
set dropuser=!DATA!
echo  !dropuser!
)

pause