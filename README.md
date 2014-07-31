vim-operator-inserttext
=======================

[![Build Status](https://travis-ci.org/syngan/vim-operator-inserttext.svg?branch=master)](https://travis-ci.org/syngan/vim-operator-inserttext)

関数の出力結果を挿入するオペレータです。

- Requires:  ![vim-operator-user](https://github.com/kana/vim-operator-user)


```vim
function! g:Hoge(str, motion)
	" motion= 'char', 'line' or 'block'
	return "<<" . a:str . ">>"
endfunction

" motion の前に g:Hoge({motion}) の実行結果を挿入する
map <expr> ss operator#inserttext#mapexpr(function('g:Hoge'), -1)

" motion の後ろに g:Hoge({motion}) の実行結果を挿入する
map <expr> ss operator#inserttext#mapexpr(function('g:Hoge'), +1)

" motion の内容を g:Hoge({motion}) の実行結果に置き換える.
" blockwise の場合には最終行を実行結果で置き換える.
map <expr> ss operator#inserttext#mapexpr(function('g:Hoge'), +0)

```




