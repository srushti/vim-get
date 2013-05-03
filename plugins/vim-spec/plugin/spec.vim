" Ruby Single Spec
"
" Description: Plugin for running a single Ruby test under the cursor
"              Supports TestUnit and Rspec
" Last Change:	Nov 19, 2009
" Version: 1.0.1
" Author:	Doug McInnes <doug@dougmcinnes.com>
" URL: http://github.com/dmcinnes/ruby_single_test/tree
"
" When a ruby test file with your cursor within a test block, hit
" <leader>.
" and that test, and only that test, will run in quickfix.
" That's it!
"
" To remap the command, to <leader>t for instance, add something
" like this to your .vimrc:
" nmap <silent> <leader>t <Plug>ExecuteRubySpec
"
" Ruby Single Spec default to using make! with a bang.  To disable
" this behavior drop this in your .vimrc:
" let g:ruby_single_test_no_bang = 1
"
"
" TODO: add Shoulda support

if exists("loaded_ruby_single_spec")
  finish
endif
let loaded_ruby_single_spec = 1

function! s:ExecuteRubySpec()
  let old_make = &makeprg
  try
    let &l:makeprg = "zeus rspec -l " . line(".") . " " . expand("%:p")
    exe 'make'
    cwindow
  finally
    let &l:makeprg = old_make
  endtry
endfunction

function! s:ExecuteAllRubySpecs()
  let old_make = &makeprg
  try
    let &l:makeprg = "bundle exec rspec " . expand("%:p") . " --format documentation "
    exe 'make'
    cwindow
  finally
    let &l:makeprg = old_make
  endtry
endfunction

augroup RUBY_SINGLE_TEST
  au!
  au BufNewFile,BufRead *_test.rb let &l:makeprg = "ruby"
augroup END

nmap <unique> <script> <Plug>ExecuteRubySpec <SID>ExecuteRubySpec
nmap <unique> <script> <Plug>ExecuteAllRubySpecs <SID>ExecuteAllRubySpecs
nmap <SID>ExecuteRubySpec  :call <SID>ExecuteRubySpec()<CR>
nmap <SID>ExecuteAllRubySpecs  :call <SID>ExecuteAllRubySpecs()<CR>

if !hasmapto('<Plug>ExecuteRubySpec')
  nmap <silent> <leader>. <Plug>ExecuteRubySpec
  nmap <silent> <leader>' <Plug>ExecuteAllRubySpecs
endif
