
" ============================================================
" open system browser
function! ZF_OpenBrowser(url)
    if has("win32") || has("win64")
        " windows
        execute "silent !cmd /c start " . a:url
    elseif has("unix")
        silent! let s:uname=system("uname")
        if s:uname=="Darwin\n"
            " mac
            call system('open "' . a:url . '"')
        else
            " unix
            call system('xdg-open "' . a:url . '"')
        endif
    endif
endfunction
command! -nargs=1 ZFOpenBrowser :call ZF_OpenBrowser(<q-args>)

