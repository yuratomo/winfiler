"=============================================================================
" File: WinFiler.vim
" Author: yuratomo
" Last Modified: 2013.03.09
"=============================================================================
if !has('win32')
  finish
endif
command! -nargs=* -complete=dir WinFiler :call winfiler#start()

"if !exists('g:Lfiler_disable_default_explorer')
  augroup FileExplorer
    au!
  augroup END
  augroup _winfiler
    au!
    au BufEnter * silent! call winfiler#auto_start(expand("<amatch>"))
  augroup END
"endif
