syntax on

" set nu			" set number
" set rnu			" set relative number
set noerrorbells		" disable bells
set softtabstop=8		" visible tab width
set tabstop=8			" real tab width
set noexpandtab
set shiftwidth=8		" tab width for smart indent
set smartindent			" smart indent when texting
set nowrap			" no wrap the lines
set smartcase			" case sensitive searching until put capital letter
set noswapfile
set nobackup
set undodir=~/.vim/undodir	" undo directory
set undofile			" keep undos
set vif=~/.vim/.viminfofile	" set viminfofile for marks
set incsearch			" search while typing
set hlsearch			" highlight search string
set splitright			" start new split on right
set hidden			" switch between buffers without saving

set nocompatible		" be iMproved, required
set whichwrap=<,>,[,]		" jump between lines
set ttimeoutlen=0		" ESC response timeout
filetype off			" required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'		    " Plugin manager
Plugin 'preservim/nerdtree'		    " Tree Explorer
Plugin 'mbbill/undotree'		    " Showing undo tree
Plugin 'junegunn/fzf'			    " Fuzzy file, buffer, mru, tag, etc finder.
Plugin 'junegunn/fzf.vim'		    " Fuzzy file, buffer, mru, tag, etc finder.
Plugin 'rking/ag.vim'			    " For faster search
Plugin 'thaerkh/vim-workspace'		    " Manage sessions
" Plugin 'Valloric/YouCompleteMe'		    " Auto completer
Plugin 'airblade/vim-gitgutter'		    " shows a git diff in the sign column
Plugin 'preservim/tagbar'		    " shows tags for a current file
" Plugin 'scrooloose/syntastic'		    " awesome syntax checker
Plugin 'morhetz/gruvbox'		    " for colorscheme
Plugin 'vim-airline/vim-airline'	    " status bar
Plugin 'vim-airline/vim-airline-themes'	    " status bar themes
Plugin 'zivyangll/git-blame.vim'		" git blame
Plugin 'Kadiryanik/cs-in-qf.vim'        " cscope in quickfix
Plugin 'tpope/vim-fugitive'
call vundle#end()	    " required
filetype plugin indent on   " required

" FIX:
"   https://stackoverflow.com/questions/64479087/vim-8-2-problems-with-unicode
"   -> https://vi.stackexchange.com/questions/27399/whats-t-te-and-t-ti-added-by-vim-8/27400#27400
"
"   Printing charecter like that '[>4;m[>4;2m'
"   Mostly caused by gitgutter and tagbar for me.
set t_TI=
set t_TE=

" leader key
nnoremap <SPACE> <Nop>
let mapleader = " "

