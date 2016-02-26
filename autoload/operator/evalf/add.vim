let s:save_cpo = &cpo
set cpo&vim

function! operator#evalf#add#eval(str, ...)
  let s = a:str
  let ret = 0.0
  let pat = '[-+]\=[0-9]\+\(\.[0-9]\+\)\=\(e[-+][0-9]\+\)\='
  let idx = 0
  while 1
    let idx = match(s, pat, idx)
    if idx < 0
      return string(ret)
    endif
    let val = matchstr(s, pat, idx)
    let ret += str2float(val)

    let idx += len(val)
  endwhile
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
