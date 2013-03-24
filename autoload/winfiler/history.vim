
function! winfiler#history#add(dir)
  if w:wf_history_index < len(w:wf_history) - 1
    call remove(w:wf_history, w:wf_history_index, -1)
  endif
  if len(w:wf_history) >= g:winfiler_history_max
    call remove(w:wf_history, 0)
  endif
  call add(w:wf_history, a:dir)
  let w:wf_history_index += 1
endfunction

function! winfiler#history#clear()
  let w:wf_history = []
endfunction

function! winfiler#history#back()
  if w:wf_history_index > 0
    let w:wf_history_index -= 1
    exec ':cd ' . w:wf_history[w:wf_history_index]
  endif
endfunction

function! winfiler#history#forward()
  if w:wf_history_index < len(w:wf_history) - 1
    let w:wf_history_index += 1
    exec ':cd ' . w:wf_history[w:wf_history_index]
  endif
endfunction

