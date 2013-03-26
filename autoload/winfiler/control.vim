let s:instance = winfiler#regist('control')
let s:MARK_ROW = 0
let s:START_LINE = 3
let s:PATH_ROW = 34
let s:contents = []

" Interfaces

function! s:instance.show()
  let s:contents = ['']
  call add(s:contents, '  Control panel tool             Command                           ')
  call add(s:contents, '  ------------------------------ ----------------------------------')
  call add(s:contents, '  Accessibility Options          control access.cpl')
  call add(s:contents, '  Admin tools                    control admintools')
  call add(s:contents, '  Add New Hardware               control sysdm.cpl add new hardware')
  call add(s:contents, '  Add/Remove Programs            control appwiz.cpl')
  call add(s:contents, '  Date/Time Properties           control DATE/TIME')
  call add(s:contents, '  Display Properties             control desktop')
  call add(s:contents, '  FindFast                       control findfast.cpl')
  call add(s:contents, '  Folder Options                 control FOLDERS')
  call add(s:contents, '  Fonts Folder                   control FONTS')
  call add(s:contents, '  Firewall                       control Firewall.cpl')
  call add(s:contents, '  Internet Properties            control inetcpl.cpl')
  call add(s:contents, '  Joystick Properties            control joy.cpl')
  call add(s:contents, '  Keyboard Properties            control keyboard')
  call add(s:contents, '  Modem Properties               control modem.cpl')
  call add(s:contents, '  Mouse Properties               control main.cpl')
  call add(s:contents, '  Multimedia Properties          control mmsys.cpl')
  call add(s:contents, '  Network Properties             control NETCONNECTIONS')
  call add(s:contents, '  Password Properties            control USERPASSWORDS')
  call add(s:contents, '  Power Management (Windows 98)  control powercfg.cpl')
  call add(s:contents, '  Printers Folder                control printers')
  call add(s:contents, '  Regional Settings              control intl.cpl')
  call add(s:contents, '  Scanners and Cameras           control sticpl.cpl')
  call add(s:contents, '  Sound Properties               control mmsys.cpl sounds')
  call add(s:contents, '  System Properties              control sysdm.cpl')
  call add(s:contents, '  Security                       control wscui.cpl')
  call add(s:contents, '  Device Manager                 rundll32 url.dll,FileProtocolHandler devmgmt.msc')
  call add(s:contents, '  Eject Removable Disk           control hotplug.dll')
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

