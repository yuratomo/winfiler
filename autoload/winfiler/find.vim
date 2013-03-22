let s:instance = winfiler#regist('find')
let s:pattern = ''

function! s:instance.show()
  setlocal modifiable
  % delete _
  call setline(1, winfiler#header())
  call setline(2, 'Input find file pattern')
  call setline(3, '>')
  if s:pattern != ''
    call setline(4, split(winfiler#system('dir /s /b ' . s:pattern), '\n'))
  else
  endif
  setlocal nomodifiable
endfunction

function! s:instance.select(start, end, midx) range
endfunction

function! s:instance.open(ln, cl)
endfunction

function! s:instance.up()
endfunction

function! s:instance.exec(line)
endfunction

function! s:instance.yank()
endfunction

function! s:instance.delete()
endfunction

function! s:instance.update()
endfunction

function! s:instance.status()
endfunction

function! s:is_selectable(line)
endfunction

