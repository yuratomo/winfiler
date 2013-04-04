let s:instance = winfiler#regist('task')
let s:MARK_ROW = 0
let s:START_LINE = 4
let s:tasklist = []

" Interfaces

function! s:instance.show()
  let vbs = winfiler#cmd_dir() . 'tasklist.vbs'
  let special_folders = []
  let s:tasklist = ['']
  call add(s:tasklist, '  Program Name                     Virtual Size     Process ID ')
  call add(s:tasklist, '  -------------------------------- ---------------- -----------')
  let result = filter(split(winfiler#system('cscript /nologo "' . vbs . '"'), '\n'), "v:val =~ ','")
  for line in result
    let items = split(line, ',')
    call add(s:tasklist, printf('  %-32s %-16s %-10d', items[0], items[2], items[1]))
  endfor

  call s:update(s:START_LINE, s:MARK_ROW+1)
endfunction

function! s:instance.update()
  call s:instance.show()
endfunction

function! s:instance.delete()
  let vbs = winfiler#cmd_dir() . 'taskkill.vbs'
  let lines = getline(s:START_LINE, line('$'))
  for line in lines
    if line[s:MARK_ROW] != '*'
      continue
    endif
    call winfiler#system('cscript /nologo "' . vbs . '" ' . substitute(line[52:], "\s\+", "", "g"))
  endfor
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

" Internal functions

function! s:update(l,c)
  setlocal modifiable
  % delete _
  call setline(1, winfiler#header())
  call setline(2, s:tasklist)
  setlocal nomodifiable
  call cursor(a:l, a:c)
endfunction

function! s:is_selectable(line)
  return s:is_available(a:line) == 1
endfunction

function! s:is_available(line)
  if line('.') > s:START_LINE
    return 1
  endif
  return 0
endfunction

