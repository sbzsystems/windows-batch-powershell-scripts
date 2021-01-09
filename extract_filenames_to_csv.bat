chcp 65001
del FilesDirectoryList.csv

for /r %%a in (*.jpeg,*.jpg,*.pdf,*.png) do @echo %%~na >>../FilesDirectoryList.csv

cd ../Δικαιολογητικά Αγορών για μεταπώληση
for /r %%a in (*.jpeg,*.jpg,*.pdf,*.png) do @echo %%~na >>../FilesDirectoryList.csv