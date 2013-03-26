let s:menu = []
let s:menu_in = 0
let s:CONTEXT_MENU_TOP  = '+--------------------------------->'
let s:CONTEXT_MENU_ITEM = '|%-30s|   '
let s:CONTEXT_MENU_BOT  = '+------------------------------+   '

au! CursorMoved winfiler-*  call s:cursor_moved()

function! s:cursor_moved()
  let [l, c] = [line('.'), col('.')]
  let line = getline('.')
  if s:menu_in == 1
    call clearmatches()
  endif
  if c > 0 && c < 31 && match(line, '^|.\{30\}|  ') == 0
    call matchadd('winfilerMenuSelect', '^|.\{30\}|\%' . l . 'l')
    let s:menu_in = 1
  else
    let s:menu_in = 0
  endif
endfunction

function! winfiler#dir_menu#get()
  let menu = []
  call add(menu, s:CONTEXT_MENU_TOP)
  for item in s:menu
    call add(menu, printf(s:CONTEXT_MENU_ITEM, item.name))
  endfor
  call add(menu, s:CONTEXT_MENU_BOT)
  return menu
endfunction

function! winfiler#dir_menu#on(line, path)
  for item in s:menu
    if a:line[1:] =~ item.name
      call item.on(a:path)
      break
    endif
  endfor
endfunction

function! winfiler#dir_menu#is_menu(line, col)
  if a:col >= 1 && a:col <= 32 && match(a:line, '^|.\{30\}|  ') == 0
    return 1
  endif
  return 0
endfunction

function! s:new(name)
  let _new = {'name' : a:name}
  call add(s:menu, _new)
  return _new
endfunction

"
" MENU
"

let s:item = s:new('OPEN NEW TAB')
function! s:item.on(path)
  tabedit `=a:path`
  normal gT
endfunction

let s:item = s:new('EXECUTE')
function! s:item.on(path)
  silent execute '!start rundll32 url.dll,FileProtocolHandler' a:path
endfunction

let s:item = s:new('PROPERTY')
function! s:item.on(path)
  let vbs = winfiler#cmd_dir() . 'invoke.vbs'
  exe 'silent !start /MIN cmd /c ("' . vbs . '" properties "' . a:path . '")'
endfunction

let s:item = s:new('OPEN EXPLORER')
function! s:item.on(path)
  silent execute '!start explorer /n,/select,' . a:path
endfunction

let s:item = s:new('COPY PATH TO CLIPBOARD')
function! s:item.on(path)
  call setreg('*', a:path)
endfunction

let s:item = s:new('RENAME')
function! s:item.on(path)
  call winfiler#dir#rename()
endfunction

let s:item = s:new('DELETE FILE OR FOLDER')
function! s:item.on(path)
  call winfiler#dir#delete(a:path)
endfunction

let s:item = s:new('CREATE FOLDER')
function! s:item.on(path)
  call winfiler#dir#mkdir(a:path)
endfunction

"let s:item = s:new('ADD BOOKMARK')
"function! s:item.on(path)
"  echoerr 'not support now'
"endfunction

let s:git = 'TortoiseGitProc'
if executable(s:git)
  let s:item = s:new('======== TORTOISE GIT ========')
  function! s:item.on(path)
  endfunction

  let s:item = s:new('GIT LOG')
  function! s:item.on(path)
    call s:git_command('log', '')
  endfunction

  let s:item = s:new('GIT ADD')
  function! s:item.on(path)
    call s:git_command('add', ' /path:"' . a:path . '"')
  endfunction

  let s:item = s:new('GIT DIFF')
  function! s:item.on(path)
    call s:git_command('diff', ' /path:"' . a:path . '"')
  endfunction

  let s:item = s:new('GIT CLONE')
  function! s:item.on(path)
    call s:git_command('clone', '')
  endfunction

  let s:item = s:new('GIT BRANCH')
  function! s:item.on(path)
    call s:git_command('branch', '')
  endfunction

  let s:item = s:new('GIT CHECKOUT')
  function! s:item.on(path)
    call s:git_command('switch', '')
  endfunction

  let s:item = s:new('GIT COMMIT')
  function! s:item.on(path)
    call s:git_command('commit', ' /path:"' . a:path . '"')
  endfunction

  let s:item = s:new('GIT PULL')
  function! s:item.on(path)
    call s:git_command('pull', '')
  endfunction

  let s:item = s:new('GIT PUSH')
  function! s:item.on(path)
    call s:git_command('push', '')
  endfunction

  function! s:git_command(cmd, opt)
    silent execute '!start ' . s:git . ' /command:' . a:cmd . a:opt
  endfunction

endif

let s:svn = 'TortoiseProc'
if executable(s:svn)
  let s:item = s:new('======== TORTOISE SVN ========')
  function! s:item.on(path)
  endfunction

  let s:item = s:new('SVN LOG')
  function! s:item.on(path)
    call s:svn_command('log', '')
  endfunction

  let s:item = s:new('SVN DIFF')
  function! s:item.on(path)
    call s:svn_command('diff', ' /path:"' . a:path . '"')
  endfunction

  let s:item = s:new('SVN CHECKOUT')
  function! s:item.on(path)
    call s:svn_command('checkout', '')
  endfunction

  let s:item = s:new('SVN EXPORT')
  function! s:item.on(path)
    call s:svn_command('export', '')
  endfunction

  let s:item = s:new('SVN ADD')
  function! s:item.on(path)
    call s:svn_command('add', '')
  endfunction

  let s:item = s:new('SVN COMMIT')
  function! s:item.on(path)
    call s:svn_command('commit', ' /path:"' . a:path . '"')
  endfunction

  function! s:svn_command(cmd, opt)
    silent execute '!start ' . s:svn . ' /command:' . a:cmd . a:opt
  endfunction
endif

