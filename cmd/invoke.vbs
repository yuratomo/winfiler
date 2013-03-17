If WScript.Arguments.Count<>2 Then WScript.Quit

Set Shell = CreateObject("Shell.Application") 
Set Fso = CreateObject("Scripting.FileSystemObject")

find = False
first = True
For i = 0 to 10
  For Each win In Shell.Windows() 
    If win.ReadyState<>4 Then
    ElseIf win.Busy Then
    ElseIf InStr(TypeName(win.Document),"IShellFolderViewDual") Then
      find = True
      Exit For 
    End If
  Next 
  If find = True Then
    Exit For
  else
    If first = True Then
      CreateObject("WScript.Shell").Run "explorer.exe",0,True 
      first = False
    End If
    WScript.Sleep 100 
  End If
Next 
If IsEmpty(win) Then
  WScript.Quit 
End If

Set ieApp = win.Document.Application 
strTarget = Wscript.Arguments(1)
strPath = Fso.GetParentFolderName(strTarget)
strFile = Fso.GetFileName(strTarget)
call ieApp.NameSpace(strPath).ParseName(strFile).InvokeVerb(Wscript.Arguments(0))
