
let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_operator_inserttext') && g:loaded_operator_inserttext
  finish
endif

call operator#user#define('inserttext', 'operator#inserttext#do')

let g:loaded_operator_inserttext = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
