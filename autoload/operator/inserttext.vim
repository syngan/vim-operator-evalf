scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" {{{ vital
let s:RD = vital#of('operator_inserttext').import('Data.RegDict')
let s:opmo = vital#of('operator_inserttext').import('Opmo')
" }}}

" s:postbl {{{
let s:postbl = {
\ '!': 'echo',
\ '+': 'paste_after',
\ '-': 'paste_before',
\ '0': 'paste_replace',
\} " }}}

function! s:log(str) abort " {{{
  if get(g:, 'operator#inserttext#debug', 0)
    silent! call vimconsole#log(a:str)
  endif
endfunction " }}}

function! s:system(cmd) abort " {{{
  " @TODO vimproc
  let cmd = substitute(a:cmd, "\n", '', 'g')
  let val = system(cmd)
  let err = v:shell_error
  return [val, err]
endfunction " }}}

function! operator#inserttext#system(cmd) abort " {{{
  let [val, err] = s:system(a:cmd)
  if err
    return ''
  else
    return val
  endif
endfunction " }}}

function! s:echo(msg) abort " {{{
  redraw | echo 'inserttext: ' . a:msg
endfunction " }}}

function! s:echoerr(msg) abort " {{{
  echohl ErrorMsg
  echomsg 'inserttext: ' . a:msg
  echohl None
endfunction " }}}

function! s:is_valid_config() abort " {{{
  return exists('g:operator#inserttext#config') &&
