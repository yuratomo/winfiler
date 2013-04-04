let s:instance = winfiler#regist('tools')
let s:MARK_ROW = 0
let s:START_LINE = 3
let s:PATH_ROW = 34
let s:contents = []

" Interfaces

function! s:instance.show()
  let s:contents = ['']
  call add(s:contents, '  Tools                          Command                           ')
  call add(s:contents, '  ------------------------------ ----------------------------------')
  call add(s:contents, '  Command Prompt                 cmd.exe')
  call add(s:contents, '  Notepad                        notepad.exe')
  call add(s:contents, '  Calculator                     calc.exe')
  call add(s:contents, '  MS paint                       mspaint.exe')
  call add(s:contents, '  Media Player                   wmplayer.exe')
  call add(s:contents, '  Internet Explorer              iexplore.exe')
  call add(s:contents, '  Remote Desktop                 mstsc.exe')
  call add(s:contents, '  Task Manager                   taskmgr.exe')
  call add(s:contents, '  Registry Editor                regedit.exe')
  call add(s:contents, '  On screen keyboard             osk.exe')
  call add(s:contents, '  Performance Monitor            perfmon.exe /res')
  call add(s:contents, '  Disk Cleanup                   cleanmgr.exe')
  call add(s:contents, '  Mobile Syncronization          mobsync.exe')
  call add(s:contents, '')
  call add(s:contents, '  Development Tools              Command                           ')
  call add(s:contents, '  ------------------------------ ----------------------------------')
  call add(s:contents, '  Windows SDKs                   cmd /E:ON /V:ON /T:0E /K SetEnv.cmd')
  call add(s:contents, '  WDK 7.1 Check Build x64        cmd /k C:\WinDDK\7600.16385.1\bin\setenv.bat C:\WinDDK\7600.16385.1\ chk x64 WIN7')
  call add(s:contents, '  WDK 7.1 Free  Build x64        cmd /k C:\WinDDK\7600.16385.1\bin\setenv.bat C:\WinDDK\7600.16385.1\ fre x64 WIN7')
  call add(s:contents, '  ')
  call s:update(s:START_LINE, s:MARK_ROW+1)
endfunction

function! s:instance.open(ln, cl)
  call s:instance.exec(a:ln)
endfunction

function! s:instance.exec(ln)
  let line = getline(a:ln)
  if s:is_available(line) == 1
    exe 'silent !start ' . line[s:PATH_ROW-1 : ]
  endif
endfunction

" Internal functions

function! s:update(l,c)
  setlocal modifiable
  % delete _
  call setline(1, winfiler#header())
  call setline(2, s:contents)
  call setline(line('$')+1, '')
  setlocal nomodifiable
  call cursor(a:l, a:c)
endfunction

function! s:is_selectable(line)
  return s:is_available(a:line)
endfunction

function! s:is_available(line)
  if match(a:line[ s:PATH_ROW : ], '^Command') != -1
    return 0
  endif
  if match(a:line[ s:PATH_ROW : ], '^-') != -1
    return 0
  endif
  return 1
endfunction

