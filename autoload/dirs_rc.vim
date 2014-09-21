
nnoremap <silent> m :<C-u>call <SID>append_mark()<CR>

let s:filename = fnamemodify(bufname('%'), ':t')
if s:filename == fnamemodify(expand(g:dirs_filename), ':t')
  nnoremap <buffer> ga :<C-u>echo system("git add " . dirs#entry())<CR>
  nnoremap <buffer> gr :<C-u>echo dirs#inputcmd()<CR>
  nnoremap <buffer> gc :<C-u>echo <SID>chdir()<CR>
  nnoremap <buffer> gj ddp
  nnoremap <buffer> gk kddpk
  nnoremap <buffer> gl :<C-u>call dirs#ls("")<CR>
  nnoremap <buffer> gh zc
  nnoremap <buffer> <silent> ge :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#entry())<CR>
  nnoremap <buffer> <silent> gy :<C-u>call setreg(v:register == "" ? '"' : v:register, dirs#curln())<CR>
  nnoremap <buffer> gp $p
  nnoremap <buffer> gs :<C-u>call dirs#do_entry('split', 'l')<CR>
  nnoremap <buffer> go :<C-u>call dirs#do_entry('edit', 'l')<CR>
  nnoremap <buffer> t  :<C-u>call dirs#do_entry('tabe', '')<CR>
  nmap <buffer> , :<C-u>wall<CR>go
  nmap <buffer> <CR> :<C-u>wall<CR>go
  nmap <buffer> <2-LeftMouse> :<C-u>wall<CR>go
  nmap <buffer> gv :<C-u>if dirs#do_entry('e', 'l') \| wincmd p \| endif<CR>
  nmap <buffer> v :<C-u>wall<CR>gv
  nnoremap <buffer> Y :<C-u>call <SID>yank_buf()<CR>
  nnoremap <buffer> P :<C-u>call <SID>paste_buf()<CR>
  nnoremap <buffer> D :<C-u>call dirs#delete()<CR>
  nnoremap <buffer> R :<C-u>call dirs#rename()<CR>
  nnoremap <buffer> M :<C-u>call dirs#mkdir()<CR>
  nnoremap <buffer> J Jx
  nnoremap <buffer> w wl
  nnoremap <buffer> b bh
  nnoremap <buffer> e $
  nnoremap <buffer> <silent> f :<C-u>call <SID>search_tailhead()<CR>
  nnoremap <buffer> <silent> ; :<C-u>call <SID>repeat_search()<CR>
endif

let s:register = ""
function! s:yank_buf()
  if dirs#do_entry('edit', 'l')
    let s:regitser = getline(1, '$')
    wincmd p
  endif
endfunction

function! s:paste_buf()
  if dirs#do_entry('edit', 'l')
    call append(0, s:regitser)
    wincmd p
  endif
endfunction

function! s:chdir()
  let entry = dirs#entry()
  execute 'chdir' entry
  return entry
endfunction

let s:search_char = ""
function! s:search_tailhead()
  let s:search_char = nr2char(getchar())
  call s:repeat_search()
endfunction

function! s:repeat_search()
  normal! zR
  normal! j
  let start = line('.')
  let end = line('$')
  if s:_search(s:search_char, start + 1, end)
    return s:open_only()
  endif
  normal! gg
  if s:_search(s:search_char, 1, start - 1)
    return s:open_only()
  endif
endfunction

function! s:_search(ch, start, end)
  let ix = a:start
  while 1
    let tail = dirs#tail()
    if tail[0] == a:ch
      normal! ^
      return 1
    endif
    if ix >= a:end
      return 0
    endif
    normal! j
    let ix += 1
  endwhile
endfunction

function! s:open_only()
  let [level, entry] = dirs#getln('.')
  let level = level / g:dirs_shiftwidth
  normal! zM
  silent! execute 'normal!' level . 'zo'
endfunction

function! s:append_mark()
  let ch = nr2char(getchar())
  let name = bufname('%')
  let lnum = line('.')
  execute 'mark' ch
  call dirs#open()
  call append(0, ":normal! '" . ch . "  # " . name . ": " . lnum)
endfunction
