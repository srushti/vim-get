" -----------------------------------------------------------------------------
" | VIM Settings |
" | (see gvimrc for gui vim settings) |
" -----------------------------------------------------------------------------

set nocompatible  " We don't want vi compatibility.

let mapleader = ","
let maplocalleader = "\\"
set wildmenu
set wildmode=list:longest,full
set lazyredraw
set autowriteall
set autoread

if has("nvim")
  set termguicolors
endif

" Show syntax highlighting groups for word under cursor
nmap <C-S-S> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

function! <SID>StripTrailingWhitespaces()
  if mode() == 'n'
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endif
endfunction

if has('autocmd')
  augroup buffer_filetype_autocmds
    au!
    autocmd FileType html let g:html_indent_strict=1
    autocmd BufEnter {Gemfile,Rakefile,Guardfile,Capfile,Vagrantfile,Thorfile,config.ru,*.rabl} setfiletype ruby
    autocmd BufEnter *.template setfiletype json
    autocmd BufEnter *.j setfiletype objc
    autocmd BufEnter *.md setfiletype markdown
    autocmd BufWritePre ?* :call <SID>StripTrailingWhitespaces()
    autocmd BufEnter *.yml.sample setfiletype yaml
    autocmd BufLeave,FocusLost ?* nested :wa
    autocmd BufReadPost #* set bufhidden=delete
    autocmd BufEnter *nginx.conf setfiletype nginx
  augroup END
endif

command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

" Shortcuts********************************************************************
nmap <silent> <unique> <leader>w :w<CR>
nmap <silent> <unique> <leader>W :wa<CR>
nmap <silent> <unique> <leader>p "*p
nmap <silent> <unique> <C-S-Down> :A<CR>
nmap <silent> <unique> <Space> <PageDown>
nmap <silent> <unique> <S-Space> <PageUp>
nmap <silent> <unique> <C-S-Left> <C-o>
nmap <silent> <unique> <C-S-Right> <C-i>
cnoremap %% <C-R>=expand('%:h').'/'<cr>
nmap <unique> <leader>ew :e %%
nmap <unique> <leader>es :sp %%
nmap <unique> <leader>ev :vsp %%
nmap <unique> <leader>et :tabe %%

nnoremap <unique> <C-h> <C-w>h
nnoremap <unique> <C-j> <C-w>j
nnoremap <unique> <C-k> <C-w>k
nnoremap <unique> <C-l> <C-w>l
nnoremap <unique> <C-Tab> <C-w>w
nnoremap <unique> <C-S-Tab> <C-w>W

nnoremap <unique> <S-Tab> <C-o>

inoremap <c-cr> <esc>A<cr>
nnoremap <unique> Y y$

" Help
autocmd FileType help :nnoremap <buffer> <silent> q :q<cr>

" Emacs style ctrl-a & ctrl-e in insert mode
inoremap <c-e> <c-r>=InsCtrlE()<cr>
function! InsCtrlE()
  try
    norm! i
    return "\<c-o>A"
  catch
    return "\<c-e>"
  endtry
endfunction
imap <C-a> <C-o>I

" Tabs ************************************************************************
"set sta " a <Tab> in an indent inserts 'shiftwidth' spaces

" Files, backups and undo******************************************************
" Turn backup off, since most stuff is in SVN, git anyway...
set nobackup
set nowb
set noswapfile

"Persistent undo
try
  if MySys() == "windows"
    set undodir=C:\Windows\Temp
  else
    set undodir=~expand('$HOME/.vim/tmp')
  endif

  set undofile
catch
endtry

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Easy buffer navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l

nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Split line (sister to [J]oin lines)
" The normal use of S is covered by cc, so don't worry about shadowing it.
nnoremap S i<cr><esc><right>

" Better Completion
set completeopt=menu,longest,preview

" Toggle paste
set pastetoggle=<F8>

function! Tabstyle_tabs()
  " Using 4 column tabs
  set softtabstop=4
  set shiftwidth=4
  set tabstop=4
  set noexpandtab
  autocmd User Rails set softtabstop=4
  autocmd User Rails set shiftwidth=4
  autocmd User Rails set tabstop=4
  autocmd User Rails set noexpandtab
endfunction

function! Tabstyle_spaces()
  " Use 2 spaces
  set softtabstop=2
  set shiftwidth=2
  set tabstop=2
  set expandtab
endfunction

if hostname() == "Laptop.local"
  call Tabstyle_tabs()
else
  call Tabstyle_spaces()
endif

" Indenting *******************************************************************
set autoindent " Automatically set the indent of a new line (local to buffer)
set smartindent " smartindent  (local to buffer)

" Scrollbars ******************************************************************
set sidescrolloff=2
set numberwidth=4

" Spaces while joining ********************************************************
set nojoinspaces

" Windows *********************************************************************
set equalalways " Multiple windows, when created, are equal in size
set splitbelow splitright

"Vertical split then hop to new buffer
noremap <leader>v :vsp<CR>
noremap <leader>h :split<CR>

