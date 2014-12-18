scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:suite = themis#suite('add')
let s:assert = themis#helper('assert')

function! s:suite.before()
  map <expr> sz <Plug>(operator-inserttext)
endfunction

function! s:suite.before_each()
  new
endfunction

function! s:suite.after_each()
  quit!
endfunction


function! s:suite.eval()
  let F = function("operator#inserttext#add#eval")
  call s:assert.equals(F('1 2 3'), 6)
  call s:assert.equals(F('1+2+3'), 6)
  call s:assert.equals(F('|1|2|3|'), 6)
  call s:assert.equals(F("1\n2\n3\n"), 6)
  call s:assert.equals(F('1 -2 +3 4'), 6)
endfunction

function! s:suite.add0()
  let str = "|1|2|3|4|5|"
  call setline(1, str)
  execute 'normal' "ggV\<Plug>(operator-inserttext)add\<CR>"
  call s:assert.equals(getline(1), '15.0')
endfunction

function! s:suite.addp()
  let str = "|1|2|3|4|5|"
  call setline(1, str)
  execute 'normal' "ggV\<Plug>(operator-inserttext)add+\<CR>"
  call s:assert.equals(getline(1), str)
  call s:assert.equals(getline(2), '15.0')
endfunction

function! s:suite.padd()
  let str = "|1|2|3|4|5|"
  call setline(1, str)
  execute 'normal' "ggV\<Plug>(operator-inserttext)+add\<CR>"
  call s:assert.equals(getline(1), str)
  call s:assert.equals(getline(2), '15.0')
endfunction

function! s:suite.addm()
  let str = "|1|2|3|4|5|"
  call setline(1, str)
  execute 'normal' "ggV\<Plug>(operator-inserttext)add-\<CR>"
  call s:assert.equals(getline(1), '15.0')
  call s:assert.equals(getline(2), str)
endfunction

function! s:suite.madd()
  let str = "|1|2|3|4|5|"
  call setline(1, str)
  execute 'normal' "ggV\<Plug>(operator-inserttext)-add\<CR>"
  call s:assert.equals(getline(1), '15.0')
  call s:assert.equals(getline(2), str)
endfunction


call themis#func_alias({'test.s:suit': s:suite})
call themis#func_alias({'test.s:': s:})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
