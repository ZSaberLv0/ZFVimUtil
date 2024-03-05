
command! -nargs=1 ZFReadToTmp :call ZFReadToTmp(<q-args>)

function! ZFReadToTmp(url)
    let to = tempname()
    if !ZFDownload(to, a:url)
        return 0
    endif
    if v:version < 800
        " some old vim would cause strange issue, reason unknown
        noautocmd execute 'noautocmd edit ' . substitute(to, ' ', '\\ ', 'g')
    else
        execute 'edit ' . substitute(to, ' ', '\\ ', 'g')
    endif
    return 1
endfunction

