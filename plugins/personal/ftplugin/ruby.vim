" vim.vim - PairTools Configuration
" Maintainer: Martin Lafreniere <pairtools@gmail.com>
" Last Change: 2011 May 18
"
" This is my own configuration file for C++.
" It is free to use, modify and distribute. It is provided "AS IS" with no 
" warranty.

" Enable/Disable modules to use. For C++, I don't need the Tag Wrench
" module at all.
let g:pairtools_ruby_pairclamp = 1
let g:pairtools_ruby_tagwrench = 1
let g:pairtools_ruby_jigsaw    = 1

" Configure PairClamp
let g:pairtools_ruby_autoclose  = 1
let g:pairtools_ruby_forcepairs = 0
let g:pairtools_ruby_closepairs = "(:),[:],{:},':',\":\""
let g:pairtools_ruby_smartclose = 1
let g:pairtools_ruby_smartcloserules = '\w,(,&,\*'
let g:pairtools_ruby_apostrophe = 0
let g:pairtools_ruby_antimagic  = 1
let g:pairtools_ruby_antimagicfield  = "Comment,String,Special"
let g:pairtools_ruby_pcexpander = 1
let g:pairtools_ruby_pceraser   = 1

" Configure TagWrench
let g:pairtools_ruby_tagwrenchhook = 'tagwrench#BuiltinNoHook'
let g:pairtools_ruby_twexpander = 0
let g:pairtools_ruby_tweraser   = 0


