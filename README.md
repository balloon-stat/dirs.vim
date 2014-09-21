dirs.vim
========

version 0.1.0 

何度も開くファイルをメモしてアクセスを簡単にします。  
IDEによくあるプロジェクトエクスプローラのような使い方ができます。  
シンプルなランチャー機能もあります。  
 
~/vim_dirs にファイルパスのツリーを書いていきます。  
DirsOpenBufコマンドを実行して、vim_dirsファイルを開いてください。  
バッファが開かれるときに ~/.dirs_rc が実行されます。  

~/.dirs_rc を用意しない場合、デフォルトである autoload/dirs_rc.vim を実行します。  

DirsOpenBufコマンドを実行すると左側に新しいウィンドウが作られます。  
このウィンドウのバッファにアクセスしたいファイルのパスを書きます。  

デフォルトではパスにカーソルを合わせて Enterキーを押すと  
右のウィンドウにそのファイルが表示されます。  

パスは通常の表記のほかツリー上にインデントしてカスケードさせることができます。

```
/home/user/
  foo/
    foo1
    foo2
    foo3
  bar/
    bar1
    bar2
  baz/
    baz1
    bazz/
      bazz1
```

### 関数

---

```
dirs#ls(ignore)
```

現在カーソルがある行のディレクトリの下にあるノードの一覧を現在行の下に追加します。  
`ignore` には一覧から除外したいノードの正規表現を指定します。  

---

```
dirs#entry()
```

現在カーソルがある行が折りたたまれているときは折りたたみを開きます。  
開かれている場合にはカスケードになっているパスを遡って連結しフルパスを返します。  

---

```
dirs#do_entry(edit_cmd, win_cmd)
```

現在カーソルがある行が折りたたまれているときは折りたたみを開きます。  
開かれている場合には wincmd を `win_cmd` を引数にして実行し、その後、  
`edit_cmd` にフルパスを渡して実行します。  

---

以下の関数は `dirs#entry()` を実行し、その値を引数とします。  

`dirs#inputcmd()` コマンドの入力を求め、それを実行します。  
`dirs#rename()` リネームします。  
`dirs#mkdir()` ディレクトリを作成します。  
`dirs#delete()` ファイルを削除します。  

---

### グローバル変数

`g:dirs_window_width` DirsOpenBuf 実行時のバッファの幅 `24`  
`g:dirs_shiftwidth`   vim_dirs バッファのshiftwidth `1`  
`g:dirs_filename`     vim_dirs バッファのファイルパス `'~/vim_dirs'`  
`g:dirs_rc_filename`  DirsOpenBuf 実行時の設定ファイルのパス `'~/.dirs_rc'`  
`g:dirs_separator` パスの区切り Windows `'\'` 他 `'/'`  
`
---

### dirs_rc.vim の Map

Buffer local Map  

```
ga :<C-u>echo system("git add " . dirs#entry())<CR>  
gr :<C-u>call dirs#inputcmd()<CR>  
gc :<C-u>execute 'chdir' dirs#entry()<CR>  
gj ddp  
gk kddpk  
gl :<C-u>call dirs#ls("")<CR>  
gh zc  
ge :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#entry())<CR>  
gy :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#curln())<CR>  
gp $p  
gs :<C-u>call dirs#do_entry('split', 'l')<CR>  
go :<C-u>call dirs#do_entry('edit', 'l')<CR>  
t  :<C-u>call dirs#do_entry('tabe', '')<CR>  
, :<C-u>wall<CR>go  
<CR> :<C-u>wall<CR>go  
<2-LeftMouse> :<C-u>wall<CR>go  
gv :<C-u>if dirs#do_entry('e', 'l') \| wincmd p \| endif<CR>  
v :<C-u>wall<CR>gv  
Y :<C-u>call <SID>yank_buf()<CR>  
P :<C-u>call <SID>paste_buf()<CR>  
D :<C-u>call dirs#delete()<CR>  
R :<C-u>call dirs#rename()<CR>  
M :<C-u>call dirs#mkdir()<CR>  
J Jx  
w wl  
b bh  
e $  
f :<C-u>call <SID>search_tailhead()<CR>  
; :<C-u>call <SID>repeat_search()<CR>  
```

Global Map 

```
m :<C-u>call <SID>append_mark()<CR>  
```

