let s:menu = []
let s:CONTEXT_MENU_TOP  = ''
let s:CONTEXT_MENU_ITEM = '-> %s'
let s:CONTEXT_MENU_BOT  = ''

function! winfiler#dir_action#get()
  let menu = []
  call add(menu, s:CONTEXT_MENU_TOP)
  for item in s:menu
    call add(menu, printf(s:CONTEXT_MENU_ITEM, item.name))
  endfor
  call add(menu, s:CONTEXT_MENU_BOT)
  return menu
endfunction

function! winfiler#dir_action#on(line, path)
  for item in s:menu
    if a:line[1:] =~ item.name
      call item.on(a:path)
      break
    endif
  endfor
endfunction

function! winfiler#dir_action#is_menu(line)
  if match(a:line, '^-> [0-9]\+\. ') == 0
    return 1
  endif
  return 0
endfunction

let s:menu_id = 0
function! s:new(name)
  let _new = {'name' : s:menu_id . '. ' . a:name}
  call add(s:menu, _new)
  let s:menu_id += 1
  return _new
endfunction

"
" MENU
"

let s:item = s:new('CLEAR YANKED LIST')
function! s:item.on(path)
  call winfiler#dir#clear_yank_list()
endfunction

let s:item = s:new('COPY TO HERE')
function! s:item.on(path)
  call winfiler#dir#copy_here()
endfunction

let s:item = s:new('MOVE TO HERE')
function! s:item.on(path)
  call winfiler#dir#move_here()
endfunction

let s:item = s:new('PACK TO HERE')
function! s:item.on(path)
  call winfiler#dir#pack_here()
endfunction

let s:item = s:new('UNPACK TO HERE')
function! s:item.on(path)
  call winfiler#dir#unpack_here()
endfunction

if executable('mklink')
  let s:item = s:new('CREATE SYMBOLIC LINK TO HERE')
  function! s:item.on(path)
    call winfiler#dir#mklink_here()
  endfunction
endif

let s:item = s:new('CREATE HARD LINK TO HERE')
function! s:item.on(path)
  call winfiler#dir#hardlink_here()
endfunction

