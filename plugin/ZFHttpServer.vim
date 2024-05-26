
" ============================================================
" ZFHttpServer
command! -nargs=* -complete=dir ZFHttpServerStart :call ZFHttpServerStart(<f-args>)
command! -nargs=* -complete=dir ZFHttpServerStop :call ZFHttpServerStop(<f-args>)
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
    silent! call ZFHttpServerStop(get(a:, 1, 0), get(a:, 2, ''))

    let port = get(a:, 1, 0)
    if port <= 0
        let port = 8080
    endif
    let path = get(a:, 2, '')
    if empty(path)
        let path = getcwd()
    endif
    let path = fnamemodify(path, ':p')

    let serverInfo = {
                \   'path' : path,
                \   'port' : port,
                \ }
    if !empty(ZFPython())
        if ZFPythonVersion() >= 3
            let cmd = ZFPython() . ' -m http.server ' . serverInfo['port']
        else
            let cmd = ZFPython() . ' -m SimpleHTTPServer ' . serverInfo['port']
        endif
    elseif executable('http-server')
        " npm i http-server
        let cmd = 'http-server .'
                    \ . ' -p ' . serverInfo['port']
                    \ . ' --cors'
    else
        echo '[ZFHttpServer] no python or http-server available'
        return
    endif

    let pathSaved = fnamemodify(getcwd(), ':p')
    echo '[ZFHttpServer] started at port ' . serverInfo['port'] . ', path: ' . fnamemodify(serverInfo['path'], ':.')
    execute 'cd ' . substitute(path, ' ', '\\ ', 'g')
    if exists('*ZFAsyncRun')
        call ZFAsyncRun({
                    \   'jobCmd' : cmd,
                    \   'outputTo' : get(g:, 'ZFHttpServer_outputTo', {
                    \     'outputType' : 'statusline',
                    \     'outputTypeSuccess' : '',
                    \     'outputTypeFail' : '',
                    \   }),
                    \ }, s:serverId(serverInfo))
        let s:serverList[s:serverId(serverInfo)] = serverInfo
    else
        call system(cmd)
    endif
    execute 'cd ' . substitute(pathSaved, ' ', '\\ ', 'g')
endfunction

function! ZFHttpServerStop(...)
    let port = get(a:, 1, 0)
    if port <= 0
        let port = 8080
    endif
    let path = get(a:, 2, '')
    if empty(path) || fnamemodify(path, ':p') == fnamemodify(getcwd(), ':p')
        let path = getcwd()
        for serverInfo in values(s:serverList)
            if serverInfo['port'] == port
                let path = serverInfo['path']
                break
            endif
        endfor
    endif
    let path = fnamemodify(path, ':p')

    let serverInfo = {
                \   'path' : path,
                \   'port' : port,
                \ }
    let serverId = s:serverId(serverInfo)
    if exists('*ZFAsyncRun')
        call ZFAsyncRunStop(serverId)
    endif
    if exists('s:serverList[serverId]')
        unlet s:serverList[serverId]
        echo '[ZFHttpServer] stopped at port ' . port . ', path: ' . fnamemodify(path, ':.')
    else
        echo '[ZFHttpServer] no server at port ' . port . ', path: ' . fnamemodify(path, ':.')
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

