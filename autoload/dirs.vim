let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')

function! dirs#open()
  let bufwn = bufwinnr(g:dirs_filename)
  if bufwn > 0
    execute bufwn 'wincmd w'
    if b:dirs_is_run
      return
    endif
  else
    exec 'silent vertical new' g:dirs_filename
    wincmd H
    exec 'vertical resize' g:dirs_window_width
  endif
  call s:buf_setup()
  let b:dirs_is_run = 1
endfunction

function! dirs#edit()
  exec 'silent edit' g:dirs_filename
  call s:buf_setup()
  let b:dirs_is_run = 1
endfunction

function! s:buf_setup()
  setlocal foldenable foldmethod=indent foldcolumn=0
  setlocal foldtext=DirsFoldText()
  setlocal nonumber noswapfile nobuflisted nowrap
  setlocal expandtab winwidth=1
  let &l:shiftwidth = g:dirs_shiftwidth
  if filereadable(g:dirs_rc_filename)
    execute 'source' g:dirs_rc_filename
  else
    execute 'source' s:path . g:dirs_separator . 'dirs_rc.vim'
  endif
endfunction

function! DirsFoldText()
  let [level, dir] = dirs#getln(v:foldstart)
  let nr = v:foldend - v:foldstart + 1
  let indent = repeat(' ', level)
  return indent . '+- ' . nr . ' nodes '
endfunction

function! dirs#getln(lnum)
  let line = getline(a:lnum)
  let space = matchstr(line, '^\s*')
  let level = len(space)
  let entry = strpart(line, level)
  let entry = substitute(entry, '\s*#.*', '', '')
  if entry[0] == ':'
    return [-1, entry]
  endif
  return [level, entry]
endfunction

function! dirs#curln()
  if foldclosed('.') != -1
    normal! zo
    return ""
  endif
  let [level, entry] = dirs#getln('.')
  return entry
endfunction

function! dirs#tail()
  let [level, entry] = dirs#getln('.')
  let entry = substitute(entry, escape(g:dirs_separator, '\') . '$', '', '')
  return fnamemodify(entry, ':t')
endfunction

function! dirs#fullpath(lnum)
  let [level, path] = dirs#getln(a:lnum)
  if level == -1
    return [-1, 0]
  endif
  let ln = line(a:lnum)
  let lv = level
  while ln > 0 && lv > 0
    let ln -= 1
    let [nlv, entry] = dirs#getln(ln)
    if nlv == -1
      continue
    elseif nlv < lv
      let path = entry . path
      let lv = nlv
      if lv == 0
        break
      endif
    endif
  endwhile
  return [level, path]
endfunction

function! s:fix_dir_sign(path)
  if a:path !~ '\' . g:dirs_separator . '$'
    execute 'normal A' . g:dirs_separator
  endif
endfunction

function! dirs#ls(ignore)
  let [level, path] = dirs#fullpath('.')
  echo path
  if isdirectory(path)
    call s:fix_dir_sign(path)
    let pathstr = globpath(path, '\.[^.]*', 1) . "\n" . globpath(path, '*', 1)
    let pathls = split(pathstr, "\n")
    let files = []
    for pl in pathls
      if a:ignore != "" && pl =~ a:ignore
        continue
      endif
      let indent = repeat(' ', level + g:dirs_shiftwidth)
      let is_dir = isdirectory(pl)
      let entry = fnamemodify(pl, ':t')
      if is_dir
        let entry .= g:dirs_separator
      endif
      call add(files, indent . entry)
    endfor
    call append(line('.'), files)
  endif
endfunction

function! dirs#entry()
  if foldclosed('.') != -1
    normal! zo
    return ""
  endif
  let [level, path] = dirs#fullpath('.')
  return substitute(path, escape(g:dirs_separator, '\') . '$', '', '')
endfunction

function! dirs#do_entry(edit_cmd, win_cmd)
  let entry = dirs#curln()
  if entry == ""
    return 0
  elseif entry[0] == ':'
    if a:win_cmd != ""
      execute 'wincmd' a:win_cmd
    endif
    execute entry[1:]
    wincmd p
    return 0
  endif
  let path = dirs#entry()
  if isdirectory(path)
    execute 'chdir' path
    echo "cwd:" path
    return 0
  elseif a:win_cmd != ""
    execute 'wincmd' a:win_cmd
    if a:edit_cmd[0] == 'e' && path == expand('%:p')
      return 1
    endif
  endif
  execute a:edit_cmd path
  return 1
endfunction

function! dirs#inputcmd()
  let entry = dirs#entry()
  if entry == ""
    return
  endif
  let cmd = input("input command for " . entry . "\n")
  return system(cmd . ' ' . entry)
endfunction

function! dirs#rename()
  let entry = dirs#entry()
  let kind = filewritable(entry)
  if kind > 0
    let newname = input("input new name: ")
    redraw
    let path = fnamemodify(entry, ':h')
    if rename(entry, path . '/' . newname)
      echoerr "fail rename from " . entry . " to " . path . newname
    else
      let oldname = fnamemodify(entry, ':t')
      silent execute 's/' . oldname . '/' . newname . '/'
      echo "renamed from" oldname "to" newname
    endif
  endif
endfunction

function! dirs#mkdir()
  let entry = dirs#entry()
  if isdirectory(entry) || filereadable(entry)
    echoerr "exists:" entry
    return
  endif
  call mkdir(entry, 'p')
  call s:fix_dir_sign(entry)
  echo "created:" entry
endfunction

function! dirs#delete()
  let entry = dirs#entry()
  if isdirectory(entry)
    echo "directry can not delete"
    return
  elseif delete(entry)
    echoerr "fail delete" entry
  else
    normal dd
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