\   type(g:operator#inserttext#config) == type({})
endfunction " }}}

function! s:get(config, key) abort " {{{
  " return conf + pos
  let c = a:config
  let ks = s:RD.keys(c, '^' . a:key)
  if len(ks) == 1
    let key = ks[0]
    if type(c[key]) != type({}) || !has_key(c[key], 'func') ||
\     type(c[key].func) != type(function('tr'))
      call s:echo('invalid config[' . key . ']')
      return [0, 0]
    endif
    return [c[key], s:postbl[get(c[key], 'pos', 0)]]
  endif

  for x in [[0,1,-1], [len(a:key)-1,0,-2]]
    if has_key(s:postbl, a:key[x[0]])
      let ks = s:RD.keys(c, '^' . a:key[x[1] : x[2]])
      if len(ks) == 1
        let key = ks[0]
        call s:log(c)
        call s:log(key)
        return [c[key], s:postbl[a:key[x[0]]]]
      endif
    endif
  endfor

  return [-1, 0]
endfunction " }}}

function! operator#inserttext#complete(arglead, ...) abort " {{{
  " arglead カーソル位置までの文字列
  " cmdline 入力された文字列すべて.
  if !exists('g:operator#inserttext#config') || type(g:operator#inserttext#config) != type({})
    return []
  endif
  return s:RD.keys(g:operator#inserttext#config, '^' . a:arglead)
endfunction " }}}

function! s:input(...) abort " {{{
  return input('inserttext: ', '', 'customlist,operator#inserttext#complete')
endfunction " }}}

function! s:quickrun(str, ...) abort " {{{
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
  let ret = get(g:, 'operator#inserttext#quickrun_ret', '')
  unlet! g:operator#inserttext#quickrun_ret
  if ret ==# s:__func__quickrun . ': Command not found.'
    throw 'E117'
  endif
  return ret
endfunction " }}}

function! operator#inserttext#do(motion) abort " {{{
  let str = s:input(a:motion)
  if str ==# ''
    call s:echo('canceled')
    return
  endif

  " user definition {{{
  "------------------------------------------------
  if s:is_valid_config()
    let [c, p] = s:get(g:operator#inserttext#config, str)
    if c is 0
      call s:echo('invalid config')
      return
    elseif c isnot -1
      let s:__func__ = c.func
      return s:do(a:motion, p, c)
    endif
  endif " }}}

  " operator-inserttext functions {{{
  "------------------------------------------------
  for x in [[1,-1,0],[0,-2,len(str)-1],[0,-1]]
    if len(x) > 2 && !has_key(s:postbl, str[x[2]])
      continue
    endif

    let l:F = function('operator#inserttext#' . str[x[0] : x[1]] . '#eval')
    try
      let s:__func__ = F
      if len(x) == 2
        return s:do(a:motion, s:postbl[0])
      else
        return s:do(a:motion, s:postbl[str[x[2]]])
      endif
    catch /E117.*/
      break
    endtry
  endfor " }}}

  " do quickrun {{{
  "------------------------------------------------
  for x in [[1,-1,0],[0,-2,len(str)-1],[0,-1]]
    if len(x) > 2 && !has_key(s:postbl, str[x[2]])
      continue
    endif
    let s:__func__ = function('s:quickrun')
    try
      if len(x) == 2
        let s:__func__quickrun = str
        return s:do(a:motion, s:postbl[0])
      else
        let s:__func__quickrun = str[x[0] : x[1]]
        return s:do(a:motion, s:postbl[str[x[2]]])
      endif
    catch /E117.*/
      break
    endtry
  endfor " }}}

  " call s:echo('undefined: config[' + str + ']')
  " return
  call s:echoerr('not found: ' . str)
endfunction " }}}

function! operator#inserttext#mapexpr(func, pos) abort " {{{
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

function! operator#inserttext#do_after(motion) abort " {{{
  return s:do(a:motion, s:postbl['+'])
endfunction " }}}

function! operator#inserttext#do_before(motion) abort " {{{
  return s:do(a:motion, s:postbl['-'])
endfunction " }}}

function! operator#inserttext#do_replace(motion) abort " {{{
  return s:do(a:motion, s:postbl[0])
endfunction " }}}

function! s:knormal(s) abort " {{{
  execute 'keepjumps' 'silent' 'normal!' a:s
endfunction " }}}

let s:funcs = {'char' : {}, 'line': {}, 'block': {}, 'common': {}}
function! s:funcs.common.echo(str, ...) abort " {{{
  echo a:str
endfunction " }}}

function! s:funcs.line.paste_before(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'V')
  call s:knormal('`["' . a:reg . 'P')
endfunction " }}}

function! s:funcs.line.paste_after(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'V')
  call s:knormal('`]"' . a:reg . 'p')
endfunction " }}}

function! s:funcs.line.paste_replace(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'V')
  if getpos("'[")[1] == 1 && getpos("']")[1] == line('$')
    " vanish
    call s:knormal('`[V`]"_d"' . a:reg . 'PG"_ddggVG"' . a:reg . 'y')
  else
    call s:knormal('`[V`]"_d"' . a:reg . 'p')
  endif
endfunction " }}}

function! s:funcs.char.paste_before(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'v')
  call s:knormal('`["' . a:reg . 'P')
endfunction " }}}

function! s:funcs.char.paste_after(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'v')
  call s:knormal('`]"' . a:reg . 'p')
endfunction " }}}

function! s:funcs.char.paste_replace(str, reg) abort " {{{
  call setreg(a:reg, a:str, 'v')
  call s:knormal('`[v`]"' . a:reg . 'P')
endfunction " }}}

function! s:funcs.block.paste_before(str, reg) abort " {{{
  let p = [getpos("'["), getpos("']"), getregtype(a:reg)]
  let str = repeat(' ', p[0][2]-1) . a:str
  call setreg(a:reg, str, 'V')
  call s:knormal('`["' . a:reg . 'P')
endfunction " }}}

function! s:funcs.block.paste_after(str, reg) abort " {{{
  let p = [getpos("'["), getpos("']"), getregtype(a:reg)]
  let str = repeat(' ', p[0][2]-1) . a:str
  call setreg(a:reg, str, 'V')
  call s:knormal('`]"' . a:reg . 'p')
endfunction " }}}

function! s:funcs.block.paste_replace(str, reg) abort " {{{
  let p = [getpos("'["), getpos("']"), getregtype(a:reg)]
  " 最終行を置き換える
  call setpos('.', [p[0][0], p[1][1], p[0][2], p[0][3]])
  call s:knormal('R' . a:str)
endfunction " }}}

function! s:set_funcs() abort " {{{
  for key in keys(s:funcs.common)
    let s:funcs.char[key] = s:funcs.common[key]
    let s:funcs.line[key] = s:funcs.common[key]
    let s:funcs.block[key] = s:funcs.common[key]
  endfor
  unlet s:funcs.common
endfunction " }}}

call s:set_funcs()

function! s:do(motion, pos, ...) abort " {{{

  let fdic = s:funcs[a:motion]
  let reg = '"'
  let regdic = {}
  for r in [reg]
    let regdic[r] = [getreg(r), getregtype(r)]
  endfor

  try
    let src = s:opmo.gettext(a:motion)
    if a:0 == 0
      let str = s:__func__(src, a:motion)
    else
      let str = s:__func__(src, a:motion, a:1)
    endif
    if str !=# ''
      call fdic[a:pos](str, reg)
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
