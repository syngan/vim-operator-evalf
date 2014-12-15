scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:log(str) " {{{
  silent! call vimconsole#log(a:str)
endfunction " }}}

function! s:system(cmd) " {{{
  " @TODO vimproc
  let cmd = substitute(a:cmd, "\n", '', 'g')
  let val = system(cmd)
  let err = v:shell_error
  return [val, err]
endfunction " }}}

function! operator#inserttext#system(cmd) " {{{
  let [val, err] = s:system(a:cmd)
  if err
    return ''
  else
    return val
  endif
endfunction " }}}

function! s:echo(msg) " {{{
  redraw | echo 'inserttext: ' . a:msg
endfunction " }}}

function! s:echoerr(msg) " {{{
  echohl ErrorMsg
  echomsg 'inserttext: ' . a:msg
  echohl None
endfunction " }}}

function! s:is_valid_config() " {{{
  return exists('g:operator#inserttext#config') &&
\   type(g:operator#inserttext#config) == type({})
endfunction " }}}

function! s:get(config, key) " {{{
  let c = a:config
  if has_key(c, a:key)
    if !type(c[a:key]) != type({}) || !has_key(c[a:key], 'func') ||
\     type(c[a:key].func) != type(function('tr'))
      call s:echo('invalid config[' + a:key + ']')
      return [0, 0]
    endif
    return [c[a:key], get(c[a:key], 'pos', 0)]
  endif

  for x in [[0,1,-1], [-1,0,-2]]
    if a:key[x[0]] == '+' || a:key[x[0]] == '-'
      if has_key(c, a:key[x[1] : x[2]])
        return [c[a:key[x[1] : x[2]]], a:key[x[0]]=='+' ? 1 : -1]
      endif
    endif
  endfor

  return [-1, 0]
endfunction " }}}

function! operator#inserttext#complete(...) " {{{
  return keys(g:operator#inserttext#config)
endfunction " }}}

function! s:input(...) " {{{
  return input('inserttext: ', '', 'custom,operator#inserttext#complete')
endfunction " }}}

function! operator#inserttext#quickrun(str, ...) " {{{
  let f = tempname()
  call writefile(split(a:str, '\n'), f)
  call quickrun#run({
        \ 'outputter': 'variable',
        \ 'srcfile': f,
        \ 'outputter/variable/name': 'g:operator#inserttext#quickrun_ret',
        \ 'type': s:__func__quickrun,
        \ 'runner': 'system'
        \ })
  " 任意の runner で同期処理にする方法がよくわからない.
  " ローカル変数は利用できるんか?
  call delete(f)
  let ret = get(g:, "operator#inserttext#quickrun_ret", '')
  unlet! g:operator#inserttext#quickrun_ret
  if ret ==# s:__func__quickrun + ': Command not found.'
    throw 'E117'
  endif

  return ret
endfunction " }}}

function! operator#inserttext#do(motion) " {{{
  let str = s:input(a:motion)
  if str == ''
    call s:echo('canceled')
    return
  endif

  " user definition {{{
  "------------------------------------------------
  if s:is_valid_config()
    let [c, p] = s:get(str, g:operator#inserttext#config)
    if c == 0
      return
    elseif c != -1
      let s:__func__ = c.func
      return s:do(a:motion, p)
    endif
  endif " }}}

  " operator-inserttext functions {{{
  "------------------------------------------------
  for x in [[1,-1,0],[0,-2,len(str)-1],[0,-1]]
    if len(x) > 2 && str[x[2]] != '+' && str[x[2]] != '-'
      continue
    endif
    let F = function('operator#inserttext#' . str[x[0] : x[1]] . '#eval')
    try
      let s:__func__ = F
      if len(x) == 2
        return s:do(a:motion, 0)
      else
        return s:do(a:motion, str[x[2]] == '+' ? 1 : -1)
      endif
    catch /E117.*/
      break
    endtry
  endfor " }}}

  " do quickrun {{{
  "------------------------------------------------
  for x in [[1,-1,0],[0,-2,len(str)-1],[0,-1]]
    if len(x) > 2 && str[x[2]] != '+' && str[x[2]] != '-'
      continue
    endif
    let s:__func__ = function('operator#inserttext#quickrun')
    try
      if len(x) == 2
        let s:__func__quickrun = str
        return s:do(a:motion, 0)
      else
        let s:__func__quickrun = str[x[0] : x[1]]
        return s:do(a:motion, str[x[2]] == '+' ? 1 : -1)
      endif
    catch /E117.*/
      break
    endtry
  endfor " }}}

  " call s:echo('undefined: config[' + str + ']')
  " return
  call s:echoerr('not found: ' . str)
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
