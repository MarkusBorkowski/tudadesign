#Unterdrücke Fehlermeldungen des Systems
$ErrorActionPreference = "SilentlyContinue"



write-host "--LOADING FONTS--"
write-host "looking for fonts in current path"
if ((Test-Path tudfonts-tex_0.0.20090806.zip) -eq $True){
	write-host "fonts found in current path"
	$fontfile=(Get-Item -Path ".\" -Verbose).FullName + "\tudfonts-tex_0.0.20090806.zip"
}else{
	write-host "ERROR: fonts not found" -foreground "red"
	write-host "trying to download fonts"
	$cl = new-object system.net.webclient
	$cl.DownloadFile("http://exp1.fkp.physik.tu-darmstadt.de/tuddesign/latex/tudfonts-tex/tudfonts-tex_0.0.20090806.zip" , "tudfonts-tex_0.0.20090806.zip")
	if ((Test-Path tudfonts-tex_0.0.20090806.zip) -eq $True){
		write-host "downloaded fonts"
		$fontfile=(Get-Item -Path ".\" -Verbose).FullName + "\tudfonts-tex_0.0.20090806.zip"
	}else{
		write-host "ERROR: fonts could not be downloaded" -foreground "red"
		$DLfontfile = Read-Host -Prompt "Bitte Pfad angeben, in dem die Fonts heruntergeladen wurden:"
		$DLfontfile = "${DLdirectory}" + "\tudfonts-tex_0.0.20090806.zip"
		if ((Test-Path DLfontfile) -eq $True){
		$fontfile = $DLfontfile
		}else{
			write-host "ERROR: fonts not found in path" -foreground "red"
			Read-Host -Prompt "Press enter to exit"
			Exit
		}
	}
}

write-host ""
write-host "--INSTALLING--"

$InstallDIR = "${env:programdata}"+"\tudadesign"
mkdir $InstallDIR

write-host "extracting fonts"
$shellApplication = new-object -com shell.application
$zipPackage = $shellApplication.NameSpace($fontfile)
$destinationFolder = $shellApplication.NameSpace($InstallDIR)
$destinationFolder.CopyHere($zipPackage.Items())

write-host "copying tudadesign"
$pfad = ((Get-Item -Path ".\" -Verbose).FullName)
Copy-Item $pfad\texmf* $InstallDIR\ -recurse

cd $InstallDIR
write-host "deleting texmf\fonts\map\dvipdfm"
rmdir /Q /S "texmf\fonts\map\dvipdfm"

write-host ""
write-host "--CONFIGURING--"

mo_admin
write-host "---------------------------------------------"  -foreground "yellow"
write-host "|                IMPORTANT                  |"  -foreground "yellow"
write-host "|                                           |"  -foreground "yellow"
write-host "| 1. go to the ROOTS tab                    |"  -foreground "yellow"
write-host "| 2. click ADD                              |"  -foreground "yellow"
write-host "| 3. select C:\PROGRAMDATA\TUDADESIGN\TEXMF |"  -foreground "yellow"
write-host "| 4. click OK                               |"  -foreground "yellow"
write-host "|                                           |"  -foreground "yellow"
write-host "---------------------------------------------"  -foreground "yellow"

start-sleep -s 2

Get-ChildItem $env:APPDATA"\MikTeX" | ForEach-Object { 
$pfad = $_.FullName
write-host "editing "$pfad"\miktex\config\updmap.cfg"
$nl = [Environment]::NewLine
"Map 5ch.map"+$nl+"Map 5fp.map"+$nl+"Map 5sf.map" | Out-File $pfad"\miktex\config\updmap.cfg" -encoding ASCII
}

write-host "making maps"
initexmf --mkmaps

write-host "installation successfull" -foreground "green"
Read-Host -Prompt "Press Enter to Exit"
