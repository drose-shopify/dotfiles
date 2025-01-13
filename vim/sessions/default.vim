let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/src/github.com/Shopify/shopify
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +1 ~/src/github.com/Shopify/shopify
badd +27 areas/core/shopify/components/taxes/app/utils/tax_engine/line_item_calculator.rb
badd +551 areas/core/shopify/components/checkouts/core/app/models/cart_line.rb
badd +33 areas/core/shopify/components/checkouts/core/app/models/abandoned_cart/abstract_cart_item.rb
badd +37 areas/core/shopify/components/checkouts/core/app/models/cart_serializers/cart_item.rb
badd +1 areas/core/shopify/components/online_store/app/models/cart_item.rb
badd +44 areas/core/shopify/components/checkouts/core/app/models/abandoned_cart/cart_item_component.rb
badd +1 areas/core/shopify/components/taxes/test/unit/tax_engine/line_item_calculator_test.rb
badd +0 areas/core/shopify/components/sales/app/models/concerns/sales/line_item_common.rb
argglobal
%argdel
$argadd ~/src/github.com/Shopify/shopify
edit areas/core/shopify/components/taxes/app/utils/tax_engine/line_item_calculator.rb
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd w
wincmd w
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 1resize ' . ((&columns * 31 + 140) / 281)
exe '2resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 2resize ' . ((&columns * 124 + 140) / 281)
exe '3resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 3resize ' . ((&columns * 124 + 140) / 281)
exe '4resize ' . ((&lines * 10 + 33) / 67)
argglobal
enew
file NERD_tree_tab_1
balt ~/src/github.com/Shopify/shopify
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
balt areas/core/shopify/components/taxes/test/unit/tax_engine/line_item_calculator_test.rb
setlocal fdm=syntax
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
4
normal! zo
5
normal! zo
23
normal! zo
31
normal! zo
39
normal! zo
93
normal! zo
103
normal! zo
39
normal! zo
93
normal! zo
103
normal! zo
let s:l = 27 - ((26 * winheight(0) + 26) / 53)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 27
normal! 046|
wincmd w
argglobal
if bufexists(fnamemodify("areas/core/shopify/components/sales/app/models/concerns/sales/line_item_common.rb", ":p")) | buffer areas/core/shopify/components/sales/app/models/concerns/sales/line_item_common.rb | else | edit areas/core/shopify/components/sales/app/models/concerns/sales/line_item_common.rb | endif
if &buftype ==# 'terminal'
  silent file areas/core/shopify/components/sales/app/models/concerns/sales/line_item_common.rb
endif
balt areas/core/shopify/components/taxes/app/utils/tax_engine/line_item_calculator.rb
setlocal fdm=syntax
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
4
normal! zo
5
normal! zo
let s:l = 34 - ((33 * winheight(0) + 26) / 53)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 34
normal! 0
wincmd w
argglobal
enew
balt areas/core/shopify/components/checkouts/core/app/models/cart_line.rb
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=10
setlocal fml=1
setlocal fdn=10
setlocal fen
wincmd w
2wincmd w
exe '1resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 1resize ' . ((&columns * 31 + 140) / 281)
exe '2resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 2resize ' . ((&columns * 124 + 140) / 281)
exe '3resize ' . ((&lines * 53 + 33) / 67)
exe 'vert 3resize ' . ((&columns * 124 + 140) / 281)
exe '4resize ' . ((&lines * 10 + 33) / 67)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
