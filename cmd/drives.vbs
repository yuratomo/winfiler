Option Explicit
Dim Fso, Shell, d, param
Set Fso = CreateObject("Scripting.FileSystemObject")
For Each d in Fso.Drives
   param = Array( _
     d.DriveLetter, _
     d.VolumeName, _
     d.FileSystem, _
     d.IsReady, _
     d.AvailableSpace, _
     d.TotalSize, _
     d.ShareName _
     )
   WScript.Echo Join(param, ",")
Next
Set Shell = CreateObject("Wscript.Shell")
WScript.Echo "My Documents," & Shell.SpecialFolders("MyDocuments")
WScript.Echo "Desktop," & Shell.SpecialFolders("Desktop")
WScript.Echo "Start Menu," & Shell.SpecialFolders("StartMenu")

