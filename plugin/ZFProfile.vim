
" ============================================================
" ZFProfileStart
command! -nargs=0 ZFProfileStart :call ZFProfileStart()

if has('profile')
    let s:ZFProfilePath = get(g:, 'zf_vim_cache_path', $HOME . '/.vim_cache')
    augroup ZFProfile_augroup
        autocmd!
        autocmd VimEnter * call s:ZFProfileCheck()
        autocmd VimLeavePre * call s:ZFProfileExit()
    augroup END
    function! s:ZFProfileCheck()
        if filereadable(s:ZFProfilePath . '/ZFProfile_syntax')
            enew
            execute 'edit ' . substitute(substitute(s:ZFProfilePath . '/ZFProfile_syntax', '\\', '/', 'g'), ' ', '\\ ', 'g')
            setlocal buftype=nofile noswapfile
            call delete(s:ZFProfilePath . '/ZFProfile_syntax')
        endif
        if filereadable(s:ZFProfilePath . '/ZFProfile_profile')
            enew
            execute 'edit ' . substitute(substitute(s:ZFProfilePath . '/ZFProfile_profile', '\\', '/', 'g'), ' ', '\\ ', 'g')
            setlocal buftype=nofile noswapfile
            call delete(s:ZFProfilePath . '/ZFProfile_profile')
        endif
    endfunction
    function! s:ZFProfileExit()
        if !exists('s:ZFProfileStarted')
            return
        endif
        profile pause
        let result = ''
        if exists('*execute')
            let result = execute('syntime report')
        else
            try
                redir => result
                silent syntime report
            finally
                redir END
            endtry
        endif
        call writefile(split(result, "\n"), s:ZFProfilePath . '/ZFProfile_syntax')
    endfunction
endif
function! ZFProfileStart(...)
    if !has('profile')
        echo "[ZFProfile] require has('profile')"
        return
    endif
    if exists('s:ZFProfileStarted')
        echo '[ZFProfile] already started, exit and relaunch vim to see result'
        return
    endif
    let s:ZFProfileStarted = 1
    echo '[ZFProfile] started, operate and relaunch vim to see result'

    syntime on
    execute 'profile start ' . substitute(substitute(s:ZFProfilePath . '/ZFProfile_profile', '\\', '/', 'g'), ' ', '\\ ', 'g')
    profile func *
    profile! file *
endfunction

