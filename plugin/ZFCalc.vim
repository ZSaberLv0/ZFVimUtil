
" calc
function! ZFCalc(pattern)
    if has('python3')
        let cmd = 'python3'
    elseif has('python')
        let cmd = 'python'
    else
        echo 'python not available'
        return
    endif
    let cmd .= ' '
    let cmd .= 'import math;'
    let cmd .= 'from math import *;'
    let cmd .= 'print(' . a:pattern . ')'
    try
        silent! let result = ZF_ExecCmd(cmd)
    catch
        echo v:exception
        return
    endtry
    let result = substitute(result, '\.0\+$', '', '')
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

command! -nargs=+ -complete=custom,ZFCalcComplete ZFCalc :call ZFCalc(<q-args>)

