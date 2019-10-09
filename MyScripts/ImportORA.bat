echo off
REM ### Batch Script to import DB in Oracle DataBase ####
REM ###Scripts Started###

REM ###To use a different character (the exclamation mark) to expand environment variables at execution time###
setlocal EnableDelayedExpansion


set log=log.log
if exist log del log

set table_count=table_count.log
if exist table_count del table_count

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

REM ###WFC DB Import###
if /I %DB_IMPORT%==wfc (
echo ---------------Creating Logs-------------------------------
echo.
echo Checking !DB_IMPORT! DB ---------%Date% %Time%>>log
echo.>>log
echo ---------------Validating Database-------------------------
echo.

@echo SELECT count^(^table_name^)^ FROM all_tables where owner='TKCSOWNER' or owner='tkcsowner'; | sqlplus -s %WFC_USER%/%WFC_PASSWORD%@%WFC_SID%>table_count

for /F  "skip=3 tokens=1* delims==" %%A in (table_count)  do (	
set DATA=%%A
set Table_Count=!DATA:~2!
echo Total number of tables exist in TKCSOWNER schema is !Table_Count!---------%Date% %Time%>>log
echo.>>log
)

if not !Table_Count!==0 (
set /P C=Your %DB_IMPORT% DB has already data loaded, Are you sure you want to restore again[Y/N]?
if /I !c!==Y (

echo.
echo ---------------Deleting !WFC_SCHEMA! User---------------------
echo.
echo Deleting !WFC_SCHEMA! user --------- %Date% %Time%>>log
echo.>>log
@echo @ora_delete_tkcsowner_user.sql | sqlplus -s sys/%WFC_PASSWORD%@%WFC_SID% as sysdba>>log

echo ---------------Creating !WFC_SCHEMA! User---------------------
echo.
echo Creating !WFC_SCHEMA! user --------- %Date% %Time%>>log
echo.>>log
@echo @ora_create_tkcsowner_User.sql | sqlplus -s sys/%WFC_PASSWORD%@%WFC_SID% as sysdba>>log

echo ---------------Validating Source Path ---------------------
echo.
if exist %source_Path_wfc%\* (
for /R %source_Path_wfc% %%F in (*.DMP) do (
set "WFC_FILE=%%~nF.DMP"
echo !WFC_FILE! file available at %source_Path_wfc% %Date% %Time%>>log
echo.>>log
	::### Check if Dump File is available at Target Path###
echo ---------------Validating Target Path ---------------------
echo.
		if exist %destPath%\!WFC_FILE! (
		REM ####If file is alredy exist in DUMP_DIR then Delete the file and copy again from source path#####
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo !WFC_FILE! file already exists at location %destPath%, file replacement started at %Date% %Time%>>log
		echo.>>log
		del %destPath%\!WFC_FILE!>>log
		xcopy /-y %source_Path_wfc%\!WFC_FILE! %destPath%\ /d /c /y>>log
		
		echo ---------------DB Import started for !WFC_SCHEMA! -----------
		echo.
		REM ####Start DB import proccess using impdp command#####
		echo DB import started for !WFC_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFC_SID% SCHEMAS=!WFC_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFC_FILE! log='importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		echo Please see importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		
		REM ####If file does not exist in DUMP_DIR then copy file from Source location to DUMP_DIR DB  and then import the dump file to wfc DB#####
		) else (
		REM ####If file does not exist in DUMP_DIR then copy from source path#####
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo Copying started for !WFC_FILE! at %date% %time%>>log
		echo.>>log
		xcopy /-y %source_Path_wfc%\!WFC_FILE! %destPath%\ /d /c /y>>log

		REM ####DB import for tkcsowner#####
		echo ---------------DB Import started for !WFC_SCHEMA! -----------
		echo.
		echo DB import started for !WFC_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFC_SID% SCHEMAS=!WFC_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFC_FILE! log='importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		echo Please see importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		)
	)
) else (
echo file not found at %source_Path_wfc%>>log
	
)

) 

if /I !c!==N (

echo execution Finished as you have opted no to import>>log
exit
)


) else (
echo ---------------Deleting !WFC_SCHEMA! User---------------------
echo.
echo Deletion for !WFC_SCHEMA! user started at %Date% %Time%>>log
echo.>>log
@echo @ora_delete_tkcsowner_user.sql | sqlplus -s sys/%WFC_PASSWORD%@%WFC_SID% as sysdba>>log

:: step 2 create the User 
echo ---------------Creating !WFC_SCHEMA! User---------------------
echo.
echo Creation for !WFC_SCHEMA! user started at %Date% %Time%>>log
echo.>>log
@echo @ora_create_tkcsowner_User.sql | sqlplus -s sys/%WFC_PASSWORD%@%WFC_SID% as sysdba>>log
echo ---------------Validating Source Path ---------------------
echo.	
	if exist %source_Path_wfc%\* (
	for /R %source_Path_wfc% %%F in (*.DMP) do (
	set "WFC_FILE=%%~nF.DMP"	
	echo !WFC_FILE! file available at %source_Path_wfc%    %Date% %Time%>>log
	echo.>>log
	echo ---------------Validating Target Path ---------------------
	echo.
		if exist %destPath%\!WFC_FILE! (
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo !WFC_FILE! file already exists at location %destPath%, file replacement started at %Date% %Time%>>log
		echo.>>log
		del %destPath%\!WFC_FILE!>>log
		xcopy /-y %source_Path_wfc%\!WFC_FILE! %destPath%\ /d /c /y>>log
		
		echo ---------------DB Import started for !WFC_SCHEMA! ------------
		echo.
		echo DB import started for !WFC_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFC_SID% SCHEMAS=!WFC_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFC_FILE! log='importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		echo Please see importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log

		) else (
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo Copying started for !WFC_FILE! at %date% %time%>>log
		echo.>>log
		xcopy /-y %source_Path_wfc%\!WFC_FILE! %destPath%\ /d /c /y>>log
		
		echo ---------------DB Import started for !WFC_SCHEMA! ------------
		echo.
		echo DB import started for !WFC_FILE! file -------- %Date% %Time%>>log
		impdp system/manager@%WFC_SID% SCHEMAS=!WFC_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFC_FILE! log='importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		echo Please see importWFC-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		)
	)
	) else (
	echo nothing
	echo file not found at %source_Path_wfc%>>log
	)
	
)

) else if /I %DB_IMPORT%==wfan (
:: ####WFAN DB_IMPORT#####
echo ---------------Creating Logs-------------------------------
echo.
echo Checking !DB_IMPORT! DB ---------%Date% %Time%>>log
echo.>>log
echo ---------------Validating Database-------------------------
echo.
@echo SELECT count^(^table_name^)^ FROM all_tables where owner in ^(^'IA','IA_ETL','IA_EXT'^)^; | sqlplus -s %WFAN_USER%/%WFAN_PASSWORD%@%WFAN_SID%>table_count

for /F  "skip=3 tokens=1* delims==" %%A in (table_count)  do (	
	set DATA=%%A
    set Table_Count=!DATA:~2!
	echo Total number of table exist in WFAN schema is !Table_Count!---------%Date% %Time%>>log
	echo.>>log
)

:: ###IF WFC DB has already loaded###
if not !Table_Count!==0 (
set /P c=Your %DB_IMPORT% DB has already data loaded, Are you sure you want to restore again[Y/N]?
if /I !c!==Y (
echo.
echo ---------------Deleting WFAN Users-------------------------
echo.
echo Deletion for WFAN users started at %Date% %Time%>>log
echo.>>log
@echo @ora_delete_WFAN_User.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log

:: step 2 create the User 
echo ---------------Creating WFAN Table Spaces------------------
echo.
echo Creation for WFAN table spaces started at %Date% %Time%>>log
echo.>>log
@echo @ora_1_create_ia_tablespaces.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log
echo ---------------Creating WFAN Users-------------------------
echo.
echo Creation for WFAN table spaces started at %Date% %Time%>>log
echo.>>log
@echo @ora_2_add_schemas_roles.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log

::### Check if Dump File is available at Source Path###
echo ---------------Validating Source Path ---------------------
echo.
if exist %source_Path_wfan%\* (
	for /R %source_Path_wfan% %%F in (*.DMP) do (
	set "WFAN_FILE=%%~nF.DMP"	
	echo !WFAN_FILE! file available at %source_Path_wfan%    %Date% %Time%>>log
	echo.>>log
	REM ####Check Whether the file exist at source loaction or not#####
	echo ---------------Validating Target Path ---------------------
	echo.
	::### Check if Dump File is available at Target Path###
		if exist %destPath%\!WFAN_FILE! (
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		REM ####If file is alredy exist in DUMP_DIR then Delete the file and copy again from source path#####
		echo !WFAN_FILE! file already exists at location %destPath%, file replacement started at %Date% %Time%>>log
		echo.>>log
		del %destPath%\!WFAN_FILE!>>log
		xcopy /-y %source_Path_wfan%\!WFAN_FILE! %destPath%\ /d /c /y>>log
		
		REM ####Start DB import proccess using impdp command#####
		echo ---------------DB Import started for !WFAN_SCHEMA! -----
		echo.
		echo DB import started for !WFAN_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFAN_SID% SCHEMAS=!WFAN_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFAN_FILE! log='importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		@echo Please see importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		) else (
		REM ####If file does not exist in DUMP_DIR then copy from source path#####
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo Copying !WFAN_FILE! file started at %Date% %Time%>>log
		xcopy /-y %source_Path_wfan%\!WFAN_FILE! %destPath%\ /d /c /y>>log
		
		REM ####DB import for WFAN#####
		echo ---------------DB Import started for !WFAN_SCHEMA! -----
		echo.
		echo DB import started for !WFAN_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFAN_SID% SCHEMAS=!WFAN_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFAN_FILE! log='importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		@echo Please see importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		)
	)
	) else (
	echo file not found at %source_Path_wfan%>>log
	)
) 
:: ###IF WFAN DB has already loaded and user user opted No then Exit from execution###
if /I !c!==N (

echo execution Finished as you have opted no to import>>log
exit
)

) else (
echo ---------------Deleting WFAN Users-------------------------
echo.
echo Deletion for WFAN users started at %Date% %Time%>>log
echo.>>log
@echo @ora_delete_WFAN_User.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log

:: step 2 create the User 
echo ---------------Creating WFAN Table Spaces------------------
echo.
echo Creation for WFAN table spaces started at %Date% %Time%>>log
echo.>>log
@echo @ora_1_create_ia_tablespaces.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log
echo ---------------Creating WFAN Users-------------------------
echo.
echo Creation for WFAN table spaces started at %Date% %Time%>>log
echo.>>log
@echo @ora_2_add_schemas_roles.sql | sqlplus -s sys/%WFAN_PASSWORD%@%WFAN_SID% as sysdba>>log

::### Check if Dump File is available at Source Path###
echo ---------------Validating Source Path ---------------------
echo.

	if exist %source_Path_wfan%\* (
	for /R %source_Path_wfan% %%F in (*.DMP) do (
	set "WFAN_FILE=%%~nF.DMP"	
	echo !WFAN_FILE! file available at %source_Path_wfan%    %Date% %Time%>>log
	echo.>>log
	REM ####Check Whether the file exist at source loaction or not#####
	echo ---------------Validating Target Path ---------------------
	echo.
		if exist %destPath%\!WFAN_FILE! (
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo !WFAN_FILE! file already exists at location %destPath%, file replacement started at %Date% %Time%>>log
		echo.>>log
		del %destPath%\!WFAN_FILE!>>log
		xcopy /-y %source_Path_wfan%\!WFAN_FILE! %destPath%\ /d /c /y>>log
		
		REM ####If file is alredy exist in DUMP_DIR then start DB import proccess using impdp command#####
		echo ---------------DB Import started for !WFAN_SCHEMA! -----
		echo.
		echo DB import started for !WFAN_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFAN_SID% SCHEMAS=!WFAN_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFAN_FILE! log='importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		@echo Please see importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		
		) else (
		echo ---------------Placing dump file to DUMP_DIR --------------
		echo.
		echo Copying started for !WFAN_FILE! at %date% %time%>>log
		xcopy /-y %source_Path_wfan%\!WFAN_FILE! %destPath%\ /d /c /y>>log
		
		REM ####DB import for WFAN#####
		echo ---------------DB Import started for !WFAN_SCHEMA! --------
		echo.
		echo DB import started for !WFC_FILE! file -------- %Date% %Time%>>log
		echo.>>log
		impdp system/manager@%WFAN_SID% SCHEMAS=!WFAN_SCHEMA! DIRECTORY=DUMP_DIR DUMPFILE=!WFAN_FILE! log='importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log'>>log
		echo ---------------Copying import log -----------------
		echo.
		echo Copying import log file from DUMP_DIR ----------%Date% %Time%>>log
		echo.>>log
		set "LogFolder=%~dp0"
		xcopy /-y %destPath%\importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log  %LogFolder%  /d /c /y>>log
		@echo Please see importWFAN-%date:~4,2%-%date:~7,2%-%date:~10,4%.log file for more information.>>log
		)
	)
	) else (
	echo file not found at %source_Path_wfan%>>log
	)
) 


) else (
echo Please update DB_IMPORT field in myProperties file as WFC or WFAN......%Date% %Time%
)


pause