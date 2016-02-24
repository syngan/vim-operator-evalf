filetype plugin on

let g:str1 = "koko ha tako desu ka."
let g:str2 = "koreha line 2"
let g:str3 = "hoge de kakomitai syo-ko-gun"
let g:str4 = "tuika sita"

let g:pst1 = "pste line 1"
let g:pst2 = "pste line 2"

function! s:paste_code()
  put =[
  \    g:str1,
  \    g:str2,
  \    g:str3,
  \    g:str4,
  \ ]
  1 delete _
endfunction

function! g:P1(str, ...)
  return len(a:str) . g:pst1 . "\n" . g:pst2 . "\n"
endfunction

function! g:P2(str, ...)
  return len(a:str) . g:pst1 . "\n" . g:pst2
endfunction

describe 'insert after'
  before
    new
    call s:paste_code()
    map <expr> sa1 operator#evalf#mapexpr(function("g:P1"), +1)
    map <expr> sa2 operator#evalf#mapexpr(function("g:P2"), +1)
  end

  after
    close!
  end

  for g:m in ["sa1", "sa2"]
    it "line1"
      execute 'normal' printf("1GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# (1+len(g:str1)) . g:pst1
      Expect getline(3) ==# g:pst2
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line2"
      execute 'normal' printf("2GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# (1+len(g:str2)) . g:pst1
      Expect getline(4) ==# g:pst2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line4"
      execute 'normal' printf("4GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
      Expect getline(5) ==# (1+len(g:str4)) . g:pst1
      Expect getline(6) ==# g:pst2
    end

    it "line1-2"
      execute 'normal' printf("1GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# (1+len(g:str1)+1+len(g:str2)) . g:pst1
      Expect getline(4) ==# g:pst2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line2-3"
      execute 'normal' printf("2GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# (1+len(g:str2)+1+len(g:str3)) . g:pst1
      Expect getline(5) ==# g:pst2
      Expect getline(6) ==# g:str4
    end

    it "line3-4"
      execute 'normal' printf("3GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
      Expect getline(5) ==# (1+len(g:str3)+1+len(g:str4)) . g:pst1
      Expect getline(6) ==# g:pst2
    end

    it "line1-4"
      execute 'normal' printf("1GVG%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# g:str4
      Expect getline(5) ==# (4+len(g:str1)+len(g:str2)+len(g:str3)+len(g:str4)) . g:pst1
      Expect getline(6) ==# g:pst2
    end
  endfor
end

describe 'insert before'
  before
    new
    call s:paste_code()
    map <expr> sa1 operator#evalf#mapexpr(function("g:P1"), -1)
    map <expr> sa2 operator#evalf#mapexpr(function("g:P2"), -1)
  end

  after
    close!
  end

  for g:m in ["sa1", "sa2"]
    it "line1"
      execute 'normal' printf("1GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# (1+len(g:str1)) . g:pst1
      Expect getline(2) ==# g:pst2
      Expect getline(3) ==# g:str1
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line2"
      execute 'normal' printf("2GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# (1+len(g:str2)) . g:pst1
      Expect getline(3) ==# g:pst2
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line4"
      execute 'normal' printf("4GV%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# g:str3
      Expect getline(4) ==# (1+len(g:str4)) . g:pst1
      Expect getline(5) ==# g:pst2
      Expect getline(6) ==# g:str4
    end

    it "line1-2"
      execute 'normal' printf("1GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# (1+len(g:str1)+1+len(g:str2)) . g:pst1
      Expect getline(2) ==# g:pst2
      Expect getline(3) ==# g:str1
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line2-3"
      execute 'normal' printf("2GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# (1+len(g:str2)+1+len(g:str3)) . g:pst1
      Expect getline(3) ==# g:pst2
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line3-4"
      execute 'normal' printf("3GVj%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# g:str1
      Expect getline(2) ==# g:str2
      Expect getline(3) ==# (1+len(g:str3)+1+len(g:str4)) . g:pst1
      Expect getline(4) ==# g:pst2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end

    it "line1-4"
      execute 'normal' printf("1GVG%s", g:m)
      Expect line('$') ==# 6
      Expect getline(1) ==# (4+len(g:str1)+len(g:str2)+len(g:str3)+len(g:str4)) . g:pst1
      Expect getline(2) ==# g:pst2
      Expect getline(3) ==# g:str1
      Expect getline(4) ==# g:str2
      Expect getline(5) ==# g:str3
      Expect getline(6) ==# g:str4
    end
  endfor
end


