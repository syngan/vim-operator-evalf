scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! operator#inserttext#mapexpr(func, pos) " {{{
  let s:func = a:func
  if a:pos > 0
    return "\<Plug>(operator-inserttext-after)"
  elseif a:pos < 0
    return "\<Plug>(operator-inserttext-before)"
  else
    return "\<Plug>(operator-inserttext-replace)"
  endif
endfunction " }}}

call operator#user#define('inserttext-before',  'operator#inserttext#do_before')
call operator#user#define('inserttext-after',   'operator#inserttext#do_after')
call operator#user#define('inserttext-replace', 'operator#inserttext#do_replace')

function! operator#inserttext#do_after(motion) " {{{
  return s:do(a:motion, 1)
endfunction " }}}

function! operator#inserttext#do_before(motion) " {{{
  return s:do(a:motion, -1)
endfunction " }}}

function! operator#inserttext#do_replace(motion) " {{{
  return s:do(a:motion, 0)
endfunction " }}}

function! s:knormal(s) " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

let s:funcs = {'char' : {}, 'line': {}, 'block': {}}
function! s:funcs.char.gettext(reg) " {{{
  call s:knormal(printf('`[v`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:funcs.line.gettext(reg) " {{{
  call s:knormal(printf('`[V`]"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:funcs.block.gettext(reg) " {{{
  call s:knormal(printf('gv"%sy', a:reg))
  return getreg(a:reg)
endfunction " }}}

function! s:funcs.line.paste(str, pos, reg) " {{{
  if a:str =~# "\n$" || a:str == ""
    call setreg(a:reg, a:str, 'V')
  else
    call setreg(a:reg, a:str . "\n", 'V')
  endif
  if a:pos < 0
    call s:knormal('`[P')
  elseif a:pos > 0
    call s:knormal('`]p')
  elseif getpos("'[")[1] == 1 && getpos("']")[1] == line("$")
    " 全削除
    call s:knormal('`[V`]"_dPG"_ddggVG"' . a:reg . 'y')
  else
    call s:knormal('`[V`]"_dP')
  endif
endfunction " }}}

function! s:funcs.char.paste(str, pos, reg) " {{{
  call setreg(a:reg, a:str, 'V')
  if a:pos < 0
    call s:knormal('`[P')
  elseif a:pos > 0
    call s:knormal('`]p')
  elseif getpos("'[")[1] == 1 && getpos("']")[1] == line("$")
    " 全削除
    call s:knormal('`[v`]"_dPG"_ddggVG"' . a:reg . 'y')
  else
    call s:knormal('`[v`]"_dP')
  endif
endfunction " }}}

function! s:do(motion, pos) " {{{

  let fdic = s:funcs[a:motion]
  let reg = 'f'
  let regdic = {}
  for r in [reg, '"']
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  try
    let src = fdic.gettext(reg)
    let str = s:func(src)
    call fdic.paste(str, a:pos, reg)
  finally
    for r in [reg, '"']
      call setreg(r, regdic[r][0], regdic[r][1])
    endfor
  endtry
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
