
" ============================================================
" fold brace
function! ZF_FoldBrace(brace)
    execute "normal! va" . a:brace
    normal! zf
    echo "fold to" a:brace
endfunction
command! -nargs=+ ZFFoldBrace :call ZF_FoldBrace(<q-args>)

" trim tail spaces
function! ZF_TrimTailSpaces()
    silent! %s/[ \t]\+$//g
    echo 'trim tail spaces'
endfunction
command! -nargs=0 ZFTrimTailSpaces :call ZF_TrimTailSpaces()

" convert tab to space
function! ZF_ConvertTabToSpace()
    silent! %s/\t/    /g
    echo 'convert tab to space'
endfunction
command! -nargs=0 ZFConvertTabToSpace :call ZF_ConvertTabToSpace()

" delete duplicated lines
function! ZF_DeleteDuplicatedLines()
    sort
    g/^\(.\+\)$\n\1\n/d
    normal! gg
endfunction
command! -nargs=0 ZFDeleteDuplicatedLines :call ZF_DeleteDuplicatedLines()

" convert endl
function! ZF_EolUnix()
    set fileformat=unix
    update
endfunction
command! -nargs=0 ZFEolUnix :call ZF_EolUnix()
function! ZF_EolMac()
    set fileformat=mac
    update
endfunction
command! -nargs=0 ZFEolMac :call ZF_EolMac()
function! ZF_EolDos()
    set fileformat=dos
    update
endfunction
command! -nargs=0 ZFEolDos :call ZF_EolDos()

" convert BOM
function! ZF_BomOn()
    set bomb
    update
endfunction
command! -nargs=0 ZFBomOn :call ZF_BomOn()
function! ZF_BomOff()
    set nobomb
    update
endfunction
command! -nargs=0 ZFBomOff :call ZF_BomOff()

" convert encoding
function! ZF_EncUnicode()
    set fileencoding=utf-16le
    set bomb
    update
endfunction
command! -nargs=0 ZFEncUnicode :call ZF_EncUnicode()
function! ZF_EncUtf8()
    set fileencoding=utf-8
    set nobomb
    update
endfunction
command! -nargs=0 ZFEncUtf8 :call ZF_EncUtf8()
function! ZF_EncAnsi()
    set fileencoding=cp936
    set nobomb
    update
endfunction
command! -nargs=0 ZFEncAnsi :call ZF_EncAnsi()

" toggle wrap
function! ZF_ToggleWrap()
    setlocal wrap!
    setlocal wrap?
endfunction
command! -nargs=0 ZFToggleWrap :call ZF_ToggleWrap()

" toggle window size
function! ZF_ToggleWindowSize()
    if &lines > 30 && &columns > 100
        set lines=30 columns=100
    else
        set lines=150 columns=300
    endif
    echo &lines &columns
endfunction
command! -nargs=0 ZFToggleWindowSize :call ZF_ToggleWindowSize()


" util method
function! ZF_Convert()
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'trim tail spaces', 'command':'call ZF_TrimTailSpaces()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'tab to space', 'command':'call ZF_ConvertTabToSpace()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'delete duplicated lines', 'command':'call ZF_DeleteDuplicatedLines()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'EOL to Unix', 'command':'call ZF_EolUnix()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'EOL to Mac', 'command':'call ZF_EolMac()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'EOL to DOS', 'command':'call ZF_EolDos()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'BOM on', 'command':'call ZF_BomOn()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'BOM off', 'command':'call ZF_BomOff()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'encoding to unicode', 'command':'call ZF_EncUnicode()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'encoding to UTF8', 'command':'call ZF_EncUtf8()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'encoding to ANSI', 'command':'call ZF_EncAnsi()'})

    call ZF_VimCmdMenuShow({'headerText':'convert options:'})
endfunction

" util method
function! ZF_Toggle()
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'wrap', 'command':'call ZF_ToggleWrap()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'window size', 'command':'call ZF_ToggleWindowSize()'})

    call ZF_VimCmdMenuShow({'headerText':'toggle:'})
endfunction

