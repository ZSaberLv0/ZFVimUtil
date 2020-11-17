
" ============================================================
" ZFHttpServer
command! -nargs=? ZFHttpServerStart :call ZFHttpServerStart(<f-args>)
command! -nargs=0 ZFHttpServerStop :call ZFHttpServerStop()

function! ZFHttpServerStart(...)
    let port = get(a:, 1, 8080)
    if empty(ZFPython())
        echo '[ZFHttpServer] no python available'
        return
    endif
    if ZFPythonVersion() >= 3
        let cmd = ZFPython() . ' -m http.server ' . port
    else
        let cmd = ZFPython() . ' -m SimpleHTTPServer ' . port
    endif
    let path = fnamemodify(getcwd(), ':~')
    echo '[ZFHttpServer] started at port ' . port . ', path: ' . path
    if exists('*ZFAsyncRun')
        call ZFAsyncRun(cmd, 'ZFHttpServer:' . path)
    else
        call system(cmd)
    endif
endfunction

function! ZFHttpServerStop()
    if exists('*ZFAsyncRun')
        let path = fnamemodify(getcwd(), ':~')
        call ZFAsyncRunStop('ZFHttpServer:' . path)
    endif
endfunction

