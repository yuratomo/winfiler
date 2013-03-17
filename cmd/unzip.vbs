Dim ZipFile, ExtractTo, Fso, Shell, Zip, Folder

If WScript.Arguments.Count <> 2 Then WScript.Quit

ZipFile = Wscript.Arguments(0)
ExtractTo = Wscript.Arguments(1)

Set Fso = CreateObject("Scripting.FileSystemObject")
If Not Fso.FolderExists(ExtractTo) Then
   Fso.CreateFolder(ExtractTo)
End If

Set Shell = CreateObject("Shell.Application")
Set Zip = Shell.NameSpace(ZipFile).items
Set Folder = Shell.NameSpace(ExtractTo)
If (Not Folder Is Nothing) Then
  Folder.CopyHere Zip, H00 
End If

Set Fso = Nothing
Set Shell = Nothing
Set Folder = Nothing
Set Zip = Nothing