" Easy jump for marks
nnoremap , `

" disable syntax checker
let g:ycm_show_diagnostics_ui = 0

" toggle line numbers
map <F2> :set nu!<CR>
map <F4> :set rnu!<CR>
map <F5> :!cscope -qR<CR>:cs reset<CR>
map <F9> :set ignorecase!<CR>
map <F10> :e ~/.vimrc<CR>
map <F12> :set whichwrap=<,>,[,]<CR>

" load cscope if exist
if filereadable("cscope.out")
    :cs add cscope.out
endif

" open tagbar using mostly for FunctionList
"     f: Jump to tagbar window when opening
"     j: Jumpt to tagbar if already open
"     c: close tagbar on tag selection
map <F8> :TagbarOpen fjc<CR>
map <leader>fl :TagbarOpen fjc<CR>

" open new terminal
nmap <leader><leader>t :term bash<CR>
nmap <leader><leader>T :vert term bash<CR>
" switch terminal to normal mode
tnoremap <C-n> <C-w>N
" quit terminal split and bash
tnoremap <C-x> <C-w>:bd!<CR>

" copy to clipboard
vmap <C-c> "+y
" paste from clipboard
map <C-p> "+p

" find selected
vnoremap <leader>f y/<C-R>"<CR>
" replace selected
vnoremap <leader>rs y:%s/<C-R>"//gic
" replace word
vnoremap <leader>rw y:%s/\<<C-R>"\>//gic

" indent profile default (with tab)
nmap <leader>ipd :set noexpandtab tabstop=8 softtabstop=4 shiftwidth=4<CR>
" indent profile 8 (with tab)
nmap <leader>ip8 :set noexpandtab tabstop=8 softtabstop=8 shiftwidth=8<CR>

" indent profile space 2
nmap <leader>ips2 :set expandtab tabstop=2 softtabstop=2 shiftwidth=2<CR>
" indent profile space 3
nmap <leader>ips3 :set expandtab tabstop=3 softtabstop=3 shiftwidth=3<CR>
" indent profile space 4
nmap <leader>ips4 :set expandtab tabstop=4 softtabstop=4 shiftwidth=4<CR>
" indent profile space 8
nmap <leader>ips8 :set expandtab tabstop=8 softtabstop=8 shiftwidth=8<CR>

" maps for navigate between splits
nnoremap <leader>w <C-w>w
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" no highlight
nnoremap <silent> <leader>nh :nohl<CR>

" open Vertical and Horizontal split
nnoremap <silent> <leader>sv <C-w>v
nnoremap <silent> <leader>sh <C-w>S
" rotate splits forward, backward, exchange
nnoremap <silent> <leader>sr <C-w>r
nnoremap <silent> <leader>sR <C-w>R
nnoremap <silent> <leader>sx <C-w>x

" resize horizontal split
nnoremap <silent> <leader><leader>+ :resize +5<CR>
nnoremap <silent> <leader><leader>- :resize -5<CR>
" resize vertical split
nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>

" show undo tree
nnoremap <leader>u :UndotreeShow<CR>

" I don't use it anymore, I use CSCOPE instead.
" " creating tag file: ctags -R *
" " ctags: go defination
" nmap <silent> <leader>gd <C-]>
" " ctags: go back (prev tag)
" nmap <silent> <leader>gb <C-t>

" go references
" 0 Find this C symbol:
" 1 Find this function definition:
" 2 Find functions called by this function:
" 3 Find functions calling this function:
" 4 Find this text string:
" 5 Change this text string:
" 6 Find this egrep pattern:
" 7 Find this file:
" 8 Find files #including this file:
nmap <silent> <leader>gr :YcmCompleter GoToReferences<CR>

" CSCOPE shortcuts. Creating cscope file: cscope -q -R
" find this C symbol
nmap <leader><leader>0 :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <leader>0 :Qcs s<CR>
" find this definition
nmap <leader><leader>1 :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <leader>1 :Qcs g<CR>
" find functions called by this function
nmap <leader><leader>2 :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <leader>2 :Qcs d<CR>
" find functions calling this function
nmap <leader><leader>3 :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <leader>3 :Qcs c<CR>
" find this text string
nmap <leader><leader>4 :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <leader>4 :Qcs t<CR>
" find this egrep pattern
nmap <leader><leader>5 :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <leader>5 :Qcs e<CR>
" find this file
nmap <leader><leader>6 :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <leader>6 :Qcs f<CR>
" find files #including this file
nmap <leader><leader>7 :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <leader>7 :Qcs i<CR>
" find places where this symbol is assigned a value
nmap <leader><leader>8 :cs find a <C-R>=expand("<cword>")<CR><CR>
nmap <leader>8 :Qcs a<CR>

" quickfix
nnoremap <silent> <C-j> :cprevious<CR>
nnoremap <silent> <C-n> :cnext<CR>
nnoremap <silent> <C-q> :ToggleQF<CR>
 
" cscope shortcuts.
" find this C symbol
nmap <leader><leader>s :Qcs s<CR>
" find this definition
nmap <leader><leader>g :Qcs g<CR>
" find functions called by this function
nmap <leader><leader>d :Qcs d<CR>
" find functions calling this function
nmap <leader><leader>c :Qcs c<CR>
" find this text string
" nmap <leader><leader>t :Qcs t<CR>
" find this egrep pattern
nmap <leader><leader>e :Qcs e<CR>
" find this file
nmap <leader><leader>f :Qcs f<CR>
" find files #including this file
nmap <leader><leader>i :Qcs i<CR>
" find places where this symbol is assigned a value
nmap <leader><leader>a :Qcs a<CR>

" buffer shortcuts
nmap <leader>bp :bp<CR>
nmap <leader>bn :bn<CR>
nmap <leader>bd :bd<CR>

" git blame
nnoremap <Leader><leader>b :<C-u>call gitblame#echo()<CR>

" nerdTree maps
nnoremap <silent> <leader>t :NERDTreeToggle<CR>
nnoremap <silent> <leader>gf :NERDTreeFind<CR>

" vim-workspace gives error when nerd tree left open in session
" so close it and quit all for successfully session restore
nnoremap <silent> <leader>qa :NERDTreeClose<CR>:qa!<CR>
nnoremap <silent> <leader>qw :NERDTreeClose<CR>:wqa<CR>
nnoremap <silent> <leader>qq :NERDTreeClose<CR>:qa<CR>

" move page up and down one line keep cursor same in line
map <C-Up> <C-Y>
map <C-Down> <C-E>
imap <C-Up> <ESC> <C-Y>i
imap <C-Down> <ESC> <C-E>i
" move cursor
map <C-Left> <C-o>
map <C-Right> <C-i>
" move current line up and down
nnoremap <C-S-Up> :move -2<CR>=0
nnoremap <C-S-Down> :move +1<CR>=0
vnoremap <C-S-Up> :move '<-2<CR>gv=gv
vnoremap <C-S-Down> :move '>+1<CR>gv=gv
imap <C-S-Up> <ESC> :move -2<CR>=0i
imap <C-S-Down> <ESC> :move +1<CR>=0i

" managing tabs
nmap <leader>nt :tabnew<CR>
nmap <leader>ct :tabclose<CR>
nnoremap <Tab> gt	" switch the next tab
nnoremap <S-Tab> gT	" switch the prev tab

" move current split to tab
map <leader>st <C-w>T

" highlight, delete, hide trailing charecters
nmap <silent> <leader>WSE :highlight ExtraWhitespace ctermbg=red guibg=red<CR>:match ExtraWhitespace /\s\+$/<CR>
nmap <silent> <leader>WSD :%s/\s\+$//g<CR>
nmap <silent> <leader>WSH :match<CR>

" workspace session settings
let g:workspace_persist_undo_history = 0	" enabled = 1 (default), disabled = 0
let g:workspace_undodir='.undodir'
" let g:workspace_autosave_always = 1
let g:workspace_autosave = 0			" if too much file operation disable it
let g:workspace_autosave_untrailspaces = 0
let g:workspace_autosave_ignore = ['gitcommit']

" FZF settings and shortcuts
" :Files [PATH]		Files (runs $FZF_DEFAULT_COMMAND if defined)
" :GFiles [OPTS]	Git files (git ls-files)
" :GFiles?		Git files (git status)
" :Buffers		Open buffers
" :Colors		Color schemes
" :Ag [PATTERN]		ag search result (ALT-A to select all, ALT-D to deselect all)
" :Rg [PATTERN]		rg search result (ALT-A to select all, ALT-D to deselect all)
" :Lines [QUERY]	Lines in loaded buffers
" :BLines [QUERY]	Lines in the current buffer
" :Tags [QUERY]		Tags in the project (ctags -R)
" :BTags [QUERY]	Tags in the current buffer
" :Marks		Marks
" :Windows		Windows
" :Locate PATTERN	locate command output
" :History		v:oldfiles and open buffers
" :History:		Command history
" :History/		Search history
" :Snippets		Snippets (UltiSnips)
" :Commits		Git commits (requires fugitive.vim)
" :BCommits		Git commits for the current buffer
" :Commands		Commands
" :Maps			Normal mode mappings
" :Helptags		Help tags 1
" :Filetypes		File types

" setup rg for fzf
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" Empty value to disable preview window altogether
let g:fzf_preview_window = ['right:40%:hidden', 'ctrl-w']

" search in whole project
map <F3> :Files<CR>

" buffers list
nmap <leader>bl :Buffers<CR>
" search in current buffer
nmap <leader>bs :BLines<CR>
" search in all buffer
nmap <leader>ba :Lines<CR>

" :Ag [options] {pattern} [{directory}]
" -w		-> whole word with case sensitive
" -w -i		-> whole word without case sensitive
" -s		-> case sensitive
" -Q		-> dont parse pattern as regex
" -G		-> File search regex
" :Ag commands after search
" e    to open file and close the quickfix window
" o    to open (same as enter)
" go   to preview file (open but maintain focus on ag.vim results)
" t    to open in new tab
" T    to open in new tab silently
" h    to open in horizontal split
" H    to open in horizontal split silently
" v    to open in vertical split
" gv   to open in vertical split silently
" q    to close the quickfix window

" find string
nmap <leader>fs :Ag <C-R>=expand("<cword>")<CR><CR>
" find whole word sensitive
nmap <leader>fw :Ag -U -w <C-R>=expand("<cword>")<CR><CR>
" find word sensitive
nmap <leader>fs :Ag -U <C-R>=expand("<cword>")<CR><CR>
" find whole word insensitive
nmap <leader>fi :Ag -U -w -i <C-R>=expand("<cword>")<CR><CR>
" find fill yourself with copying current word into command
nmap <leader>ff :Ag -U -w -s <C-R><C-A>

" syntastic setting. Disabled for now.
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_check_on_open = 0
"  :SyntasticCheck for checking

" gitgutter settings
highlight GitGutterAdd guifg=#009900 ctermfg=Green
highlight GitGutterChange guifg=#bbbb00 ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222 ctermfg=Red
nmap ) :GitGutterNextHunk<CR>
nmap ( :GitGutterPrevHunk<CR>
let g:gitgutter_map_keys = 0
" toggle highlighting
nmap <leader>gh :GitGutterLineHighlightsToggle<CR>

" vim-fugitive mappings
nmap <leader>gs :Git<CR>
nmap <leader>gl :Git log<CR>
nmap <leader>gb :Git blame<CR>
nmap <leader>gm :Git mergetool<CR>
" shows only unstaged changes
nmap <leader>gd :Gvdiffsplit<CR>
nmap <leader>gt :Git difftool<CR>
" shows also staged changes
nmap <leader>ggd :Gvdiffsplit HEAD<CR>
nmap <leader>ggt :Git difftool HEAD<CR>
" jump prev-next in Gvdiff
nmap <A-Left> [c
nmap <A-Right> ]c

" colorscheme settings
colorscheme gruvbox
set background=dark

" airline setting
let g:airline#extensions#tabline#enabled = 1		" enable airline tabline
let g:airline#extensions#tabline#tab_min_count = 2	" minimum of 2 tabs needed to display the tabline
let g:airline#extensions#tabline#tabs_label = ''	" can put text here like BUFFERS to denote buffers (I clear it so nothing is shown)
let g:airline#extensions#tabline#buffers_label = ''	" can put text here like TABS to denote tabs (I clear it so nothing is shown)
let g:airline#extensions#tabline#fnamemod = ':t'	" disable file paths in the tab
let g:airline#extensions#tabline#show_close_button = 0	" remove 'X' at the end of the tabline
let g:airline#extensions#tabline#show_tab_nr = 0	" disable tab numbers
let g:airline#extensions#tabline#show_tab_count = 0	" dont show tab numbers on the right
let g:airline#extensions#tabline#show_buffers = 0	" dont show buffers in the tabline
let g:airline#extensions#tabline#show_splits = 0	" disables the buffer name that displays on the right of the tabline
let g:airline#extensions#tabline#show_tab_type = 0	" disables the weird ornage arrow on the tabline
let g:airline#extensions#whitespace#checks = [ ]	" [ 'indent', 'trailing', 'long', 'mixed-indent-file' ]
let g:airline_section_z = airline#section#create(['windowswap', 'obsession', '%p%%', 'colnr', 'linenr', 'maxlinenr'])

" save and load folding texts
autocmd BufWinLeave *.* mkview!
autocmd BufWinEnter *.* silent loadview

" Remap for destroying trailing whitespace cleanly
nnoremap <Leader>gg :%!cat -s<CR>

nnoremap <Leader>g :let _save_pos=getpos(".") <Bar>
    \ :let _s=@/ <Bar>
    \ :%s/\s\+$//e <Bar>
    \ :let @/=_s <Bar>
    \ :nohl <Bar>
    \ :unlet _s<Bar>
    \ :normal gg=G <Bar>
    \ :call setpos('.', _save_pos)<Bar>
    \ :unlet _save_pos<CR><CR>

" Usefull tips
" u			-> for Undo
" Ctrl+R		-> for Redo
" :e			-> open file
" :mksession		-> create session, give name if you want
" :source session	-> load session
" v			-> visual mode
" Shift+v		-> visual line, for tabbing
" Ctrl+v		-> visual block
" Shift+i		-> insert to visual mode
" Shift+.		-> select tab(>) or shift tab(<)
" cw			-> change word starting cursor pos. in the word
" ciw			-> change word starting begin of the word
" ci", ci(, cit		-> change word in "" or () or tag(for html)
" di{, dip, yi{, yip	-> delete or copy in {} or paragraph
" g;	g,		-> go to last (prev) change, go to more recent (next) change
" <C-o> <C-i>		-> jump old and newer cursor position

"   SEARCH in file
" /\cword		-> case insensitive search
" /\Cword		-> case sensitive search
" /\<word\>		-> search whole word
" *			-> search the current whole word
" :%s/search/replace/g	-> search and replace
" :%s/srch/rep/gic	-> search and replace with asking
"			-> a: all, l: replace and quit, q: quit

"   MARKS
" ma			-> mark with 'a' the current cursor position
" 'a			-> go to line with marked 'a'
" `a			-> go to cursor position with marked 'a'
" [' ]'			-> go to prev, next mark line
" :marks		-> show marks
" :delmarks		-> delete given marks a-z or A-Z or a,x,y
" fe			-> find next 'e' in line, usefull in visual mode
"   BUFFERS
" :bp :bn :ls :b3	-> buffers, prev, next, list, jump buffer-3
" :ba :vert ba :3ba	-> bring all buffers, bring up to 3
" :b <tab>		-> select with name and jump
" :bd <tab>		-> select with name and delete in buffer list
" :sp <sv> :vsp <sh>	-> split horizontal(=), split vertical(||), <leader shortcuts>

