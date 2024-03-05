
command! -nargs=1 ZFReadToTmp :call ZFReadToTmp(<q-args>)

function! ZFReadToTmp(url)
    let to = tempname()
    if !ZFDownload(to, a:url)
        return 0
    endif
    try
        execute 'edit ' . substitute(to, ' ', '\\ ', 'g')
    catch
        return 0
    endtry
    return 1
endfunction

