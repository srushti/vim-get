" -----------------------------------------------------------------------------
" | VIM Settings |
" | GUI stuff |
" -----------------------------------------------------------------------------


" OS Specific *****************************************************************
if has("gui_macvim")

  set fuoptions=maxvert,maxhorz " fullscreen options (MacVim only), resized window when changed to fullscreen
  "set fullscreen
  set guifont=Monaco:h11
  set transparency=10
  macmenu &File.New\ Tab key=<nop>
  map <D-t> :CtrlP<CR>

elseif has("gui_gtk2")

  set guifont=Courier\ 10\ pitch

  set noerrorbells
  set visualbell
  set t_vb=

elseif has("x11")
elseif has("gui_win32")
end

colorscheme camouflage
let g:airline_theme="solarized"

set guioptions-=T " remove toolbar

" General *********************************************************************
set anti " Antialias font

"set transparency=0

" Default size of window
set columns=120
set lines=45

" Tab headings
set gtl=%t gtt=%F
