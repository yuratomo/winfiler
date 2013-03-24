let s:instance = winfiler#regist('drive')
let s:MARK_ROW = 0
let s:START_LINE = 4
let s:LTR_ROW = 2
let s:PATH_ROW = 24
let s:volumes = []

" Interfaces

function! s:instance.show()
  let vbs = winfiler#cmd_dir() . 'drives.vbs'
  let special_folders = []
  let s:volumes = ['']
  call add(s:volumes, '  Ltr Label            Fs       Size(MB) Free(MB) Status    ')
  call add(s:volumes, '  --- ---------------- -------- -------- -------- ----------')
  let result = filter(split(winfiler#system('cscript "' . vbs . '"'), '\n'), "v:val =~ ','")
  for line in result
    let items = split(line, ',')
    if len(items) >= 7
      let label = items[6]
    elseif len(items) >= 6
      let label = items[1]
    else
      call add(special_folders, items)
      continue
    endif
    if items[3] == 'True'
      let status = 'Ready'
    else
      let status = 'Not Ready'
    endif
    call add(s:volumes, printf('  %1s:  %-16s %-8s %-8d %-8d %s', items[0], label, items[2], items[4]/1024/1024, items[5]/1024/1024, status))
  endfor
  call add(s:volumes, '')
  call add(s:volumes, '  Label                Path                                 ')
  call add(s:volumes, '  -------------------- -------------------------------------')
  call add(s:volumes, '  System Root          ' . $SystemRoot)
  call add(s:volumes, '  Program Files        ' . $ProgramFiles)
  call add(s:volumes, '  User Profile         ' . $USERPROFILE)
  call add(s:volumes, '  Application Data     ' . $APPDATA)
  for folder in special_folders
    call add(s:volumes, printf('  %-20s %s', folder[0], folder[1]))
  endfor
  call add(s:volumes, '  Vim Directory        ' . $VIM)

  call s:update(s:START_LINE, s:MARK_ROW+1)
endfunction

function! s:instance.update()
  call s:instance.show()
endfunction

function! s:instance.select(direct, start, end) range
  let cc = col('.')
  setlocal modifiable
  let idx = a:start
  let lines = getline(a:start, a:end)
  for line in lines
    if !s:is_selectable(line)
      let idx = idx + 1
      continue
    endif
    let mark = ''
    if line[s:MARK_ROW] == '*'
      let mark = ' '
    else
      let mark = '*'
    endif
    call setline(idx, mark . line[s:MARK_ROW+1 : ])
    let idx = idx + 1
  endfor
  setlocal nomodifiable

  if a:direct > 0
    call cursor(a:end+1, cc)
  elseif a:direct < 0
    call cursor(a:start-1, cc)
  endif
endfunction

function! s:instance.open(ln, cl)
  let line = getline(a:ln)
  if winfiler#drive_action#is_menu(line)
    call winfiler#drive_action#on(line, expand('%:p:h'))
  elseif s:is_available(line) == 1
    call winfiler#dir#open(line[s:LTR_ROW] . ':\')
  elseif s:is_available(line) == 2
    call winfiler#dir#open(line[s:PATH_ROW-1 : ])
  endif
endfunction

" Internal functions

function! s:update(l,c)
  setlocal modifiable
  % delete _
  call setline(1, winfiler#header())
  call setline(2, s:volumes)
  call setline(line('$')+1, winfiler#drive_action#get())
  call setline(line('$')+1, '')
  setlocal nomodifiable
  call cursor(a:l, a:c)
endfunction

function! s:is_selectable(line)
  return s:is_available(a:line) == 1
endfunction

function! s:is_available(line)
  if match(a:line, '^[ *] [A-Z]:') == 0
    return 1
  endif
  if match(a:line, '^.\{' . (s:PATH_ROW-1) . '\}[A-Z]:') == 0
    return 2
  endif
  return 0
endfunction

