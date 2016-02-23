vim-operator-evalf
=======================

[![Build Status](https://travis-ci.org/syngan/vim-operator-evalf.svg?branch=master)](https://travis-ci.org/syngan/vim-operator-evalf)

関数の出力結果を挿入するオペレータです。

- Requires:  ![vim-operator-user](https://github.com/kana/vim-operator-user)


```vim
function! g:Hoge(motion, wise_name)
	" wise_name = 'char', 'line' or 'block'
	return "<<" . a:motion . ">>"
endfunction

" motion の前に g:Hoge({motion}, {wise_name}) の実行結果を挿入する
map <expr> ss operator#evalf#mapexpr(function('g:Hoge'), -1)

" motion の後ろに g:Hoge({motion}, {wise_name}) の実行結果を挿入する
map <expr> ss operator#evalf#mapexpr(function('g:Hoge'), +1)

" motion の内容を g:Hoge({motion}, {wise_name}) の実行結果に置き換える.
" blockwise の場合には最終行を実行結果で置き換える.
map <expr> ss operator#evalf#mapexpr(function('g:Hoge'), +0)

```



