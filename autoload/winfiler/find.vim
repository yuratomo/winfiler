let s:instance = winfiler#regist('find')
let s:pattern = ''

function! s:instance.show()
  redraw
  let s:pattern = input('Input find file pattern:', '')
  if s:pattern != ''
    let b:contents = map(split(winfiler#system('dir /s /b ' . s:pattern), '\n'), '"  " . v:val')
  endif
  call s:instance.update()
endfunction

function! s:instance.update()
  setlocal modifiable
  % delete _
  call setline(1, winfiler#header())
  call setline(2, 'PATTERN: ' . s:pattern)
  call setline(3, '')
  call setline(4, b:contents)
  call setline(line('$'), '')
  setlocal nomodifiable
endfunction

function! s:instance.open(ln, cl)
endfunction

function! s:instance.exec(line)
endfunction

function! s:instance.yank()
endfunction

function! s:instance.select(direct, start, end)
  setlocal modifiable
  let idx = 0
  let lines = getline(a:start, a:end)
  for line in lines
    if !s:is_selectable(line)
      let idx = idx + 1
      continue
    endif
    let mark = ''
    if line[0] == '*'
      let mark = ' '
    else
      let mark = '*'
    endif
    call setline(a:start + idx, mark . line[1 : ])
    let idx = idx + 1
  endfor
  setlocal nomodifiable

  if a:direct > 0
    call cursor(a:end+1, 3)
  elseif a:direct < 0
    call cursor(a:start-1, 3)
  endif
endfunction

" Internal functions

function! s:is_selectable(line)
  return s:is_available(a:line)
endfunction

function! s:is_available(line)
  if match(a:line, '[ \*] .:') == 0
    return 1
  endif
  return 0
endfunction

