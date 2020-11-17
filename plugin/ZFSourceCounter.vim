
" ============================================================
" ZFSourceCounter
command! -nargs=* ZFSourceCounter call ZF_SourceCounter(<f-args>)

if !exists('g:ZFSourceCounterExtList')
    let g:ZFSourceCounterExtList=[
                \   'md', 'vim', 'txt',
                \   'h', 'c', 'hpp', 'cpp',
                \   'java',
                \   'py', 'rb', 'lua', 'js', 'ts', 'php',
                \ ]
endif
" ext,count,line
if !exists('g:ZFSourceCounterSortMode')
    let g:ZFSourceCounterSortMode='line'
endif

function! ZF_SourceCounter(...)
    if a:0
        let extList = a:000
    else
        let extList = g:ZFSourceCounterExtList
    endif
    let extMap = {}
    for ext in extList
        let extMap[ext] = 1
    endfor
    let result = s:ZF_SourceCounter_count(extMap)
    let result = sort(result, function('s:ZF_SourceCounter_sort'))
    call s:ZF_SourceCounter_print(result)
    return result
endfunction
function! s:ZF_SourceCounter_count(extMap)
    redraw
    echo '[ZFSourceCounter] collecting files...'
    let result = []
    let files = globpath(getcwd(), '**/*.*', 0, 1)
    for file in files
        let ext = fnamemodify(file, ':e')
        if empty(get(a:extMap, ext))
            continue
        endif
        redraw
        echo '[ZFSourceCounter] checking: ' . fnamemodify(file, ':t')
        let lines = str2nr(matchstr(system('wc -l "'. fnameescape(file) . '"'), '\d\+'))
        let found = 0
        for item in result
            if item[0] == ext
                let item[1] += 1
                let item[2] += lines
                let found = 1
                break
            endif
        endfor
        if found
            continue
        endif
        call add(result, [ext, 1, lines])
    endfor
    return result
endfunction
function! s:ZF_SourceCounter_sort(a, b)
    let m = get(g:, 'ZFSourceCounterSortMode')
    let field = 2
    if m == 'count'
        let field = 1
    elseif m == 'ext'
        let field = 0
    endif
    return a:a[field] == a:b[field] ? 0 : a:a[field] > a:b[field] ? -1 : 1
endfunction
function! s:ZF_SourceCounter_print(result)
    let msg = "[ZFSourceCounter] result:\n"
    let headList = ['ext', 'count', 'line']
    let widthList = [strwidth(headList[0]), strwidth(headList[1]), strwidth(headList[2])]
    for item in a:result
        if widthList[0] < strwidth(item[0])
            let widthList[0] = strwidth(item[0])
        endif
        if widthList[1] < strwidth(item[1])
            let widthList[1] = strwidth(item[1])
        endif
        if widthList[2] < strwidth(item[2]) + 1
            let widthList[2] = strwidth(item[2])
        endif
    endfor

    let msg .= s:ZF_SourceCounter_printLine(headList, widthList)
    let msg .= "\n"
    for item in a:result
        let msg .= s:ZF_SourceCounter_printLine(item, widthList)
    endfor
    let msg .= "\n"

    redraw!
    echo msg
endfunction
function! s:ZF_SourceCounter_printLine(item, widthList)
    return ' '
                \ . ' ' . repeat(' ', a:widthList[0] - strwidth(a:item[0])) . a:item[0]
                \ . ' ' . repeat(' ', a:widthList[1] - strwidth(a:item[1])) . a:item[1]
                \ . ' ' . repeat(' ', a:widthList[2] - strwidth(a:item[2])) . a:item[2]
                \ . "\n"
endfunction

