Dim ZipFile, EmptyData, Fso, Shell, Handle, Zip

If WScript.Arguments.Count < 2 Then WScript.Quit

ZipFile = Wscript.Arguments(0)

Set Fso = WScript.CreateObject("Scripting.FileSystemObject")
Set Shell = WScript.CreateObject("Shell.Application")

Set Handle = Fso.CreateTextFile( ZipFile, True )
EmptyData = Chr(&H50) & Chr(&H4B) & Chr(&H5) & Chr(&H6)
EmptyData = EmptyData & String( 18, Chr(0) )
Handle.Write EmptyData
Handle.Close

Set Zip = Shell.NameSpace(ZipFile)
For idx=1 to WScript.Arguments.Count-1
    Call Zip.CopyHere( WScript.Arguments(idx), 0 )
Next

do until Zip.Items().Count = WScript.Arguments.Count - 1
  WScript.Sleep 300
loop

Set Fso = Nothing
Set Shell = Nothing
Set Handle = Nothing
Set Zip = Nothing
