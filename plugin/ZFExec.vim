
" ============================================================
" internal function
function! ZF_getTermEncoding()
    if exists('g:ZF_ExecShell_encoding')
        return g:ZF_ExecShell_encoding
    endif
    if match(&shell, 'cmd') < 0 || match(system('sh --version'), '[0-9]\+\.[0-9]\+\.[0-9]\+') >= 0
        return 'utf-8'
    endif

    let cp = system("@echo off && for /f \"tokens=2* delims=: \" %a in ('chcp') do (echo %a)")
    let cp = 'cp' . substitute(cp, '[\r\n]', '', 'g')
    return cp
endfunction
function! ZF_convertTermText(text)
    let cp = ZF_getTermEncoding()
    if empty(cp)
        return a:text
    else
        return iconv(a:text, cp, &encoding)
    endif
endfunction
function! ZF_setClipboard(data)
    if has('clipboard')
        let @* = a:data
    endif
    let @" = a:data
endfunction


" ============================================================
" run shell and copy result to clipboard
function! ZF_ExecShell(expr)
    redraw!
    try
        let result = system(a:expr)
    catch
        echo v:exception
        return ''
    endtry
    let result = ZF_convertTermText(result)
    let result = substitute(result, '^\n\(.*\)', '\1', 'g')
    let result = substitute(result, '^\(.*\)\n', '\1', 'g')

    call ZF_setClipboard(result)
    redraw!
    echo result
    return result
endfunction
if exists('*getcompletion')
    function! ZF_ExecShell_complete(ArgLead, CmdLine, CursorPos)
        if exists('*ZFJobCmdComplete')
            return ZFJobCmdComplete(a:ArgLead, a:CmdLine, a:CursorPos)
        else
            return getcompletion(a:ArgLead, 'file')
        endif
    endfunction
    command! -nargs=+ -complete=customlist,ZF_ExecShell_complete ZFExecShell :call ZF_ExecShell(<q-args>)
else
    command! -nargs=+ -complete=file ZFExecShell :call ZF_ExecShell(<q-args>)
endif

" run command and copy result to clipboard
function! ZF_ExecCmd(expr)
    if exists('*execute')
        let @" = execute(a:expr, '')
    else
        try
            redir @"
            execute a:expr
        finally
            redir END
        endtry
    endif
    let result = @"
    let result = substitute(result, '^\n\(.*\)', '\1', 'g')
    let result = substitute(result, '^\(.*\)\n', '\1', 'g')
    call ZF_setClipboard(result)
    return result
endfunction
command! -nargs=+ -complete=command ZFExecCmd :call ZF_ExecCmd(<q-args>)


" ============================================================
" open all files in clipboard
function! ZF_OpenAllFileInClipboard()
    for file in split(@", "\n")
        let file = substitute(file, '^[\t ]*', '', 'g')
        let file = substitute(file, '[\t ]*$', '', 'g')
        if empty(file)
            continue
        endif
        execute ':edit ' . file
    endfor
endfunction
command! -nargs=0 ZFOpenAllFileInClipboard :call ZF_OpenAllFileInClipboard()

" run all files in clipboard by system editor
function! ZF_RunAllFileInClipboard()
    for file in split(@", "\n")
        let file = substitute(file, '^[\t ]*', '', 'g')
        let file = substitute(file, '[\t ]*$', '', 'g')
        if empty(file)
            continue
        endif
        call ZFRunFile(file)
    endfor
endfunction
command! -nargs=0 ZFRunAllFileInClipboard :call ZF_RunAllFileInClipboard()

function! ZFRunFile(path)
    if !exists('s:haskdeinit')
        let s:haskdeinit = system("ps -e") =~ 'kdeinit'
    endif
    if !exists('s:hasdarwin')
        let s:hasdarwin = system("uname -s") =~ 'Darwin'
    endif

    let l:oldssl=&shellslash
    set noshellslash

    if has("gui_running")
        let args = shellescape(a:path,1)." &"
    else
        let args = shellescape(a:path,1)." > /dev/null"
    end

    if has("unix") && executable("gnome-open") && !s:haskdeinit
        exe "silent !gnome-open ".args
        let ret= v:shell_error
    elseif has("unix") && executable("kde-open") && s:haskdeinit
        exe "silent !kde-open ".args
        let ret= v:shell_error
    elseif has("unix") && executable("open") && s:hasdarwin
        exe "silent !open ".args
        let ret= v:shell_error
    elseif has("win32") || has("win64")
        exe "silent !start explorer ".shellescape(a:path,1)
    end
    let &shellslash=l:oldssl

    return ret == 0
endfunction

" run shell script in clipboard
function! ZF_RunShellScriptInClipboard()
    let tmp_file = tempname()
    call writefile(split(@", "\n"), tmp_file)
    let result = system('sh ' . tmp_file)
    call delete(tmp_file)
    let result = ZF_convertTermText(result)
    redraw!
    let result = substitute(result, '^\n\(.*\)', '\1', 'g')
    let result = substitute(result, '^\(.*\)\n', '\1', 'g')
    call ZF_setClipboard(result)
    echo result
endfunction
command! -nargs=0 ZFRunShellScriptInClipboard :call ZF_RunShellScriptInClipboard()

" run vim command in clipboard
function! ZF_RunVimCommandInClipboard()
    let result = ''
    for cmd in split(@", "\n")
        if len(cmd) <= 0
            continue
        endif
        if len(result)
            let result .= "\n"
        endif

        if exists('*execute')
            let t = execute(cmd)
        else
            try
                redir => t
                silent! execute cmd
            finally
                redir END
            endtry
        endif

        let t = substitute(t, '^\n\(.*\)', '\1', 'g')
        let t = substitute(t, '^\(.*\)\n', '\1', 'g')
        let result .= t
    endfor
    call ZF_setClipboard(result)
    echo result
endfunction
command! -nargs=0 ZFRunVimCommandInClipboard :call ZF_RunVimCommandInClipboard()