" Cursor highlights ***********************************************************
au WinLeave * set nocursorline nocursorcolumn
au WinEnter,BufEnter * set cursorline cursorcolumn
set cursorline cursorcolumn
set colorcolumn=120

" Searching *******************************************************************
set hlsearch " highlight search
nmap <silent><unique> <leader>? :nohlsearch<CR>
set incsearch " incremental search, search as you type
set ignorecase " Ignore case when searching
set smartcase " Ignore case when searching lowercase

" Colors **********************************************************************
"set t_Co=256 " 256 colors
syntax on " syntax highlighting
colorscheme camouflage

if !has('gui_running')
  let g:airline_theme="solarized"
endif

" Status Line *****************************************************************
set showcmd
set ruler " Show ruler
"set ch=2 " Make command line two lines high
set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%d/%m/%Y-%H:%M\")}\ %{exists('g:loaded_rvm')?rvm#statusline():''}%=\ %l:%c%V\ %L\ %P
set laststatus=2

" Line Wrapping ***************************************************************
set nowrap
set linebreak " Wrap at word
set showbreak=…

" Per-directory .vimrc files
set exrc
set secure

" Mappings ********************************************************************
" Professor VIM says '87% of users prefer jj over esc', jj abrams strongly disagrees
imap jj <Esc>
imap uu _
imap hh =>
imap -- ->
imap aa @

" Directories *****************************************************************
" Setup backup location and enable
"set backupdir=~/backup/vim
"set backup

" Set Swap directory
"set directory=~/backup/vim/swap

" Sets path to directory buffer was loaded from
"autocmd BufEnter * lcd %:p:h

" File Stuff ******************************************************************
filetype plugin indent on
" To show current filetype use: set filetype

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal g'\"" | endif
endif

autocmd FileType html set filetype=xhtml " we couldn't care less about html

" Inser New Line **************************************************************
map <S-Enter> O<ESC>
map <Enter> o<ESC>
set fo-=r " do not insert a comment leader after an enter, (no work, fix!!)

" Sessions ********************************************************************
" Sets what is saved when you save a session
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winsize

" Misc ************************************************************************
set backspace=indent,eol,start
set number " Show line numbers
set matchpairs+=<:>
set vb t_vb= " Turn off the bell, this could be more annoying, but I'm not sure how

" Set list Chars - for showing characters that are not
" normally displayed i.e. whitespace, tabs, EOL
nmap <unique><silent><leader>l :set list!<CR>
set listchars=tab:▸\ ,eol:¬

" Mouse ***********************************************************************
"set mouse=a " Enable the mouse
"behave xterm
"set selectmode=mouse

" " Cursor Movement *************************************************************
" " Make cursor move by visual lines instead of file lines (when wrapping)
map <up> gk
map k gk
" imap <up> <C-o>gk # uncomment at your own risk. it interferes with Fuf.
map <down> gj
map j gj
" imap <down> <C-o>gj # same warning as the imap above.
" map E ge

" Ruby stuff ******************************************************************
compiler ruby " Enable compiler support for ruby
map <F5> :!ruby %<CR>

" Omni Completion *************************************************************
if has('autocmd')
  autocmd FileType html :set omnifunc=htmlcomplete#CompleteTags
  autocmd FileType python set omnifunc=pythoncomplete#Complete
  autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType css set omnifunc=csscomplete#CompleteCSS
  autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
  autocmd FileType php set omnifunc=phpcomplete#CompletePHP
  autocmd FileType c set omnifunc=ccomplete#Complete
  autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete " may require ruby compiled in
  autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
  autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
  autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
endif

" -----------------------------------------------------------------------------
" | Plugins |
" -----------------------------------------------------------------------------

" Airline *********************************************************************
let g:airline_powerline_fonts = 1

" NERDTree ********************************************************************
nmap <silent> <unique> <leader>n :NERDTreeToggle<CR>
nmap <silent> <unique> <leader>/ :NERDTreeFind<CR>

" User instead of Netrw when doing an edit /foobar
let NERDTreeHijackNetrw=1

" Single click for everything
let NERDTreeMouseMode=1

" Ignoring java class files
let NERDTreeIgnore=['.class$', '\~$', '^cscope', 'tags', 'node_modules', '.tmp']

" Rails.vim shortcuts *********************************************************
nmap <silent> <unique> <leader>s :.Rake<CR>
nmap <silent> <unique> <leader>S :Rake<CR>
nmap <silent> <unique> <leader>- :Rake -<CR>

