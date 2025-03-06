
" ============================================================
" ZFOpenBrowser
command! -nargs=* -range ZFOpenBrowser :call ZF_OpenBrowser(<q-args>)

function! ZF_OpenBrowser(url)
    if empty(a:url)
        try
            let saved = @t
            normal! gv"ty
            let url = @t
        finally
            let @t = saved
        endtry
    else
        let url = a:url
    endif

    if has("win32") || has("win64")
        " windows
        execute "silent !cmd /c start " . url
    elseif has("unix")
        silent! let s:uname=system("uname")
        if s:uname=="Darwin\n"
            " mac
            call system('open "' . url . '"')
        else
            " unix
            call system('xdg-open "' . url . '"')
        endif
    endif
endfunction

