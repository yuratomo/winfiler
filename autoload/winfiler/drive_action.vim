let s:menu = []
let s:CONTEXT_MENU_TOP  = ''
let s:CONTEXT_MENU_ITEM = '-> %s'
let s:CONTEXT_MENU_BOT  = ''

function! winfiler#drive_action#get()
  let menu = []
  call add(menu, s:CONTEXT_MENU_TOP)
  for item in s:menu
    call add(menu, printf(s:CONTEXT_MENU_ITEM, item.name))
  endfor
  call add(menu, s:CONTEXT_MENU_BOT)
  return menu
endfunction

function! winfiler#drive_action#on(line, path)
  for item in s:menu
    if a:line[1:] =~ item.name
      call item.on(a:path)
      break
    endif
  endfor
endfunction

function! winfiler#drive_action#is_menu(line)
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

let s:item = s:new('Eject volume')
function! s:item.on(path)
  silent execute '!start control.exe hotplug.dll'
  call winfiler#message('open hotplug...')
endfunction

let s:item = s:new('Open trush')
function! s:item.on(path)
  silent execute '!start Explorer.exe /e, ::{645FF040-5081-101B-9F08-00AA002F954E}'
  call winfiler#message('open trush...')
endfunction

