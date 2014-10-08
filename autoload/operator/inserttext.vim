scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:log(str) " {{{
  silent! call vimconsole#log(a:str)
endfunction " }}}

function! operator#inserttext#mapexpr(func, pos) " {{{
  let s:__func__ = a:func
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
  call setreg(a:reg, a:str, 'V')
  if a:pos < 0
    call s:knormal('`["' . a:reg . 'P')
  elseif a:pos > 0
    call s:knormal('`]"' . a:reg . 'p')
  elseif getpos("'[")[1] == 1 && getpos("']")[1] == line("$")
    " vanish
    call s:knormal('`[V`]"_d"' . a:reg . 'PG"_ddggVG"' . a:reg . 'y')
  else
    call s:knormal('`[V`]"_d"' . a:reg . 'p')
  endif
endfunction " }}}

function! s:funcs.char.paste(str, pos, reg) " {{{
  call setreg(a:reg, a:str, 'v')
  if a:pos < 0
    call s:knormal('`["' . a:reg . 'P')
  elseif a:pos > 0
    call s:knormal('`]"' . a:reg . 'p')
  else
    call s:knormal('`[v`]"' . a:reg . 'P')
  endif
endfunction " }}}

function! s:funcs.block.paste(str, pos, reg) " {{{
  let p = [getpos("'["), getpos("']"), getregtype(a:reg)]
  if a:pos != 0
    let str = repeat(' ', p[0][2]-1) . a:str
    call setreg(a:reg, str, 'V')
    if a:pos < 0
      call s:knormal('`["' . a:reg . 'P')
    else
      call s:knormal('`]"' . a:reg . 'p')
    endif
    return
  else
    " 最終行を置き換える
    call setpos(".", [p[0][0], p[1][1], p[0][2], p[0][3]])
    call s:knormal('R' . a:str)
  endif
endfunction " }}}

function! s:do(motion, pos) " {{{

  let fdic = s:funcs[a:motion]
  let reg = '"'
  let regdic = {}
  for r in [reg]
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  try
    let src = fdic.gettext(reg)
    let str = s:__func__(src, a:motion)
    if str != ''
      call fdic.paste(str, a:pos, reg)
    endif
  finally
    for r in [reg]
      call setreg(r, regdic[r][0], regdic[r][1])
    endfor
  endtry
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
