cd C:\Program Files (x86)\Firebird\Firebird_3_0
instsvc stop

SET maindb="C:\Users\solon\Desktop\MAIN_NEW21.fdb"
SET tempdb=%maindb:.fdb=.fbk%

for /F "delims=" %%i in (%maindb%) do set filename="%%~nxi"
SET backupdb=%filename:.fdb=.fdb.bak%

del %tempdb%


gfix -mend -full -ignore -user SYSDBA -pas masterkey %maindb%

gbak -b -v -user SYSDBA -password "masterkey" %maindb% %tempdb%

ren %maindb% %backupdb%

gbak -c -user SYSDBA -password masterkey %tempdb% %maindb%

instsvc start   

cd /d "%USERPROFILE%\Desktop"    