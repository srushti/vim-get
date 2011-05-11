" ----------------------------------------------------------------------------
" Vim plugin for various pair operations
" Last Change: 2011 Apr 20
" Maintainer:  Martin Lafreniere <pairtools@gmail.com>
"
" Copyright (C) 2011 by Martin Lafrenière
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and permit persons to whom the Software is furnished
" to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NOT EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.


if exists("g:loaded_PairTools")
    finish
endif
let g:loaded_PairTools = 1

let s:save_cpo = &cpo
set cpo&vim

"============================================================================
" Util Functions ---{{{1

function! s:EscapePair(Char) " --- {{{2
    " Sanitize some characters for regular expressions
    if has_key(b:SpecialPairs, a:Char)
        return ["\\".a:Char, "\\".b:ClosePairs[a:Char]]
    endif

    return [a:Char, b:ClosePairs[a:Char]]

endfunction


function! s:GetUnmatchedPair(Line) " --- {{{2

    " Setup regex to remove matched pairs
    let regexTable = []

    for key in keys(b:ClosePairsSame)
        let qEsc   = s:EscapePair(key)[0]
        " Double quotes string uses escaped characters!
        if key == '"'
            call add(regexTable, qEsc.'[^\\'.qEsc.']*\%(\\.[^\\'.qEsc.']*\)*'.qEsc )
        else
            call add(regexTable, qEsc.'[^'.qEsc.']*'.qEsc )
        endif
    endfor
    
    let regex = '\%(' . join(regexTable, '\|') . '\)'
    
    " Remove matched pairs
    let line  = a:Line
    let index = match(line, regex)

    while index > -1
        let match = matchstr(line, regex)
        if index > 0
            let line = line[:(index - 1)] . line[(strlen(match) + index):]
        else
            let line = line[strlen(match):]
        endif
        let index = match(line, regex)
    endwhile

    return line

endfunction


function! s:InsertAfterCursor(Start, Line, ClosePairs) " --- {{{2

    let column  = col('.')-1
    let prefix = (column == 0 ? "" : a:Line[:(column - 1)])

    call setline('.', prefix . a:ClosePairs[a:Start] . a:Line[(column):]) 

endfunction


