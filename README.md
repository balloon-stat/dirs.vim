dirs.vim
========

version 0.1.1  

ファイルパスを特定のファイル（~/vim_dirs）に記述することによって、  
そのパスが指すファイルを隣のウィンドウで開きます。  

パスは通常の表記のほかツリー上にインデントしてカスケードさせることができます。  

```
/home/user/
  foo0/
    foo1
    bar0/
      bar1
      bar2
  baz0/
    baz1
```

パスの組み立てはインデントを見て行なわれます。  
またインデントの深さによって折り畳みを行います。  

---

DirsOpenBufコマンドを実行すると、左側に新しいウィンドウが作られて  
vim_dirsファイルがそのウィンドウに開かれます。  
ここにアクセスしたいファイルのパスを書いて下さい。  

デフォルトのキー設定では gl と入力することで、  
ディレクトリ下のファイルの一覧をその次の行へと追記することができます。  

記述したパスにカーソルを合わせて Enterキーを押すと  
ファイルの場合、右のウィンドウにカーソルが移動し、そのファイルを開きます。  
ディレクトリの場合は、そのディレクトリに cd します。  

また、パス以外にExコマンドを書いて、Enter で実行することもできます。  
Exコマンドはコマンドの先頭に ":" を書いてください。  


DirsOpenBufの実行時にデフォルトでは ~/.dirs_rc が読み込まれます。  
~/.dirs_rc が存在しない場合、autoload/dirs_rc.vim が読み込まれます。  
キー設定を変えたりしたい場合は、autoload/dirs_rc.vim をサンプルに  
~/.dirs_rc を作成してください。  


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
開かれている場合にはカスケードされているノードを遡って連結しフルパスを返します。  

---

```
dirs#do_entry(edit_cmd, win_cmd)
```

現在カーソルがある行が折りたたまれているときは折りたたみを開きます。  
開かれている場合にはカスケードにされているノードを遡って連結しフルパスを作ります。  
パスが指すのがファイルの場合、wincmd を `win_cmd` を引数にして実行し、その後、  
`edit_cmd` にパスを渡して実行します。  
ディレクトリの場合、そのディレクトリに cd します。  
行の先頭が ':' の場合は、wincmd を `win_cmd` を引数にして実行し、その後、Exコマンドとして実行します。  


---

以下の関数は `dirs#entry()` を内部で実行し、その値を対象とします。  

`dirs#inputcmd()` コマンドの入力を求め、それを実行します。  
`dirs#rename()` ファイル名の入力を求め、その名前にリネームします。  
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

```vim
Normal mode mappings.

{lhs}         {rhs}
--------      -----------------------------
ga             :<C-u>echo system("git add " . dirs#entry())<CR>  
gr             :<C-u>call dirs#inputcmd()<CR>  
gj             ddp  
gk             kddpk  
gl             :<C-u>call dirs#ls("")<CR>  
gh             zc  
ge             :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#entry())<CR>  
gy             :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#curln())<CR>  
gp             $p  
gs             :<C-u>call dirs#do_entry('split', 'w')<CR>  
go             :<C-u>call dirs#do_entry('edit', 'w')<CR>  
t              :<C-u>call dirs#do_entry('tabe', '')<CR>  
,              :<C-u>wall<CR>go  
<CR>           :<C-u>wall<CR>go  
<2-LeftMouse>  :<C-u>wall<CR>go  
gf             :<C-u>echo dirs#tail()<CR>  
gv             :<C-u>if dirs#do_entry('e', 'w') \| wincmd p \| endif<CR>  
v              :<C-u>wall<CR>gv  
Y              :<C-u>call <SID>yank_buf()<CR>  
P              :<C-u>call <SID>paste_buf()<CR>  
D              :<C-u>call dirs#delete()<CR>  
R              :<C-u>call dirs#rename()<CR>  
M              :<C-u>call dirs#mkdir()<CR>  
J              Jx  
w              wl  
b              bh  
e              $  
=              :<C-u>call <SID>win_resize()<CR>  
f              :<C-u>call <SID>search_tailhead()<CR>  
;              :<C-u>call <SID>repeat_search()<CR>  
```
