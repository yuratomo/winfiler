If WScript.Arguments.Count = 1 Then
  Set wp = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_Process where ProcessId='" & WScript.Arguments(0) & "'")
  for each p in wp
    p.terminate
  Next
  Set wp = Nothing
End if
