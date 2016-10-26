cls
@ECHO OFF
echo This will convert all .png images in this folder to .webp format.
echo Type "yes" if you want to proceed.
:CONFIRM
set /p "cho=>" 
if %cho%==yes goto CONVERT
GOTO:eof
:CONVERT
for %%f in (*.png) do (
	cwebp -q 100 %%~nxf -o "%%~nf.webp"
	rm %%~nxf
)
