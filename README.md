vim-operator-evalf
=======================

[![Build Status](https://travis-ci.org/syngan/vim-operator-evalf.svg?branch=master)](https://travis-ci.org/syngan/vim-operator-evalf)

関数の出力結果を挿入するオペレータです。

- Required:  ![vim-operator-user](https://github.com/kana/vim-operator-user)


```vim
function! Hoge(motion, wise_name, ...)
	" wise_name = 'char', 'line' or 'block'
	return "<<" . a:motion . ">>"
endfunction

" motion の前に Hoge({motion}, {wise_name}) の実行結果を挿入する
map <expr> ss operator#evalf#mapexpr(function('Hoge'), -1)

" motion の後ろに Hoge({motion}, {wise_name}) の実行結果を挿入する
map <expr> ss operator#evalf#mapexpr(function('Hoge'), +1)

" motion の内容を Hoge({motion}, {wise_name}) の実行結果に置き換える.
" blockwise の場合には最終行を実行結果で置き換える.
map <expr> ss operator#evalf#mapexpr(function('Hoge'),  0)



" func({str}, {motion} {definition})
function! In2Pre(str, ...)
	return mconv#in2pre(a:str)
endfunction

let g:operator#evalf#config = {
\	'prefix': {'func': function('In2Pre') },
\}

" 実行後に g:operator#evalf#config で定義した関数を入力する.
" 挿入先は関数名の最初か最後に -/0/+ で指定する
map ss <Plug>(operator-evalf)
```

