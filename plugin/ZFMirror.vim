
if !exists('g:ZFMirrorPreset')
    let g:ZFMirrorPreset = {
                \   'China' : {
                \     'npm' : {
                \       'mirror' : 'https://registry.npm.taobao.org',
                \       'shell' : [
                \         'npm -g config set registry https://registry.npm.taobao.org',
                \       ],
                \     },
                \     'pip' : {
                \       'mirror' : 'https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple',
                \       'shell' : [
                \         'pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple',
                \         'pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple',
                \       ],
                \     },
                \   },
                \ }
endif

function! ZFMirror()
    if empty(g:ZFMirrorPreset)
        echo 'no mirror preset'
        return
    endif
    if len(g:ZFMirrorPreset) == 1
        let preset = g:ZFMirrorPreset[keys(g:ZFMirrorPreset)[0]]
    else
        let keys = keys(g:ZFMirrorPreset)
        let choice = ZFChoice('choose mirror preset:', keys)
        if choice < 0 || choice >= len(keys)
            echo 'canceled'
            return
        endif
        let preset = g:ZFMirrorPreset[keys[choice]]
    endif

    let hint = 'about to modify global mirror configs:'
    for name in keys(preset)
        let hint .= printf("\n    %s => %s", name, preset[name]['mirror'])
    endfor
    let hint .= "\n"
    let hint .= "\nenter `got it` to continue: "
    call inputsave()
    let input = input(hint)
    call inputrestore()
    if input != 'got it'
        redraw
        echo 'canceled'
        return
    endif

    redraw
    if exists('*ZF_system')
        let Fn = function('ZF_system')
    else
        let Fn = function('system')
    endif
    for name in keys(preset)
        let config = preset[name]
        let T_checker = get(config, 'checker', '')
        if !empty(T_checker) && !T_checker()
            continue
        endif

        let T_shell = get(config, 'shell', '')
        if !empty(T_shell)
            if type(T_shell) == type('')
                let result = Fn(T_shell)
                if v:shell_error != '0'
                    echo result
                endif
            elseif type(T_shell) == type([])
                for t in T_shell
                    let result = Fn(t)
                    if v:shell_error != '0'
                        echo result
                    endif
                endfor
            elseif type(T_shell) == type(function('type'))
                call T_shell()
            endif
        endif

        let T_cmd = get(config, 'cmd', '')
        if !empty(T_cmd)
            if type(T_cmd) == type('')
                execute T_cmd
            elseif type(T_cmd) == type([])
                for t in T_cmd
                    execute t
                endfor
            elseif type(T_cmd) == type(function('type'))
                call T_cmd()
            endif
        endif
    endfor
endfunction

