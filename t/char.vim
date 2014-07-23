filetype plugin on

let g:str1 = "koko ha tako desu ka."
let g:str2 = "koreha line 2"
let g:str3 = "hoge de kakomitai syo-ko-gun"
let g:str4 = "tuika sita"

let g:pst1 = "pste"

function! s:paste_code()
  put =[
  \    g:str1,
  \    g:str2,
  \    g:str3,
  \    g:str4,
  \ ]
  1 delete _
endfunction

function! g:P1(str)
  return len(a:str) . g:pst1
endfunction

describe 'insert after'
  before
    new
    call s:paste_code()
    map <expr> sa1 operator#inserttext#mapexpr(function("g:P1"), +1)
  end

  after
    close!
  end

  for g:m in ["sa1"]

    it "line1 head"
      execute 'normal' printf("1G0ve%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# substitute(g:str1, "koko", "koko4" . g:pst1, "")
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
    end

    it "line1 1word"
      execute 'normal' printf("1Gftve%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# substitute(g:str1, "tako", "tako4" . g:pst1, "")
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
    end

    it "line3 2word"
      execute 'normal' printf("3Gfdvee%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# substitute(g:str3, "de kakomitai", "de kakomitai12" . g:pst1, "")
      Expect getline(4) ==# g:str4
    end

    it "line4 1word tail"
      execute 'normal' printf("4Gfsve%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# substitute(g:str4, "sita", "sita4" . g:pst1, "")
    end

    it "line1-2 tail"
      execute 'normal' printf("1Gfuwvj$%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2 . "17" . g:pst1
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
    end

    it "whole"
      execute 'normal' printf("1G0vG$%s", g:m)
      Expect line('$') ==# 4
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4 . (3 + len(g:str1.g:str2.g:str3.g:str4)) . g:pst1
    end
  endfor
end


