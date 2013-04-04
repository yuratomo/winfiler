Set wp  = GetObject( "winmgmts:{impersonationLevel=impersonate}").ExecQuery( "Select * From Win32_Process", , 48 )
Set fso = WScript.CreateObject("Scripting.FileSystemObject")

For Each p in wp
  insert_list = True
  If WScript.Arguments.Count > 1 Then
    if InStr(p.Name, WScript.Arguments(1)) = 0 Then
      insert_list = False
    End if
  End if
  If insert_list = True Then
    If p.GetOwner( user, domain ) = 0 Then
      If user <> "SYSTEM" And InStr (user , "SERVICE") = 0 Then
        WScript.Echo p.name & "," & p.ProcessId & "," & p.VirtualSize
      End If
    End If
  End If
Next

Set fso = Nothing
Set wp  = Nothing
