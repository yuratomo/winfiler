let [ s:MODE_DRIVE, s:MODE_DIR, s:MODE_COUNT ] = range(3)
let s:TITLE = 'winfiler'
let s:DEFAULT = 'dir'
let s:modes = {}

let rtp = split(&runtimepath, ',')
let rtp = filter(rtp, 'v:val =~ "winfiler"')
let s:cmd_dir = rtp[0] . '\cmd\'

function! winfiler#cmd_dir()
  return s:cmd_dir
endfunction

function! winfiler#auto_start(path)
  if isdirectory(a:path)
    call winfiler#start()
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

" TODO ヘッダはいらないかな・・・
function! winfiler#header()
  return '<< winfiner >>         '
    \ . substitute(' ' . join(keys(s:modes), '  ') . ' ', ' ' . b:mode.name . ' ', '[' . b:mode.name . ']', '')
    \ . '                                                            '
endfunction

function! winfiler#show_menu()
  call b:mode.show_menu(line('.'))
endfunction

function! winfiler#update()
  call b:mode.update()
endfunction

function! winfiler#message(msg)
  redraw
  if a:msg != ''
    echom 'winfiler: ' . a:msg
  endif
endfunction

function! winfiler#switch()
  let keys = keys(s:modes)
  if b:mode.name == 'drive'
    let mode = s:MODE_DIR
  else
    let mode = s:MODE_DRIVE
  endif
  let b:mode = s:modes[keys[mode]]
  call b:mode.show()
endfunction

function! winfiler#status()
  call b:mode.status()
endfunction

function! winfiler#select(direct) range
  call b:mode.select(a:direct, a:firstline, a:lastline)
endfunction

function! winfiler#select_all()
  call b:mode.select_all()
endfunction

function! winfiler#open()
  call b:mode.open(line('.'), col('.'))
endfunction

function! winfiler#up()
  call b:mode.up()
endfunction

function! winfiler#toggle()
  call b:mode.toggle()
endfunction

function! winfiler#exec()
  call b:mode.exec(line('.'))
endfunction

function! winfiler#yank()
  call b:mode.yank()
endfunction

function! winfiler#delete()
  call b:mode.delete()
endfunction

" Internal functions

function! winfiler#prepare()
  " for toggle dir
  if !exists('b:toggle_dir')
    let toggle_dir = getbufvar(bufnr('#'), "toggle_dir")
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
  nnoremap <buffer> D         :call winfiler#delete()<CR>
  nnoremap <buffer> c         :call winfiler#show_menu()<CR>
  nnoremap <buffer> u         :call winfiler#update()<CR>
  nnoremap <buffer> a         :call winfiler#select_all()<CR>
  nnoremap <buffer> q         :call winfiler#switch()<CR>
  nnoremap <buffer> s         :call winfiler#status()<CR>

  if toggle_dir != ''
    let b:toggle_dir = toggle_dir
    echo b:toggle_dir
  else
    let b:toggle_dir = s:pwd()
  endif

  let b:mode = s:modes[s:DEFAULT]
endfunction

" Load modes

let files = split(globpath(&runtimepath, 'autoload/winfiler/*.vim'), '\n')
for file in files
  if file !~ '.*menu.vim$' && file !~ '.*action.vim$'
    exe 'so ' . file
  endif
endfor

