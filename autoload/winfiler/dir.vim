let s:SORT_OPTIONS = [ 'N', 'S', 'D', 'E', 'R' ]
let [s:COMM_PROC_TYPE_COPY, s:COMM_PROC_TYPE_MOVE, s:COMM_PROC_TYPE_HARDLINK, s:COMM_PROC_TYPE_MKLINK ] = range(4)
let s:FILE_ROW = 36
let s:STATUS_ROW = 19
let s:TYPE_START_ROW = 21
let s:TYPE_END_ROW   = 25
let s:START_LINE = 5
let s:YANK_TITLE = '<< yanked files >>'
let s:instance = winfiler#regist('dir')
let s:yank_files = []
let s:option = {
  \ 'sort_type' : 0,
  \ }

function! winfiler#dir#open(dir)
  call winfiler#change_mode(s:instance.name)
  call s:cd(a:dir)
  call s:instance.show()
endfunction

"
" interfaces
"

function! s:instance.show()
  let opt = s:get_sort_option()
  let pwd = s:pwd()
  if pwd[0:1] == '\\' "for unc
    let opt .= ' "' . pwd . '"'
  endif
  let b:list = split(winfiler#system('dir /A ' . opt), '\n')[5:]

  " for toggle dir
  if !exists('w:toggle_dir')
    let w:toggle_dir = s:pwd()
  endif

  call s:update(s:START_LINE+2, s:FILE_ROW+1)
endfunction

function! s:update(l,c)
  setl modifiable
  % delete _
  let b:lines = []
  call add(b:lines, winfiler#header())
  call add(b:lines, 'Current: ' . s:pwd())
  call add(b:lines, 'Toggle:  ' . w:toggle_dir)
  call add(b:lines, '')
  call extend(b:lines, b:list)
  let b:dir_list_end = len(b:lines)
  if len(s:yank_files) > 0
    call add(b:lines, '')
    call add(b:lines, s:YANK_TITLE)
    let b:yank_list_start = len(b:lines)
    call extend(b:lines, map(copy(s:yank_files), "' - ' . v:val"))
    let b:yank_list_end   = len(b:lines)
    call extend(b:lines, winfiler#dir_action#get())
  else
    let b:yank_list_start = len(b:lines)
    let b:yank_list_end   = len(b:lines)
  endif

  call append(0, b:lines)
  setl nomodifiable
  call cursor(a:l, a:c)
endfunction

function! s:instance.select(direct, start, end)
  setl modifiable
  let idx = 0
  let lines = getline(a:start, a:end)
  let vlines = b:lines[a:start-1 : a:end-1]
  for vline in vlines
    let line = lines[idx]
    if !s:is_selectable(vline)
      let idx = idx + 1
      continue
    endif
    let mark = ''
    if line[s:FILE_ROW-1] == '*'
      let mark = ' '
    else
      let mark = '*'
    endif
    call setline(a:start + idx, line[: s:FILE_ROW-2] . mark . line[s:FILE_ROW : ])
    let idx = idx + 1
  endfor
  setl nomodifiable

  if a:direct > 0
    call cursor(a:end+1, s:FILE_ROW)
  elseif a:direct < 0
    call cursor(a:start-1, s:FILE_ROW)
  endif
endfunction

function! s:instance.open(ln, cl)
  let line = getline(a:ln)
  if a:ln-1 < len(b:lines)
    let vline = b:lines[a:ln-1]
  else
    let vline = ''
  endif
  if winfiler#dir_menu#is_menu(line, a:cl)
    let path = fnamemodify(s:file(getline(b:menu_target)), ':p')
    call winfiler#dir_menu#on(line, path)
    call s:instance.show_menu(b:menu_target)
    return
  elseif winfiler#dir_action#is_menu(line)
    call winfiler#dir_action#on(line, expand('%:p:h'))
    return
  elseif !s:is_available(vline)
    return
  endif
  let file = s:file(vline)
  let ret = filewritable(file)
  if ret == 2
    call s:cd(file)
    call s:instance.show()
    return
  endif
  silent edit `=file`
endfunction

function! s:instance.up()
  call s:cd('..')
  call s:instance.show()
endfunction

function! s:instance.toggle()
  let backup = s:pwd()
  if exists('w:toggle_dir')
    exec ':cd ' . w:toggle_dir
  endif
  let w:toggle_dir = backup
  call s:instance.show()
endfunction

function! s:instance.top()
  call cursor(s:START_LINE+2, s:FILE_ROW+1)
endfunction

function! s:instance.bottom()
  call cursor(len(b:list)+2, s:FILE_ROW+1)
endfunction

function! s:instance.toggle_sync()
  let w:toggle_dir = s:pwd()
  call s:update(line('.'), col('.'))
endfunction

function! s:instance.exec(ln)
  let line = getline(a:ln)
  if !s:is_available(line)
    return
  endif
  let file = fnamemodify(s:file(line), ':p')
  silent execute '!start rundll32 url.dll,FileProtocolHandler' file
  call winfiler#message('execute ' . file)
endfunction

function! s:instance.yank()
  let [cl, cc] = [line('.'), col('.')]
  let files = map(s:get_selected_items(), 'fnamemodify(v:val, ":p")')
  for file in files
    if index(s:yank_files, file) >= 0
      continue
    endif
    call add(s:yank_files, file)
  endfor
  call s:instance.show()
  call cursor(cl,cc)
endfunction

function! s:instance.paste()
  call winfiler#dir#copy_here()
endfunction

function! s:instance.delete()
  let [cl, cc] = [line('.'), col('.')]

  if cl < b:yank_list_start
    let items = s:get_selected_items()
    if len(items) == 0
      return
    endif

    if s:quest('Delete selected files? [y/n]:', '', '[yn]') != 'y'
      return
    endif

    for file in items
      let pwd = s:pwd()
      if isdirectory(pwd . file)
        echo winfiler#system('rmdir /S /Q ' . shellescape(pwd . file))
      else
        call delete(file)
      endif
    endfor
    call s:instance.show()
    call cursor(cl,cc)

  elseif cl > b:yank_list_start && cl <= b:yank_list_end
    call remove(s:yank_files, cl - b:yank_list_start - 1)
    call s:update(cl, cc)
  endif
endfunction

function! s:instance.rename(cl)
  let item = s:file(getline(a:cl))
  let dest = input('Rename from ' . item . ' to ...', item, 'file')
  let dest = substitute(dest, '\\ ', ' ', "g")
  if dest == '' || dest == item
    return
  endif
  if filereadable(dest)
    redraw
    echoerr dest . " is exists."
    return
  endif

  call rename(item, dest)
  call s:instance.show()
  call cursor(a:cl, s:FILE_ROW)
endfunction

function! s:instance.mkdir()
  call winfiler#dir#mkdir()
endfunction

function! s:instance.show_menu(ln)
  let selected_items =  s:get_selected_items()
  call s:update(a:ln, col('.'))
  setl modifiable
  call s:set_selected_items(selected_items)

  " If already show menu then return
  if exists('b:menu_target') && b:menu_target != -1
    call cursor(b:menu_target, s:FILE_ROW+1)
    let b:menu_target = -1
    setl nomodifiable
    return
  endif

  let l = a:ln
  for menu in winfiler#dir_menu#get()
    let line = getline(l)
    call setline(l, menu . line[s:FILE_ROW-1 : ])
    let l += 1
  endfor
  let b:menu_target = a:ln
  setl nomodifiable
  call cursor(a:ln+1, 2)
endfunction

function! s:instance.cancel()
  " If already show menu then return
  if exists('b:menu_target') && b:menu_target != -1
    let [l,c] = [line('.'), col('.')]
    let selected_items =  s:get_selected_items()
    call s:update(l,c)
    setl modifiable
    call s:set_selected_items(selected_items)
    let b:menu_target = -1
    setl nomodifiable
    return
  endif
endfunction

function! s:instance.update()
  let [l,c] = [line('.'), col('.')]
  call s:instance.show()
  call cursor(l, c)
endfunction

let s:git = 'git'
let s:svn = 'svn'
function! s:instance.status()
  if executable(s:git)
    let git_status = map(split(winfiler#system('git status -s'), "\n"), "substitute(v:val, '/.*$', '', '')")
  else
    let git_status = []
  endif
  if executable(s:svn)
    let svn_status = map(split(winfiler#system('svn stat'), "\n"), "substitute(v:val, '/.*$', '', '')")
  else
    let svn_status = []
  endif
  
  if len(svn_status) == 0 && len(git_status) == 0
    return
  endif

  let idx = s:START_LINE+1
  let vlines = b:lines[s:START_LINE : b:dir_list_end-2]
  if len(git_status) > 0
    setl modifiable
    for line in vlines
      if s:file(line) == '.' || s:file(line) == '..' || s:file(line) == ''
        let idx += 1
        continue
      endif
      let i = 0
      for item in git_status
        if item[3:] == s:file(line)
          call setline(idx, line[: s:STATUS_ROW-2] . item[0:1] . line[s:STATUS_ROW+1 : ])
          call remove(git_status, i)
          break
        endif
        let i += 1
      endfor
      let i = 0
      for item in svn_status
        if item[8:] == s:file(line)
          call setline(idx, line[: s:STATUS_ROW-2] . item[0:2] . line[s:STATUS_ROW+2 : ])
          call remove(svn_status, i)
          break
        endif
      endfor
      let i += 1
      let idx += 1
    endfor
    setl nomodifiable
  endif
endfunction

function! s:instance.history_forward()
  call winfiler#history#forward()
  call s:instance.show()
endfunction

function! s:instance.history_back()
  call winfiler#history#back()
  call s:instance.show()
endfunction

function! s:instance.openex(ln)
  call winfiler#dir#open_explorer(s:file(getline(a:ln)))
endfunction


"
" function
"

function! winfiler#dir#rename()
  call s:instance.rename(b:menu_target)
endfunction

function! winfiler#dir#delete(path)
  let file = a:path
  let ans = s:quest('Delete ' . file . '? [y/n]:', '', '[yn]')
  if ans != 'y'
    return
  endif
  if isdirectory(file)
    echo winfiler#system('rmdir /S /Q ' . shellescape(file))
  else
    call delete(file)
  endif
  call s:instance.show()
endfunction

function! winfiler#dir#mkdir()
  let dest = input('Create folder name : ', '')
  let dest = substitute(dest, '\\ ', ' ', "g")
  if dest == ''
    return
  endif
  call winfiler#system('mkdir ' . dest)
  call s:instance.show()
endfunction

function! winfiler#dir#open_explorer(path)
  silent execute '!start explorer /n,/select,' . a:path
endfunction

function! winfiler#dir#clear_yank_list()
  let s:yank_files = []
  call s:update(line('.'), col('.'))
endfunction

function! winfiler#dir#copy_here()
  if len(s:yank_files) == 0
    call winfiler#message('nothing')
    return
  endif

  let ans = s:quest('Copy yanked-files to current directory? [y/n]:', '', '[yn]')
  if ans != 'y'
    return
  endif
  call s:common_proc_here(s:COMM_PROC_TYPE_COPY)
endfunction

function! winfiler#dir#move_here()
  if len(s:yank_files) == 0
    call winfiler#message('nothing')
    return
  endif

  let ans = s:quest('Move yanked-files to current directory? [y/n]:', '', '[yn]')
  if ans != 'y'
    return
  endif
  call s:common_proc_here(s:COMM_PROC_TYPE_MOVE)
endfunction

function! s:common_proc_here(type)
    for file_path in s:yank_files
      if file_path[-1:] == "\\"
        let file_path = file_path[:-2]
      endif
      let s = strridx(file_path, "\\")
      let file = file_path[s+1 : ]

      if a:type == s:COMM_PROC_TYPE_MOVE
        let cmd = 'move /Y'
        if isdirectory(file_path)
          let fw_num = 2
        else
          let fw_num = 1
        endif
        let file1 = file_path
        let file2 = s:pwd()

      elseif a:type == s:COMM_PROC_TYPE_HARDLINK
        let cmd = 'fsutil hardlink create '
        if isdirectory(file_path)
          echoerr file_path . ' is a directory. Can not create a hardlink.'
          continue
        else
          let fw_num = 1
        endif
        let file1 = s:pwd() . file
        let file2 = file_path

      elseif a:type == s:COMM_PROC_TYPE_COPY
        if isdirectory(file_path)
          let cmd = 'xcopy /E /I /F /H /Y'
          let dest_append = file
          let fw_num = 2
        else
          let cmd = 'copy /Y'
          let dest_append = ''
          let fw_num = 1
        endif
        let file1 = file_path
        let file2 = s:pwd() . dest_append

      elseif a:type == s:COMM_PROC_TYPE_MKLINK
        if isdirectory(file_path)
          let cmd = 'mklink /D '
          let fw_num = 2
          let dest_append = file
        else
          let cmd = 'mklink '
          let dest_append = ''
          let fw_num = 1
        endif
        let file1 = s:pwd() . dest_append
        let file2 = file_path

      else
        continue
      endif

      if filewritable(s:pwd() . file) == fw_num
        let ans_override = s:quest('Already exists "' . file . '". Override? [y/n]:', '', '[yn]')
        if ans_override != 'y'
          call winfiler#message('cancel')
          continue
        endif
      endif
      echo winfiler#system(cmd . ' ' . shellescape(file1) . ' ' . shellescape(file2))
    endfor
    let s:yank_files = []
    call s:instance.show()
endfunction

function! winfiler#dir#pack_here()
  let zip = input('Input zip file name: ', '', 'file')
  if zip == ''
    return
  endif
  if zip[-3:] != 'zip'
    let zip = zip . '.zip'
  endif
  let target = s:pwd() . zip
  if filewritable(target) == 2
    echoerr "Create zip file error(2)"
    return
  endif

  let pass = input('Input password: ', '')
  if pass != ''
    let pass = '-p' . pass
  endif

  exe 'silent !start /MIN cmd /c (7z a ' . pass . ' "' . target .  '" "' . join(copy(s:yank_files), '" "') . '")'
  call s:instance.show()
endfunction

function! winfiler#dir#unpack_here()
  for file_path in s:yank_files
    if file_path[-1:] == "\\"
      continue
    endif
    exe 'silent !start /MIN cmd /c (7z x "' . file_path .  '" -o"' . s:pwd() . '")'
  endfor
  call s:instance.show()
endfunction

function! winfiler#dir#mklink_here()
  if len(s:yank_files) == 0
    call winfiler#message('nothing')
    return
  endif

  let ans = s:quest('Create symbolic link of yanked-files to current directory? [y/n]:', '', '[yn]')
  if ans != 'y'
    return
  endif
  call s:common_proc_here(s:COMM_PROC_TYPE_MKLINK)
endfunction

function! winfiler#dir#hardlink_here()
  if len(s:yank_files) == 0
    call winfiler#message('nothing')
    return
  endif

  let ans = s:quest('Create hard link of yanked-files to current directory? [y/n]:', '', '[yn]')
  if ans != 'y'
    return
  endif
  call s:common_proc_here(s:COMM_PROC_TYPE_HARDLINK)
endfunction

"
" Internal functions
"

function! s:is_selectable(line)
  if s:is_available(a:line)
    if a:line[s:FILE_ROW : ] == '..' || a:line[s:FILE_ROW : ] == '.'
      return 0
    endif
    return 1
  endif
  return 0
endfunction

function! s:is_available(line)
  if match(a:line, '[0-9]\{4\}\/[0-9]\{2\}\/[0-9]\{2\}') == 0
    return 1
  endif
  return 0
endfunction

function! s:get_selected_items()
  let idx = 0
  let files = []
  let lines = getline(s:START_LINE, b:dir_list_end)
  let vlines = b:lines[s:START_LINE-1 : b:dir_list_end-1]
  for line in lines
    if len(vlines) <= idx
      break
    endif
    let vline = vlines[idx]
    if !s:is_selectable(vline)
      let idx += 1
      continue
    endif
    if line[s:FILE_ROW-1] == '*'
      call add(files, s:file(line))
    endif
    let idx += 1
  endfor
  return files
endfunction

function! s:set_selected_items(files)
  let lines = getline(s:START_LINE, b:dir_list_end)
  let idx = s:START_LINE
  for line in lines
    if !s:is_selectable(line)
      let idx += 1
      continue
    endif
    if index(a:files, s:file(line)) >= 0
      call setline(idx, line[: s:FILE_ROW-2] . '*' . line[s:FILE_ROW : ])
    endif
    let idx += 1
  endfor
endfunction

function! s:get_sort_option()
  return '/OG' . s:SORT_OPTIONS[s:option.sort_type]
endfunction

function! s:cd(dir)
  exec ':cd ' . a:dir
  let b:last_dir = s:pwd()
  call winfiler#history#add(b:last_dir)
endfunction

function! s:pwd()
  let pwd  = expand('%:p:h')
  if pwd[-1:] != '\'
    let pwd = pwd . '\'
  endif
  return pwd
endfunction

function! s:file(line)
  let type = a:line[s:TYPE_START_ROW : s:TYPE_END_ROW]
  if type == '<SYML' || type == '<JUNC'
    let pos = match(a:line, '\[.*\.*]')
    if pos > 2
      let pos -= 2
    endif
    return a:line[s:FILE_ROW : pos]
  endif
  return a:line[s:FILE_ROW : ]
endfunction

function! s:quest(label, default, breakstr)
  let ans = ''
  while 1
    let ans = input(a:label, a:default)
    if match(ans, a:breakstr) != -1
      return ans
    endif
  endwhile
  return ans
endfunction

