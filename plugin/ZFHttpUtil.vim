
" ============================================================
" ZFHttpLength
command! -nargs=1 ZFHttpLength :call ZFHttpLength(<q-args>)

function! ZFHttpLength(url)
    if !executable('curl')
        echo 'curl not available'
        return -1
    endif

    let info = system(printf('curl -sI "%s"', a:url))
    " (?<=content-length: *)[0-9]+\>
    let len = matchstr(info, '\%(content-length: *\)\@<=[0-9]\+\>')
    if empty(len)
        return -1
    else
        return str2nr(len)
    endif
endfunction

" ============================================================
" ZFHttpDownload
command! -nargs=+ ZFHttpDownload :call ZFHttpDownload(<f-args>)

function! ZFHttpDownload(dst, url, ...)
    let rangeL = get(a:, 1, 0)
    let rangeR = get(a:, 2, 0)
    if rangeR <= rangeL
        let rangeR = 0
    elseif rangeR > 0
        let rangeR -= 1
    endif

    if !executable('curl')
        echo 'curl not available'
        return 0
    endif

    if rangeL > 0 || rangeR > 0
        let cmd = printf('curl -o "%s" --range %s-%s "%s"'
                    \ , a:dst
                    \ , rangeL > 0 ? rangeL : 0
                    \ , rangeR > 0 ? rangeR : ''
                    \ , a:url
                    \ )
    else
        let cmd = printf('curl -o "%s" "%s"'
                    \ , a:dst
                    \ , a:url
                    \ )
    endif
    call system(cmd)
    return v:shell_error == '0'
endfunction

