let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/dotfiles
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 ~/dotfiles
badd +4 setup_macos
badd +1 bin/macos/fonts/list
badd +6 bin/macos/initialize
badd +2 bin/macos/casks
badd +6 bin/macos/brew_packages
badd +2 bin/macos/taps
badd +2 bin/macos/install_brews
badd +2 bin/macos/homebrew/install_taps
badd +1 install-debase
badd +1 bin/macos/homebrew/casks
argglobal
%argdel
$argadd ~/dotfiles
edit bin/macos/homebrew/install_taps
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 31 + 118) / 236)
exe '2resize ' . ((&lines * 22 + 23) / 47)
exe 'vert 2resize ' . ((&columns * 204 + 118) / 236)
exe '3resize ' . ((&lines * 21 + 23) / 47)
exe 'vert 3resize ' . ((&columns * 204 + 118) / 236)
argglobal
enew
file NERD_tree_1
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal nofen
wincmd w
argglobal
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
let s:l = 1 - ((0 * winheight(0) + 11) / 22)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("bin/macos/install_brews") | buffer bin/macos/install_brews | else | edit bin/macos/install_brews | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
let s:l = 2 - ((1 * winheight(0) + 10) / 21)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 31 + 118) / 236)
exe '2resize ' . ((&lines * 22 + 23) / 47)
exe 'vert 2resize ' . ((&columns * 204 + 118) / 236)
exe '3resize ' . ((&lines * 21 + 23) / 47)
exe 'vert 3resize ' . ((&columns * 204 + 118) / 236)
tabnext 1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToOF
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
