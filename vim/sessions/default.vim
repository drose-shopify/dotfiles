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
badd +29 ~/.config/nvim/coc-settings.json
badd +32 vim/config/bindings.vim
badd +8 vim/config/plugin/rg.vim
badd +13 vim/config/plugin/nerdtree.vim
badd +1 vim/config/plugin/lightline.vim
badd +8 vim/config/plugin/fzf.vim
badd +5 vim/config/plugin/coc.vim
badd +4 vim/config/plugin/ale.vim
badd +1 vim/config/plugin/ultisnips.vim
badd +1 vim/config/basic.vim
badd +1 vim/config/plugin/vim_notes.vim
badd +1 vim/config/plugin/vim_subversive.vim
badd +1 vim/config/plugin/vim_yoink.vim
argglobal
%argdel
$argadd ~/dotfiles
edit vim/config/plugin/coc.vim
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
exe '2resize ' . ((&lines * 27 + 29) / 58)
exe 'vert 2resize ' . ((&columns * 204 + 118) / 236)
exe '3resize ' . ((&lines * 27 + 29) / 58)
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
if bufexists("~/.local/share/nvim/plugged/coc.nvim/doc/coc.txt") | buffer ~/.local/share/nvim/plugged/coc.nvim/doc/coc.txt | else | edit ~/.local/share/nvim/plugged/coc.nvim/doc/coc.txt | endif
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
let s:l = 996 - ((25 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
996
normal! 0
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
2
normal! zo
let s:l = 47 - ((25 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
47
normal! 0
wincmd w
3wincmd w
exe 'vert 1resize ' . ((&columns * 31 + 118) / 236)
exe '2resize ' . ((&lines * 27 + 29) / 58)
exe 'vert 2resize ' . ((&columns * 204 + 118) / 236)
exe '3resize ' . ((&lines * 27 + 29) / 58)
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
