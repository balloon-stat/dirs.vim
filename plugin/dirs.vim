if exists('g:loaded_dirs')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 DirsOpenBuf   call dirs#open()

let g:dirs_window_width = get(g:, 'dirs_window_width', 24)
let g:dirs_shiftwidth   = get(g:, 'dirs_shiftwidth', 1)
let g:dirs_filename     = get(g:, 'dirs_filename', '~/vim_dirs')
let g:dirs_rc_filename  = get(g:, 'dirs_rc_filename', '~/.dirs_rc')

if has('win32')
  let g:dirs_separator = get(g:, 'dirs_separator', '\')
else
  let g:dirs_separator = get(g:, 'dirs_separator', '/')
endif

let g:loaded_dirs = 1

let &cpo = s:save_cpo
unlet s:save_cpo

