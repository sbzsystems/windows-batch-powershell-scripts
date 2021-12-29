cd C:\Program Files (x86)\Firebird\Firebird_3_0

SET maindb="C:\Program Files (x86)\SBZ systems\EMDI\dbs\main.fdb"
SET backupdb=%maindb:.fdb=.nbk%


nbackup -U SYSDBA -P masterkey -B 0 %maindb% %backupdb%




cd /d "%USERPROFILE%\Desktop"   