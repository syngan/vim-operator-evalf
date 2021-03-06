scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" {{{ vital
let s:RD = vital#of('operator_evalf').import('Data.RegDict')
let s:opmo = vital#of('operator_evalf').import('Opmo')
" }}}

" s:postbl {{{
let s:postbl = {
\ '!': 'echo',
\ '+': 'insert_after',
\ '-': 'insert_before',
\ '0': 'replace',
\} " }}}

function! s:log(str) abort " {{{
  if get(g:, 'operator#evalf#debug', 0)
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

function! operator#evalf#system(cmd) abort " {{{
  let [val, err] = s:system(a:cmd)
  if err
    return ''
  else
    return val
  endif
endfunction " }}}

function! s:echo(msg) abort " {{{
  redraw | echo 'evalf: ' . a:msg
endfunction " }}}

function! s:echoerr(msg) abort " {{{
  echohl ErrorMsg
  echomsg 'evalf: ' . a:msg
  echohl None
endfunction " }}}

function! s:is_valid_config() abort " {{{
  return exists('g:operator#evalf#config') &&
\   type(g:operator#evalf#config) == type({})
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

function! operator#evalf#complete(arglead, ...) abort " {{{
  " arglead カーソル位置までの文字列
  " cmdline 入力された文字列すべて.
  if !exists('g:operator#evalf#config') || type(g:operator#evalf#config) != type({})
    return []
  endif
  return s:RD.keys(g:operator#evalf#config, '^' . a:arglead)
endfunction " }}}

function! s:input(...) abort " {{{
  return input('evalf: ', '', 'customlist,operator#evalf#complete')
endfunction " }}}

function! s:quickrun(str, ...) abort " {{{
  let f = tempname()
  call writefile(split(a:str, '\n'), f)
  call quickrun#run({
        \ 'outputter': 'variable',
        \ 'srcfile': f,
        \ 'outputter/variable/name': 'g:operator#evalf#quickrun_ret',
        \ 'type': s:__func__quickrun,
        \ 'runner': 'system'
        \ })
  " 任意の runner で同期処理にする方法がよくわからない.
  " ローカル変数は利用できるんか?
  call delete(f)
  let ret = get(g:, 'operator#evalf#quickrun_ret', '')
  unlet! g:operator#evalf#quickrun_ret
  if ret ==# s:__func__quickrun . ': Command not found.'
    throw 'E117'
  endif
  return ret
endfunction " }}}

:highlight evalf_hl_group ctermfg=Blue ctermbg=LightRed
function! operator#evalf#do(motion) abort " {{{
  let mids = s:opmo.highlight(a:motion, 'evalf_hl_group')
  redraw
  let str = s:input(a:motion)
  call s:opmo.unhighlight(mids)
  if str ==# ''
    call s:echo('canceled')
    return
  endif

  " user definition {{{
  "------------------------------------------------
  if s:is_valid_config()
    let [c, p] = s:get(g:operator#evalf#config, str)
    if c is 0
      call s:echo('invalid config')
      return
    elseif c isnot -1
      let s:__func__ = c.func
      return s:do(a:motion, p, c)
    endif
  endif " }}}

  " operator-evalf functions {{{
  "------------------------------------------------
  for x in [[1,-1,0],[0,-2,len(str)-1],[0,-1]]
    if len(x) > 2 && !has_key(s:postbl, str[x[2]])
      continue
    endif

    let l:F = function('operator#evalf#' . str[x[0] : x[1]] . '#eval')
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

function! operator#evalf#mapexpr(func, pos) abort " {{{
  let s:__func__ = a:func
  if a:pos > 0
    return "\<Plug>(operator-evalf-after)"
  elseif a:pos < 0
    return "\<Plug>(operator-evalf-before)"
  else
    return "\<Plug>(operator-evalf-replace)"
  endif
endfunction " }}}

call operator#user#define('evalf-before',  'operator#evalf#do_before')
call operator#user#define('evalf-after',   'operator#evalf#do_after')
call operator#user#define('evalf-replace', 'operator#evalf#do_replace')

function! operator#evalf#do_after(motion) abort " {{{
  return s:do(a:motion, s:postbl['+'])
endfunction " }}}

function! operator#evalf#do_before(motion) abort " {{{
  return s:do(a:motion, s:postbl['-'])
endfunction " }}}

function! operator#evalf#do_replace(motion) abort " {{{
  return s:do(a:motion, s:postbl[0])
endfunction " }}}

" @vimlint(EVL103, 1, a:motion)
function! s:opmo.echo(motion, str, ...) abort " {{{
  echo a:str
endfunction " }}}
" @vimlint(EVL103, 0, a:motion)

function! s:do(motion, pos, ...) abort " {{{

  try
    let src = s:opmo.gettext(a:motion)
    if a:0 == 0
      let str = s:__func__(src, a:motion)
    else
      let str = s:__func__(src, a:motion, a:1)
    endif
    if str !=# ''
      call s:opmo[a:pos](a:motion, str, 'nv')
    endif
  finally
  endtry
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