"   FOLDS
" zf zd zc zo zE	-> create, delete, close, open fold, eliminate all in file
" zC zO			-> when opened nested folds, open and close at once
" zn zN			-> open all, set all folds as they were before (zn)
" zj zk [z ]z		-> jump to next-prev fold, go to top-bottom of fold
" :% foldclose		-> close all fold in file, foldopen for open
" :set fdm=indent	-> set fold method (manuel,indent,syntax,expr,marker,diff)
" zr zm			-> open-close one level for all folds
" zR zM			-> open-close all level for all folds
" Vi{zf OR zfi{		-> select function body and fold it
" zfa{			-> includes function line too
" zf10j			-> fold next 10 line
" XX,YY fold		-> fold line XX to line YY

"   REGISTERS
" :register		-> show registers
" "ayiw			-> copy inner word to register 'a', a-z available
" "ap			-> paste register 'a' content
" ctrl+r a		-> paste register 'a' content in insert mode
" ctrl+r "		-> paste default register in insert mode

"   MACROS
" qm			-> start to recording macro into register 'm', a-z available
"			-> press q again to stop recording macro when you are done
" @m			-> run macro, whic in register 'm'
" 3@m			-> run 3 times
" :let @b='YOURMACRO'	-> set macro in command mode, ctrl+v before ctrl
"			-> commands, make sure it colorful

"   NUMBERS
" 5ctrl+a ctrl+x	-> increment number by 5, decrement number by 1
" g ctrl+a		-> usefull when setting array index, select in visual
"			-> block mode and type this.
" put =range(10,15)	-> inserts number 10 to 15
" for i in range(10,15) | put = '192.168.1.'.i | endfor
"			-> print ip adresses with range
" :%s/^/\=printf('%-4d', line('.'))
"			-> inserts line number to file
"			-> -4d, left aligned, 4d right aligned

"   VIMDIFF
" vimdiff file1 file2	-> shows diff
" vim -d file1 file2	-> alternative
" ]c [c			-> jump next-prev diff block changes
" :diffupdate		-> update changes
" :diffget		-> get current diff block from other file
" :diffget //2		-> get current diff block from other file (left in merge)
" :diffget //3		-> get current diff block from other file (right in merge)
" :diffput		-> put current diff block to other file

"   VUNDLE plugin manager
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
