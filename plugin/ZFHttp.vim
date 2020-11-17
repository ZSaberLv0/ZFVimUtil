
" ============================================================
" ZFHttpServer
command! -nargs=? ZFHttpServerStart :call ZFHttpServerStart(<f-args>)
command! -nargs=? ZFHttpServerStop :call ZFHttpServerStop(<f-args>)
command! -nargs=0 ZFHttpServerStopAll :call ZFHttpServerStopAll()

" {
"   serverId : {
"     'path' : '',
"     'port' : '',
"   },
" }
if !exists('s:serverList')
    let s:serverList = {}
endif

function! ZFHttpServerStart(...)
    if empty(ZFPython())
        echo '[ZFHttpServer] no python available'
        return
    endif
    let serverInfo = {
                \   'path' : fnamemodify(getcwd(), ':~'),
                \   'port' : get(a:, 1, 8080),
                \ }
    if ZFPythonVersion() >= 3
        let cmd = ZFPython() . ' -m http.server ' . serverInfo['port']
    else
        let cmd = ZFPython() . ' -m SimpleHTTPServer ' . serverInfo['port']
    endif
    echo '[ZFHttpServer] started at port ' . serverInfo['port'] . ', path: ' . serverInfo['path']
    if exists('*ZFAsyncRun')
        call ZFAsyncRun(cmd, s:serverId(serverInfo))
        let s:serverList[s:serverId(serverInfo)] = serverInfo
    else
        call system(cmd)
    endif
endfunction

function! ZFHttpServerStop(...)
    if exists('*ZFAsyncRun')
        let serverInfo = {
                    \   'path' : fnamemodify(getcwd(), ':~'),
                    \   'port' : get(a:, 1, 8080),
                    \ }
        call ZFAsyncRunStop(s:serverId(serverInfo))
        if exists('s:serverList[s:serverId(serverInfo)]')
            unlet s:serverList[s:serverId(serverInfo)]
        endif
    endif
endfunction

function! ZFHttpServerStopAll()
    for serverId in keys(s:serverList)
        call ZFAsyncRunStop(serverId)
    endfor
endfunction

function! ZFHttpServerList()
    return values(s:serverList)
endfunction

function! s:serverId(serverInfo)
    return 'ZFHttpServer:' . a:serverInfo['path'] . ':' . a:serverInfo['port']
endfunction

