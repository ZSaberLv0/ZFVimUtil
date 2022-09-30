
" ============================================================
" ZFCalc
command! -nargs=+ -complete=custom,ZFCalcComplete ZFCalc :call ZFCalc(<q-args>)

function! ZFCalc(pattern)
    if has('python3')
        let py = 'python3'
    elseif has('python')
        let py = 'python'
    else
        echo 'python not available'
        return
    endif

    let hasNumpy = 0
    try
        silent! call ZF_ExecCmd(
                    \   py
                    \   . ' '
                    \   . 'import numpy;'
                    \ )
    catch
    endtry

    let cmd = py
    let cmd .= ' '
    let cmd .= 'import math;'
    let cmd .= 'from math import *;'
    if hasNumpy
        let cmd .= 'import numpy;'
        let cmd .= 'numpy.set_printoptions(suppress = True);'
        let cmd .= 'print(numpy.format_float_positional(numpy.float32(' . a:pattern . ')))'
    else
        let cmd .= 'print(' . a:pattern . ')'
    endif
    try
        silent! let result = ZF_ExecCmd(cmd)
    catch
        echo v:exception
        return
    endtry

    " (?<=\.[0-9]*[^0]*)0+$
    let result = substitute(result, '\%(\.[0-9]*[^0]*\)\@<=0\+$', '', '')
    " \.+$
    let result = substitute(result, '\.\+$', '', '')
    call ZF_setClipboard(result)
    redraw!
    echo result
    return result
endfunction
function! ZFCalcComplete(ArgLead, CmdLine, CursorPos)
    return join(map(split(
                \ 'acos,acosh,asin,asinh,atan,atan2,atanh,ceil,copysign,cos,cosh,degrees,e,erf,erfc,exp,expm1,fabs,factorial,floor,fmod,frexp,fsum,gamma,gcd,hypot,inf,isclose,isfinite,isinf,isnan,ldexp,lgamma,log,log10,log1p,log2,modf,nan,pi,pow,radians,sin,sinh,sqrt,tan,tanh,tau,trunc'
                \ , ','), 'v:val . "("'), "\n")
endfunction