function! s:SmartCloseRegex(Char) " --- {{{2

    let rules = b:SmartCloseRules

    " Check if pair symbol was specified
    let pairsTable = []

    if match(escape(rules, '\'), '\%(^\^\|,\^\)') > -1
        " Remove pair symbols from rules
        let rules = substitute(rules, '\%(^\^\%(,\|\)\|,\^\)', '', "")

        for pair in keys(b:ClosePairs)
            if pair == b:ClosePairs[pair] && pair == a:Char
                continue
            endif
            call add(pairsTable, pair)
        endfor
    endif

    let rulesTable = split(rules, ',')
    let rulesTable = extend(rulesTable, pairsTable)

    return '\%(' . join(rulesTable, '\|') . '\)'

endfunction

" }}}1
"============================================================================
" Antimagic Field ---{{{1

function! s:GetCurrentSyntax() " --- {{{2
    
    let column = col('.')
    let fixedColumn = (column == col('$') ? column-1 : column)

    return synIDattr(synIDtrans(synID(line('.'), fixedColumn, 1)), 'name')

endfunction


function! s:StringSyntaxRegex() " --- {{{2

    let regex = []

    if index(b:AntimagicField, "String") > -1
        call add(regex, "String")
    endif

    if index(b:AntimagicField, "Special") > -1
        call add(regex, "Special")
    endif

    " C++ syntax uses Constant Field for character inside a single quotes
    if index(b:AntimagicField, "Constant") > -1
        call add(regex, "Constant")
    endif

    return '\%(' . join(regex, '\|') . '\)'

endfunction


function! s:IsComment() " --- {{{2

    if !b:Antimagic
        return 0
    endif

    return index(b:AntimagicField, "Comment") > -1 && s:GetCurrentSyntax() == "Comment"

endfunction


function! s:IsString(Char) " --- {{{2

    if a:Char != '"'
        return ""
    endif

    let currentLine = getline('.')
    let column = col('.')-1

    let line = s:GetUnmatchedPair(currentLine)

    if currentLine[column-1] == '\' && line =~ '\'
        call setline('.', currentLine[:(column-2)].currentLine[(column):])
        call setpos('.', [bufnr('%'), line('.'), column, 0])
    endif

    let syntax = s:GetCurrentSyntax() 

    call setpos('.', [bufnr('%'), line('.'), column+1, 0])
    call setline('.', currentLine)

    return syntax

endfunction


function! s:IsConstant(Char) " --- {{{2

    let currentLine = getline('.')
    let column         = col('.')-1

    let prefix = (column == 0 ? "" : currentLine[:(column-1)])
    call setline('.', prefix . a:Char . currentLine[(column):])
    
    let syntax = s:GetCurrentSyntax()

    call setline('.', currentLine)

    return syntax

endfunction


function! s:IsAntimagicField(Char) " --- {{{2
    
    if !b:Antimagic
        return 0
    endif
   
    let currentSyntax = s:GetCurrentSyntax() 

    let stringSyntax = ""
    if index(b:AntimagicField, "String") > -1
        let stringSyntax  = s:IsString(a:Char)
        if currentSyntax != "String" && stringSyntax == "String"
            return 1
        endif
    endif

    let constantSyntax = ""
    if index(b:AntimagicField, "Constant") > -1
        let constantSyntax = s:IsConstant(a:Char)
        if currentSyntax != "Constant" && constantSyntax == "Constant"
            return 1 
        endif
    endif
    
    return index(b:AntimagicField, currentSyntax) > -1 

endfunction    


function! s:IsMoveOut(Line) " --- {{{2 

    if s:GetUnmatchedPair(a:Line) =~ '\'
        return 0 
    endif

    let column   = col('.')-1
    let regex = s:StringSyntaxRegex() 

    " Go along the line until new syntax field others than
    " String or Special or EOL
    let columnCount = 1
    while s:GetCurrentSyntax() =~ regex && (column+columnCount) < col('$')
        call setpos('.', [bufnr('%'), line('.'), column + 1 + columnCount, 0])
        let columnCount += 1
    endwhile
    
    " Get last character of previous syntax field
    let last = a:Line[col('.')-2]

    " Since the cursor was moved along the line, replace it back
    call setpos('.', [bufnr('%'), line('.'), column+1, 0])
    
    return a:Line[column] == last

endfunction

" }}}1
"============================================================================
" Section handling pairs using different symbols ---{{{1

function! s:CountPairs(Char, Line) " --- {{{2

    let a = 1 
    let pairCount = 0
    for char in split(a:Line, '\zs')
        if char == a:Char
           let pairCount += 1
        elseif char == b:ClosePairsDiff[a:Char]
           let pairCount -= 1
        endif
    endfor
    return pairCount

endfunction


function! s:AllowClose(Start, Line) " --- {{{2
    
    if s:IsAntimagicField(a:Start)
        return 0
    endif

    if b:SmartClose && a:Line[col('.')-1] =~ s:SmartCloseRegex(a:Start)
        return 0
    endif

    return s:CountPairs(a:Start, a:Line) > -1

endfunction


function! s:CloseCurrentPair(Start) " --- {{{2
    
    let line = getline('.')

    if s:AllowClose(a:Start, line)
        call s:InsertAfterCursor(a:Start, line, b:ClosePairsDiff)
    endif
    return a:Start

endfunction


function! s:MoveOutCurrentPair(End) " --- {{{2
    
    let result = a:End

    if s:IsComment()
        return result
    endif

    let line = getline('.')

    if line[col('.')-1] == a:End 
        " The only time the user can move out is on the delimiter of the field
        if !s:IsAntimagicField(a:End) || (s:IsAntimagicField(a:End) && s:IsMoveOut(line))
            call setpos('.', [bufnr('%'), line('.'), col('.')+1, 0])
            return ""
        endif
    endif
    return result

endfunction

" }}}1
"============================================================================
" Section handling pairs using both the same symbol ---{{{1

function! s:CountSymbols(Char, Line) " --- {{{2

    let line = s:GetUnmatchedPair(a:Line) 

    " Count remaining symbols
    return count(split(line, '\zs'), a:Char)

endfunction


function! s:AllowQuotes(Char, Line) " --- {{{2
    
    let column = col('.')-1        

    if s:IsAntimagicField(a:Char)
        if !s:IsComment() && a:Line[column] == a:Char
            return s:IsMoveOut(a:Line)
        endif
        return 0
    endif
    
    if b:SmartClose && a:Line[column] =~ s:SmartCloseRegex(a:Char)
        return 0
    endif

    return s:CountSymbols(a:Char, a:Line) % 2 == 0

endfunction



function! s:FixCurrentPair(Char) " --- {{{2

    let line   = getline('.')
    let result = a:Char
    if s:AllowQuotes(a:Char, line)
        if line[col('.')-1] != a:Char 
            call s:InsertAfterCursor(a:Char, line, b:ClosePairsSame)
        else
            let result = ""
            call setpos('.', [bufnr('%'), line('.'), col('.')+1, 0])
        endif
    endif

    return result

endfunction

" }}}1
"============================================================================
" Forced-Pairs ---{{{1

function! s:InsertPair(Char) " --- {{{2

    call s:InsertAfterCursor(a:Char, getline('.'), b:ClosePairs)
    return a:Char

endfunction

" }}}1
"============================================================================
" Backspace Feature ---{{{1

function! s:Backspace() " --- {{{2

    let result = "\<BS>"

    let column  = col('.')-1
    let line = getline('.')
    let char = line[column-1]

    "if get(b:ClosePairs, char, "!!") == "!!"
    if !has_key(b:ClosePairs, char)
        return result
    endif
   
    if line[(column-1):(column)] == char.b:ClosePairs[char]

        " Remove pair and set cursor back one character to check magic
        if column > 1
            call setline('.', line[:(column-2)].line[(column+1):])
        else
            call setline('.', line[(column+1):])
        endif
        call setpos('.', [bufnr('%'), line('.'), column, 0])

        " Fields like strings and comments prevents pair deletion
        if s:IsAntimagicField("")
            call setline('.', line)
        else
            call setline('.', line[:(column-1)].line[(column+1):])
        endif
        
        " Set previously moved cursor back to origin
        call setpos('.', [bufnr('%'), line('.'), column+1, 0])

    endif

    return result

endfunction

" }}}1
"============================================================================
" Expansion Feature ---{{{1

function! s:ExpandCarriageReturn() " --- {{{2

    let column  = col('.')-1
    let row  = line('.')
    let line = getline('.')

    for key in keys(b:ClosePairs)
        if line[(column-1):(column)] == key.b:ClosePairs[key]
            " Keep indentation clean
            let startSpace = match(line, '\S\+')

            " Do actual expansion equivalent to <CR><CR><UP><TAB>
            call setline('.',  line[:(column-1)])
            call append(row,   repeat(' ', startSpace + &l:shiftwidth))
            call append(row+1, repeat(' ', startSpace) . line[(column):])
            
            " Place the cursor as though the user pressed tab for indentation
            call setpos('.', [bufnr('%'), row+1, startSpace + &l:shiftwidth+1, 0])
            
            return ""
        endif
    endfor
    return "\<CR>"

endfunction

" }}}1
"============================================================================
" Surround Feature ---{{{1

function! s:SurroundInline(Char, Line, Start, End) " --- {{{2

    let prefix = (a:Start.col > 0 ? a:Line[:(a:Start.col-1)] : "")
    let middle = a:Line[(a:Start.col):(a:End.col)]
    let suffix = a:Line[(a:End.col+1):]
    
    call setline(a:Start.line, prefix.a:Char.middle.b:ClosePairs[a:Char].suffix) 
    call setpos('.', [bufnr('%'), a:Start.line, a:Start.col+1, 0])

endfunction


function! s:SurroundBlock(Char, Start, End) " --- {{{2

    let lines = getbufline('%', a:Start.line, "$")

    let nbTotalLines  = len(lines)
    let nbSelectLines = a:End.line - a:Start.line + 1
    let nbLastLines   = nbTotalLines - nbSelectLines

    " Match first non-blank character for indentation
    let firstPos = -1
    let index    = 0
    while firstPos == -1 
        let firstPos = match(lines[index], '\S\+')
        let index += 1
    endwhile
    
    call setline(a:Start.line, repeat(' ', firstPos).a:Char)
    " Insert text from selection
    for lineCount in range(nbSelectLines)
        call setline(a:Start.line + 1 + lineCount, repeat(' ', &l:shiftwidth).lines[lineCount])
    endfor

    call setline(a:Start.line + nbSelectLines + 1, repeat(' ', firstPos).b:ClosePairs[a:Char])
    " Insert remaining text
    for lineCount in range(nbLastLines)
        call setline(a:Start.line + nbSelectLines + 2 + lineCount, lines[nbSelectLines + lineCount])
    endfor

endfunction


function! s:SurroundSelect(Char) " --- {{{2

    let start    = {'col': col("'<")-1, 'line': line("'<")}
    let end      = {'col': col("'>")-1, 'line': line("'>")}
    let line     = getline(start.line)
    let lineWide = strlen(line) - end.col
    let nbLines  = end.line - start.line + 1

    "if get(b:ClosePairs, a:Char, "!!") == "!!"
    if !has_key(b:ClosePairs, a:Char)
        call setpos('.', [bufnr('%'), start.line, start.col+1, 0])
        return
    endif

    if nbLines == 1 && lineWide > 0
        call s:SurroundInline(a:Char, line, start, end)
    else
        let currentLine = line('.')
        if currentLine == start.line
            call s:SurroundBlock(a:Char, start, end)
        endif
        if currentLine == end.line
            let cursorColumn = match(getline(start.line), '\S\+')
            call setpos('.', [bufnr('%'), start.line, cursorColumn+1, 0])
        endif
    endif

endfunction

" }}}1
"============================================================================
" Section handling maps ---{{{1

function! s:ExtractClosePairs(ClosePairs) " --- {{{2

    let pairs = {}
    exe "let closePairs = " . a:ClosePairs

    for stringPairs in split(closePairs, ',')
        let pair = split(stringPairs, ':')
        let pairs[pair[0]] = pair[1]
    endfor
    return pairs

endfunction


function! s:ExtractAntimagicField(AntimagicField) " --- {{{2

    exe "let antimagicField = " . a:AntimagicField
    return split(antimagicField, ',')

endfunction

function! s:SetMapped(Maps, Start, End, Add) " --- {{{2

    if a:Add
        let a:Maps[a:Start] = a:End
    else
        call remove(a:Maps, a:Start)
    endif

endfunction


function! s:SanitizeMap(Map) " --- {{{2

    if has_key(b:SpecialMaps, a:Map)
        return b:SpecialMaps[a:Map]
    endif

    return a:Map

endfunction


function! s:CleanPairToolsMaps() " --- {{{2

    " Clean up the maps
    if b:AutoCloseMaps
        for map in keys(b:ClosePairsMaps)
            let closeMap = b:ClosePairsMaps[map]

            call s:SetMapped(b:ClosePairsMaps, map, "", 0)
            if map != closeMap
                exe "iunmap <buffer> <silent> " . closeMap
            endif

            let map = s:SanitizeMap(map)
            
            exe "iunmap <buffer> <silent> " . map
            if !b:ForcedPairsMaps
                if map != b:SpecialMaps['|']
                    exe "iunmap <buffer> <silent> <M-" . map . ">"
                else
                    exe "iunmap <buffer> <silent> <C-\\>" . map
                endif
            else
                exe "iunmap <buffer> <silent> " . b:PrevForcedPairsMapping . map
            endif
        endfor
        let b:AutoCloseMaps = 0
    endif

    if b:SurroundMaps
        for map in keys(b:SurroundPairsMaps)
            call s:SetMapped(b:SurroundPairsMaps, map, "", 0)

            let special = get(b:SpecialMaps, map, "!!")
            if special != "!!"
                let map = special
            endif
            exe "vunmap <buffer> <silent> " . map
        endfor
        let b:SurroundMaps = 0
    endif

    if b:PairDeletionMaps
        exe "iunmap <buffer> <silent> <BS>"
        let b:PairDeletionMaps = 0
    endif

    if b:CRExpandMaps
        exe "iunmap <buffer> <silent> <CR>"
        let b:CRExpandMaps = 0
    endif

endfunction


function! s:SetPairToolsMaps() " --- {{{2

    for start in keys(b:ClosePairsDiff)
        let end = b:ClosePairsDiff[start]
        let startArg = '"\' . start . '"'
        let endArg   = '"\' . end   . '"' 
        
        let start = s:SanitizeMap(start)
        let end   = s:SanitizeMap(end)

        if b:AutoClose 

            exe "inoremap <buffer> <silent> " . start . " <C-R>=<SID>CloseCurrentPair("   . startArg . ")<CR>"
            exe "inoremap <buffer> <silent> " . end   . " <C-R>=<SID>MoveOutCurrentPair(" . endArg   . ")<CR>"
            
            if b:ForcedPairsMapping == ""
                if start != b:SpecialMaps['|']
                    exe "inoremap <buffer> <silent> <M-" . startArg[2] . "> <C-R>=<SID>InsertPair(" . startArg .")<CR>"
                else
                    exe "inoremap <buffer> <silent> <C-\\>" . start . " <C-R>=<SID>InsertPair(" . startArg .")<CR>"
                endif
                let b:ForcedPairsMaps = 0
            else
                exe "inoremap <buffer> <silent> " . b:ForcedPairsMapping . start . " <C-R>=<SID>InsertPair(" . startArg . ")<CR>"
                let b:ForcedPairsMaps = 1
            endif
            
            call s:SetMapped(b:ClosePairsMaps, start, end, 1)
            let b:AutoCloseMaps = 1

        endif

        if b:Surround
            exe "vnoremap <buffer> <silent> " . start . " :call <SID>SurroundSelect(" . startArg . ")<CR>"
            call s:SetMapped(b:SurroundPairsMaps, start, end, 1)
            let b:SurroundMaps = 1
        endif
    endfor

    for start in keys(b:ClosePairsSame)
        let startArg = '"\' . start . '"'

        let start = s:SanitizeMap(start)

        if b:AutoClose

            exe "inoremap <buffer> <silent> " . start . " <C-R>=<SID>FixCurrentPair(" . startArg . ")<CR>"

            if b:ForcedPairsMapping == ""
                if start != b:SpecialMaps['|']
                    exe "inoremap <buffer> <silent> <M-" . start . "> <C-R>=<SID>InsertPair(" . startArg .")<CR>"
                else
                    exe "inoremap <buffer> <silent> <C-\\>" . start . " <C-R>=<SID>InsertPair(" . startArg .")<CR>"
                endif
                let b:ForcedPairsMaps = 0
            else
                exe "inoremap <buffer> <silent> " . b:ForcedPairsMapping . start . " <C-R>=<SID>InsertPair(" . startArg . ")<CR>"
                let b:ForcedPairsMaps = 1
            endif

            call s:SetMapped(b:ClosePairsMaps, startArg[2], startArg[2], 1)
            let b:AutoCloseMaps = 1

        endif

        if b:Surround
            exe "vnoremap <buffer> <silent> " . start . " :call <SID>SurroundSelect(" . startArg . ")<CR>"
            call s:SetMapped(b:SurroundPairsMaps, startArg[2], startArg[2], 1)
            let b:SurroundMaps = 1
        endif
    endfor

    if b:PairDeletion
        inoremap <buffer> <silent> <BS> <C-R>=<SID>Backspace()<CR>
        let b:PairDeletionMaps = 1
    endif

    if b:CRExpand 
        inoremap <buffer> <silent> <CR> <C-R>=<SID>ExpandCarriageReturn()<CR>
        let b:CRExpandMaps = 1
    endif

endfunction


" Enable plugin
function! s:SetPairToolsOptions() " --- {{{2

    let b:SpecialPairs = {'*': '*', '.': '.', '$': '$'}
    let b:SpecialMaps  = {'|': '<Bar>'}

    let b:AutoClose = 1
    let b:FT_AutoClose = "g:" . &ft . "_autoclose"
    if exists(b:FT_AutoClose)
        exe "let b:AutoClose = " . b:FT_AutoClose
    endif
    if !exists('b:AutoCloseMaps')
        let b:AutoCloseMaps = 0
    endif

    " Define default pairs and add user-defined ones 
    " if its not already included
    let b:ClosePairs = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"'}
    let b:FT_ClosePairs = "g:" . &ft . "_closepairs"
    if exists(b:FT_ClosePairs) 
        let b:ClosePairs = s:ExtractClosePairs(b:FT_ClosePairs)
    endif
    if !exists('b:ClosePairsMaps')
        let b:ClosePairsMaps = {}
    endif
    if !exists('b:SurroundPairsMaps')
        let b:SurroundPairsMaps = {}
    endif

    let b:ClosePairsDiff = {}
    let b:ClosePairsSame = {}
    for b:key in keys(b:ClosePairs)
        if b:key == b:ClosePairs[b:key]
            let b:ClosePairsSame[b:key] = b:ClosePairs[b:key]
        else
            let b:ClosePairsDiff[b:key] = b:ClosePairs[b:key]
        endif
    endfor

    " Forced-Pairs mappings
    if exists('b:ForcedPairsMapping')
        let b:PrevForcedPairsMapping = b:ForcedPairsMapping
    endif
    let b:ForcedPairsMapping = ""

    let b:FT_ForcedPairsMapping = "g:" . &ft . "_forcedpairskey"
    if exists(b:FT_ForcedPairsMapping)
        exe "let b:ForcedPairsMapping = ". b:FT_ForcedPairsMapping
    endif
    if !exists('b:ForcedPairsMaps')
        let b:ForcedPairsMaps = 0
    endif


    " Antimagic Field Feature
    let b:Antimagic = 1
    let b:FT_Antimagic = "g:" . &ft . "_antimagic"
    if exists(b:FT_Antimagic)
        exe "let b:Antimagic = " . b:FT_Antimagic
    endif
    " Make sure the plugin doesn't apply its magic 
    " to close pairs in these areas of syntax
    let b:AntimagicField = ["Comment", "String"]
    let b:FT_AntimagicField = "g:" . &ft . "_antimagicfield"
    if exists(b:FT_AntimagicField)
        let b:AntimagicField = s:ExtractAntimagicField(b:FT_AntimagicField)
    endif

    " Smart Auto-Close
    let b:SmartClose = 1
    let b:FT_SmartClose = "g:" . &ft . "_smartclose"
    if exists(b:FT_SmartClose)
        exe "let b:SmartClose = " . b:FT_SmartClose
    endif

    let b:SmartCloseRules = '^,\w'
    let b:FT_SmartCloseRules = "g:" . &ft . "_smartcloserules"
    if exists(b:FT_SmartCloseRules)
        exe "let b:SmartCloseRules = " . b:FT_SmartCloseRules
    endif

    " Backspace Feature
    let b:PairDeletion = 1
    let b:FT_PairDeletion = "g:" . &ft . "_pairdeletion"
    if exists(b:FT_PairDeletion)
        exe "let b:PairDeletion = " . b:FT_PairDeletion
    endif
    if !exists('b:PairDeletionMaps')
        let b:PairDeletionMaps = 0
    endif
    
    " Enable Surround Feature 
    let b:Surround = 1
    let b:FT_Surround = "g:" . &ft . "_surround"
    if exists(b:FT_Surround)
        exe "let b:Surround = " . b:FT_Surround 
    endif
    if !exists('b:SurroundMaps')
        let b:SurroundMaps = 0
    endif
    
    " Enable <CR> Expansion Feature
    let b:CRExpand = 1
    let b:FT_CRExpand = "g:" . &ft . "_crexpand"
    if exists(b:FT_CRExpand)
        exe "let b:CRExpand = " . b:FT_CRExpand
    endif
    if !exists('b:CRExpandMaps')
        let b:CRExpandMaps = 0
    endif


    let b:PairTools = 1
    let b:FT_PairTools = "g:" . &ft . "_pairtools"
    if exists(b:FT_PairTools)
        exe "let b:PairTools = " . b:FT_PairTools
    endif

endfunction


" Setup PairTools in current buffer
function! s:SetupBuffer() " --- {{{2
    
    call s:SetPairToolsOptions()
    call s:CleanPairToolsMaps()
    if b:PairTools
        call s:SetPairToolsMaps()
        let  b:loaded_PairTools = 1
    endif

endfunction

function! s:IsLoadedPlugin() " {{{2

    return exists("b:loaded_PairTools") && b:loaded_PairTools

endfunction

" }}}1

autocmd FileType * call <SID>SetupBuffer()
autocmd BufNewFile,BufRead,BufEnter * if !<SID>IsLoadedPlugin() | call <SID>SetupBuffer() | endif

let &cpo = s:save_cpo

" vim: set ft=vim ff=unix et sw=4 ts=4 foldmethod=marker :