" Fugitive ********************************************************************
autocmd BufReadPost fugitive://* set bufhidden=delete
autocmd BufReadPost *.fugitiveblame set bufhidden=delete
autocmd BufReadPost .git/* set bufhidden=delete
autocmd BufReadPost GoToFile set bufhidden=delete

nnoremap <silent> <leader>gd :Gdiff<cr>
nnoremap <silent> <leader>gs :Gstatus<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>gb :Gblame<cr>
nnoremap <silent> <leader>gci :Gcommit<cr>
nnoremap <silent> <leader>gm :Gmove<cr>
nnoremap <silent> <leader>gr :Gremove<cr>
nnoremap <silent> <leader>gl :Glog<cr>

augroup ft_fugitive
  au!

  au BufNewFile,BufRead .git/index setlocal nolist
augroup END

" yankring*********************************************************************
let g:yankring_history_dir = expand('$HOME/.vim/tmp')
nnoremap <silent> <F6> :YRShow<cr>

" Ctrl-P **********************************************************************
let g:ctrlp_dont_split = 'NERD_tree_2'
let g:ctrlp_jump_to_buffer = 0
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_reversed = 1
let g:ctrlp_split_window = 0
let g:ctrlp_max_height = 20
let g:ctrlp_extensions = ['tag']

if filereadable("/usr/local/bin/fzf") && !has('gui_running')
  set rtp+=/usr/local/opt/fzf
  nnoremap <leader>f :FZF<CR>
else
  let g:ctrlp_map = '<leader>f'
end

let g:ctrlp_prompt_mappings = {
      \ 'PrtSelectMove("j")':   ['<c-j>', '<down>', '<s-tab>'],
      \ 'PrtSelectMove("k")':   ['<c-k>', '<up>', '<tab>'],
      \ 'PrtHistory(-1)':       ['<c-n>'],
      \ 'PrtHistory(1)':        ['<c-p>'],
      \ 'ToggleFocus()':        ['<c-tab>'],
      \ }

let ctrlp_filter_greps = "".
      \ "egrep -iv '\\.(" .
      \ "swp|swo|log|so|o|pyc|jpe?g|png|gif|mo|po|class|jar|DS_Store" .
      \ ")$' | " .
      \ "egrep -v '^(\\./)?(" .
      \ "libs/|deploy/vendor/|.git/|.hg/|.svn/|tmp/|.tmp/|.idea/|node_modules/|.sass-cache/|bower_components/|_vendor/vendor/" .
      \ ")'"

let my_ctrlp_user_command = "" .
      \ "find %s '(' -type f -or -type l ')' -maxdepth 15 -not -path '*/\\.*/*' | " .
      \ ctrlp_filter_greps

let my_ctrlp_git_command = "" .
      \ "cd %s && git ls-files && git ls-files -o | " .
      \ ctrlp_filter_greps

let g:ctrlp_user_command = ['.git/', my_ctrlp_git_command, my_ctrlp_user_command]

nnoremap <leader>t :CtrlPTag<cr>
nnoremap <leader>b :CtrlPBuffer<cr>

" Mundo ***********************************************************************
nmap <silent> <unique> <leader>u :MundoToggle<CR>
"autocmd BufReadPost __Mundo_* set bufhidden=delete

" Tagbar **********************************************************************
nmap <silent> <unique> <leader>c :TagbarToggle<CR>

" Ack *************************************************************************
if has('linux')
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
endif
map <leader>a :Ack!

" Turbux **********************************************************************
let g:no_turbux_mappings = 1

" Git Gutter ******************************************************************
if has('autocmd')
  augroup gitgutter_cmds
    au!
    autocmd BufReadPost ?* GitGutterAll
    autocmd FocusLost ?* GitGutterAll
  augroup END
endif

let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

" Syntastic *******************************************************************

let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_coffee_coffeelint_args = "--reporter csv --file ~/.coffeelint.json"

" autocomplpop ****************************************************************
" complete option
"set complete=.,w,b,u,t,k
"let g:AutoComplPop_CompleteOption = '.,w,b,u,t,k'
"set complete=.
let g:AutoComplPop_IgnoreCaseOption = 0
let g:AutoComplPop_BehaviorKeywordLength = 2

let g:EasyMotion_smartcase = 1

" Unimpaired configuration ****************************************************
" Bubble single lines
nmap <C-Up> [e==
nmap <C-k> [e==
nmap <C-Down> ]e==
nmap <C-j> ]e==
" Bubble multiple lines
vmap <C-Up> [egv=gv
vmap <C-k> [egv=gv
vmap <C-Down> ]egv=gv
vmap <C-j> ]egv=gv

" UltiSnips *******************************************************************

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"


" -----------------------------------------------------------------------------
" | OS Specific |
" | (GUI stuff goes in gvimrc) |
" -----------------------------------------------------------------------------

" Mac *************************************************************************
if has("mac")
endif

" Windows *********************************************************************
"if has("gui_win32")
""
"endif

" -----------------------------------------------------------------------------
" | Startup |
" -----------------------------------------------------------------------------
" Open NERDTree on start
"autocmd VimEnter * exe 'NERDTree' | wincmd l

" Add recently accessed projects menu (project plugin)
filetype on  " Automatically detect file types.

" Minibuffer Explorer Settings
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1

set hid

" alt+n or alt+p to navigate between entries in QuickFix
map <silent><m-p> :cp <CR>
map <silent><m-n> :cn <CR>

" Change which file opens after executing :Rails command
let g:rails_default_file='config/database.yml'

syntax enable

filetype plugin on
set ofu=syntaxcomplete#Complete

" Last but not least, allow for local overrides
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
