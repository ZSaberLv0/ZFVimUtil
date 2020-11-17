
function! ZFPython()
    if !exists('s:py')
        if 0
        elseif executable('py3')
            let s:py = 'py3'
            let s:pyVersion = 3
        elseif executable('python3')
            let s:py = 'python3'
            let s:pyVersion = 3
        elseif executable('py')
            let s:py = 'py'
            let s:pyVersion = 2
        elseif executable('python')
            let s:py = 'python'
            let s:pyVersion = 2
        else
            let s:py = ''
            let s:pyVersion = -1
        endif
    endif
    return s:py
endfunction

function! ZFPythonVersion()
    if !exists('s:pyVersion')
        call ZFPython()
    endif
    return s:pyVersion
endfunction

