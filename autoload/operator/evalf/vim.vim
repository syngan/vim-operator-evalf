let s:save_cpo = &cpo
set cpo&vim

function! operator#inserttext#vim#eval(str, ...) abort
  if a:str[len(a:str)-1] =~ '\n'
    return eval(a:str[0: -2])
  else
    return eval(a:str)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
