scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:_kname(key) abort " {{{
  return a:key
endfunction " }}}

function! s:append(dict, key, value) abort " {{{
" @return 1 if key is invalid (empty-string)
  let key = s:_kname(a:key)
  if key ==# ''
    return 1
  endif
  let a:dict[key] = a:value
endfunction " }}}

function! s:_remove(dict, key) abort " {{{
  unlet a:dict[a:key]
  return 0
endfunction " }}}

function! s:remove(dict, ...) abort " {{{
" removes elements from {dict}.
" Note: candict#remove(d, '') removes all elements from d
" @return number of removed elements
  let keys = call(function('s:keys'), [a:dict] + a:000)
  let n = len(keys)
  call map(keys, 's:_remove(a:dict, v:val)')
  return n
endfunction " }}}

function! s:keys(dict, ...) abort " {{{
" keys(dict [, key, [flag]])
" @return candidates which start with a:key
  if a:0 == 0
    return keys(a:dict)
  endif
  let key = s:_kname(a:1)
  let ks = keys(a:dict)
  return filter(ks, 'v:val =~# key')
endfunction " }}}

function! s:values(dict, ...) abort " {{{
" @return dict[a:key] if a:key is defined, candidates otherwise
  let keys = call(function('s:keys'), [a:dict] + a:000)
  return map(copy(keys), 'a:dict[v:val]')
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
