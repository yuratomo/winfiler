let s:instance = winfiler#regist('drive')
let s:MARK_ROW = 0
let s:START_LINE = 9
let s:LTR_ROW = 14
let s:volumes = []

function! s:instance.show()
  let s:volumes = filter(split(winfiler#system('echo list volume | diskpart'), '\n'), "v:val !~ '^DISKPART>'")
  call s:update(s:START_LINE, s:MARK_ROW+1)
endfunction

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

function! s:instance.select_all()
endfunction

function! s:instance.open(ln, cl)
  let line = getline(a:ln)
  if winfiler#drive_action#is_menu(line)
    call winfiler#drive_action#on(line, expand('%:p:h'))
  elseif s:is_available(line)
    call winfiler#dir#open(line[s:LTR_ROW] . ':\')
  endif
endfunction

function! s:instance.up()
endfunction

function! s:instance.toggle()
endfunction

function! s:instance.exec(ln)
  let line = getline(a:ln)
endfunction

function! s:instance.yank()
endfunction

function! s:instance.delete()
endfunction

function! s:instance.update()
endfunction

function! s:instance.status()
endfunction

function! s:instance.show_menu(ln)
endfunction

function! s:is_selectable(line)
  return s:is_available(a:line)
endfunction

function! s:is_available(line)
  if match(a:line, '^[ *] Volume [0-9]') == 0
    return 1
  endif
  return 0
endfunction

