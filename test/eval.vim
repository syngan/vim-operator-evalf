scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('eval')
let s:assert = themis#helper('assert')

function! s:suite.add()
  let F = function("operator#inserttext#add#eval")
  call s:assert.equals(F('1 2 3'), 6)
  call s:assert.equals(F('1+2+3'), 6)
  call s:assert.equals(F('|1|2|3|'), 6)
  call s:assert.equals(F("1\n2\n3\n"), 6)
  call s:assert.equals(F('1 -2 +3 4'), 6)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
