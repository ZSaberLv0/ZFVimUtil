
command! -nargs=* ZFWordCount :call ZFWordCount(<q-args>)

function! ZFWordCount(...)
    let param = get(a:, 1, '')
    if empty(param)
        let file = expand('%')
        if empty(file) || !filereadable(file) || &modified
            let content = s:getlines()
        else
            let content = join(readfile(file), "\n")
        endif
    elseif filereadable(param)
        if &modified
            let content = s:getlines()
        else
            let content = join(readfile(file), "\n")
        endif
    else
        let content = param
    endif
    let ret = len(content)
    echo ret
    return ret
endfunction

function! s:getlines()
    let ret = ''
    for i in range(1, line('$'))
        let ret .= getline(i)
        let ret .= "\n"
    endfor
    return ret
endfunction

