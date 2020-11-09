
" ============================================================
" quick convert hexmial/decimal/binary numbers
function! ZF_NumberHexToDec(n)
    return str2nr(a:n, 16)
endfunction
function! ZF_NumberDecToHex(n)
    return printf('%X', str2nr(a:n, 10))
endfunction
function! ZF_NumberHexToBin(n)
    return ZF_NumberDecToBin(ZF_NumberHexToDec(a:n))
endfunction
function! ZF_NumberBinToHex(n)
    return ZF_NumberDecToHex(ZF_NumberBinToDec(a:n))
endfunction
function! ZF_NumberDecToBin(n)
    let l:n = str2nr(a:n, 10)
    let l:r = ""
    while n
        let l:r = '01'[l:n % 2] . l:r
        let l:n = l:n / 2
    endwhile
    return l:r
endfunction
function! ZF_NumberBinToDec(n)
    let l:n = a:n
    let l:r = 0
    while strlen(l:n) != 0
        let l:r = l:r * 2
        if strpart(l:n, 0, 1) != 0
            let l:r = l:r + 1
        endif
        let l:n = strpart(l:n, 1)
    endwhile
    return l:r
endfunction

function! ZF_NumberConvert(...)
    if a:0 == 3 && len(a:1) == 1 && len(a:2) == 1
        let cmd = a:1 . a:2 . a:3
    else
        echo 'number convert'
        echo '  (d)ecimal'
        echo '  (h)eximal'
        echo '  (b)inary'
        echo '  e.g. convert A2 from hex to dec "hdA2"'
        call inputsave()
        let cmd=input("input: ")
        call inputrestore()
        let cmd_len=strlen(cmd)
        if cmd_len <= 2
            redraw!
            return
        endif
        redraw!
    endif

    if cmd[0] == 'd'
        let from='Dec'
    elseif cmd[0] == 'h'
        let from='Hex'
    elseif cmd[0] == 'b'
        let from='Bin'
    else
        echo 'invalid cmd ' . cmd[0] . ' at index 0'
        return
    endif

    if cmd[1] == 'd'
        let to='Dec'
    elseif cmd[1] == 'h'
        let to='Hex'
    elseif cmd[1] == 'b'
        let to='Bin'
    else
        echo 'invalid cmd ' . cmd[1] . ' at index 1'
        return
    endif

    let num = substitute(cmd, '..\(.*\)', '\1', 'g')
    execute 'let result = ZF_Number' . from . 'To' . to . '("' . num . '")'
    call ZF_setClipboard(result)
    echo result
    return result
endfunction
command! -nargs=* ZFNumberConvert :call ZF_NumberConvert(<f-args>)

