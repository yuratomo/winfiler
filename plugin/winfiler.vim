"=============================================================================
" File: WinFiler.vim
" Author: yuratomo
" Last Modified: 2013.03.09
"=============================================================================
if !has('win32')
  finish
endif
command! -nargs=* -complete=dir WinFiler :call winfiler#start()
command! -nargs=* -complete=dir WinFilerControlPanel :call winfiler#switch('control')
command! -nargs=* -complete=dir WinFilerDrive :call winfiler#switch('drive')
command! -nargs=* -complete=dir WinFilerFind :call winfiler#switch('find')

if !exists('g:winfiler_history_max')
  let g:winfiler_history_max = 100
endif

if !exists('g:WinFiler_disable_default_explorer')
  augroup FileExplorer
    au!
  augroup END
  augroup _winfiler
    au!
    au BufEnter * silent! call winfiler#auto_start(expand("<amatch>"))
  augroup END
endif
