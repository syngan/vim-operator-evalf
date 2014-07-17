vim-operator-inserttext
=======================

関数の出力結果を挿入するオペレータです。

- Requires:  ![vim-operator-user](https://github.com/kana/vim-operator-user)


```vim
function! g:Hoge(str)
	return "<<" . a:str . ">>"
endfunction

" motion の前に g:Hoge({motion}) の実行結果を挿入する
map <expr> ss operator#inserttext#mapexpr(function('g:Hoge'), -1)

" motion の後ろに g:Hoge({motion}) の実行結果を挿入する
map <expr> ss operator#inserttext#mapexpr(function('g:Hoge'), +1)
```




