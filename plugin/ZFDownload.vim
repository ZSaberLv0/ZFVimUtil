
function! ZFDownload(to, url)
    if !exists('s:ZFDownload_cmd')
        if executable('curl')
            let s:ZFDownload_cmd = 'curl -o "%s" -L "%s"'
            let s:ZFDownload_sizeGetter = 'curl -sI "%s"'
        elseif executable('wget')
            let s:ZFDownload_cmd = 'wget -P "%s" "%s"'
            let s:ZFDownload_sizeGetter = 'curl -sI "%s"'
        else
            let s:ZFDownload_cmd = ''
            let s:ZFDownload_sizeGetter = ''
        endif
    endif
    if empty(s:ZFDownload_cmd)
        echo 'no curl or wget available'
        return 0
    endif

    let tmp = tempname()
    let to = substitute(a:to, '\\', '/', 'g')
    let parent = fnamemodify(CygpathFix_absPath(to), ':h')
    if !isdirectory(parent)
        call mkdir(parent, 'p')
    endif

    if filereadable(to)
        let existSize = getfsize(to)
        if existSize >= 0
            let remoteSize = -1
            for line in split(system(printf(s:ZFDownload_sizeGetter, a:url)), '[\r\n]')
                if match(line, '\ccontent-length') >= 0
                    let remoteSize = str2nr(matchstr(line, '[0-9]\+'))
                    break
                endif
            endfor
            if remoteSize == existSize
                return 1
            endif
        endif
    endif

    let ret = system(printf(s:ZFDownload_cmd, substitute(tmp, '\\', '/', 'g'), a:url))
    if v:shell_error != 0
        echo 'unable to download (' . v:shell_error . '), url: ' . a:url
        return 0
    endif

    call writefile(readfile(tmp, 'b'), to, 'b')
    call delete(tmp)
    return 1
endfunction

