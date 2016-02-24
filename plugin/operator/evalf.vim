
let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_operator_evalf') && g:loaded_operator_evalf
  finish
endif

call operator#user#define('evalf', 'operator#evalf#do')

let g:loaded_operator_evalf = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
