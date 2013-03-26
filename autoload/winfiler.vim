let s:TITLE = 'winfiler'
let s:DEFAULT = 'dir'
let s:modes = {}

function! winfiler#cmd_dir()
  return s:cmd_dir
endfunction

function! winfiler#auto_start(path)
  if exists('b:last_dir')
    exec ':cd ' . b:last_dir
  elseif isdirectory(a:path)
    call winfiler#start()
    let b:last_dir = s:pwd()
  endif
endfunction

function! winfiler#start()
  call winfiler#prepare()
  call b:mode.show()
endfunction

function! winfiler#regist(name)
  let instance = {'name':a:name}
  let s:modes[a:name] = instance
  return instance
endfunction

function! winfiler#system(cmd)
  return iconv(system(a:cmd), 'cp932', &enc)
endfunction

function! winfiler#change_mode(mode)
  if has_key(s:modes, a:mode)
    let b:mode = s:modes[a:mode]
  endif
endfunction

function! winfiler#header()
  return '<< winfiner >>   mode=' . b:mode.name . ' refine='
endfunction

function! winfiler#show_menu()
  if has_key(b:mode, 'show_menu')
    call b:mode.show_menu(line('.'))
  endif
endfunction

function! winfiler#update()
  if has_key(b:mode, 'update')
    call b:mode.update()
  endif
endfunction

function! winfiler#message(msg)
  redraw
  if a:msg != ''
    echom 'winfiler: ' . a:msg
  endif
endfunction

function! winfiler#switch(mode)
  call winfiler#prepare()
  if a:mode == b:mode.name
    let b:mode = s:modes[s:DEFAULT]
  else
    let b:mode = s:modes[a:mode]
  endif
  call b:mode.show()
endfunction

function! winfiler#status()
  if has_key(b:mode, 'status')
    call b:mode.status()
  endif
endfunction

function! winfiler#select(direct) range
  if has_key(b:mode, 'select')
    call b:mode.select(a:direct, a:firstline, a:lastline)
  endif
endfunction

function! winfiler#select_all()
  if has_key(b:mode, 'select')
    let [l,c] = [line('.'), col('.')]
    call b:mode.select(1, 1, line('$'))
    call cursor(l, c)
  endif
endfunction

function! winfiler#open()
  if has_key(b:mode, 'open')
    call b:mode.open(line('.'), col('.'))
  endif
endfunction

function! winfiler#up()
  if has_key(b:mode, 'up')
    call b:mode.up()
  endif
endfunction

function! winfiler#toggle()
  if has_key(b:mode, 'toggle')
    call b:mode.toggle()
  endif
endfunction

function! winfiler#toggle_sync()
  if has_key(b:mode, 'toggle_sync')
    call b:mode.toggle_sync()
  endif
endfunction

function! winfiler#exec()
  if has_key(b:mode, 'exec')
    call b:mode.exec(line('.'))
  endif
endfunction

function! winfiler#yank()
  if has_key(b:mode, 'yank')
    call b:mode.yank()
  endif
endfunction

function! winfiler#paste()
  if has_key(b:mode, 'paste')
    call b:mode.paste()
  endif
endfunction

function! winfiler#delete()
  if has_key(b:mode, 'delete')
    call b:mode.delete()
  endif
endfunction

function! winfiler#rename()
  if has_key(b:mode, 'rename')
    call b:mode.rename(line('.'))
  endif
endfunction

function! winfiler#history_forward()
  if has_key(b:mode, 'history_forward')
    call b:mode.history_forward()
  endif
endfunction

function! winfiler#history_back()
  if has_key(b:mode, 'history_back')
    call b:mode.history_back()
  endif
endfunction

" Internal functions

function! winfiler#prepare()
  if bufname('%') =~ '^' . s:TITLE
    return
  endif

  let id = 1
  while buflisted(s:TITLE . '-' . id)
    let id += 1
  endwhile
  let bufname = s:TITLE . '-' . id
  silent edit `=bufname`
  setl bt=nofile noswf nowrap hidden nolist nomodifiable ft=winfiler
  hi link winfilerMenuSelect PmenuSel

  nnoremap <buffer> <SPACE>   :call winfiler#select(1)<CR>
  vnoremap <buffer> <SPACE>   :call winfiler#select(1)<CR>
  nnoremap <buffer> <S-SPACE> :call winfiler#select(-1)<CR>
  vnoremap <buffer> <S-SPACE> :call winfiler#select(-1)<CR>
  nnoremap <buffer> <RETURN>  :call winfiler#open()<CR>
  nnoremap <buffer> <BS>      :call winfiler#up()<CR>
  nnoremap <buffer> <TAB>     :call winfiler#toggle()<CR>
  nnoremap <buffer> x         :call winfiler#exec()<CR>
  nnoremap <buffer> y         :call winfiler#yank()<CR>
  nnoremap <buffer> p         :call winfiler#paste()<CR>
  nnoremap <buffer> D         :call winfiler#delete()<CR>
  nnoremap <buffer> r         :call winfiler#rename()<CR>
  nnoremap <buffer> c         :call winfiler#show_menu()<CR>
  nnoremap <buffer> u         :call winfiler#update()<CR>
  nnoremap <buffer> a         :call winfiler#select_all()<CR>
  nnoremap <buffer> s         :call winfiler#status()<CR>
  nnoremap <buffer> o         :call winfiler#toggle_sync()<CR>
  nnoremap <buffer> <c-n>     :call winfiler#history_forward()<CR>
  nnoremap <buffer> <c-p>     :call winfiler#history_back()<CR>
  nnoremap <buffer> <c-f>     :call winfiler#switch('find')<CR>
  nnoremap <buffer> <c-c>     :call winfiler#switch('control')<CR>
  nnoremap <buffer> <c-l>     :call winfiler#switch('drive')<CR>

  let b:mode = s:modes[s:DEFAULT]

  if !exists('w:wf_history')
    let w:wf_history = []
    let w:wf_history_index = -1
  endif
  call winfiler#history#add(s:pwd())
endfunction

function! s:pwd()
  let pwd  = expand('%:p:h')
  if pwd[-1:] != '\'
    let pwd = pwd . '\'
  endif
  return pwd
endfunction


" Resolve cmd path

let rtp = split(&runtimepath, ',')
let rtp = filter(rtp, 'v:val =~ "winfiler"')
let s:cmd_dir = rtp[0] . '\cmd\'

" Load modes

let files = split(globpath(&runtimepath, 'autoload/winfiler/*.vim'), '\n')
for file in files
  if file !~ '.*menu.vim$' && file !~ '.*action.vim$'
    exe 'so ' . file
  endif
endfor

