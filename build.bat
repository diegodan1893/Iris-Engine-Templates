echo "Building templates..."

if exist "releases\" rmdir /s /q "releases\"
mkdir "releases"

for /d %%f in (*) do (
	if not "%%f" == "releases" (
		"C:\Program Files\WinRAR\WinRar.exe" a -ep1 -r "releases\%%~nf.zip" "%%f\*"
	)
)
