
" ============================================================
" ZFDiffBuffer
command! -nargs=* ZFDiffBuffer :call ZF_DiffBuffer(<f-args>)

function! s:ZF_DiffBufferSetup()
    execute 'nnoremap <buffer><silent> ' . get(g:, 'ZF_DiffBufferKeymap_quit', 'q') . ' :call ZF_DiffBufferExit()<cr>'
    let b:ZF_DiffBuffer_mappedKey = get(g:, 'ZF_DiffBufferKeymap_quit', 'q')
endfunction
function! ZF_DiffBufferExit()
    let oldState = winsaveview()

    execute "normal! \<c-w>h"
    if exists('b:ZF_DiffBuffer_mappedKey')
        execute 'unmap <buffer> ' . b:ZF_DiffBuffer_mappedKey
        unlet b:ZF_DiffBuffer_mappedKey
    endif
    execute "normal! \<c-w>l"
    if exists('b:ZF_DiffBuffer_mappedKey')
        execute 'unmap <buffer> ' . b:ZF_DiffBuffer_mappedKey
        unlet b:ZF_DiffBuffer_mappedKey
    endif

    ZFDiffExit
    call winrestview(oldState)
endfunction
function! ZF_DiffBuffer(...)
    let b0 = get(a:, 1, 0)
    let b1 = get(a:, 2, 0)

    if b0 <= 0
        let b0 = s:bufnrChoose('choose [LEFT] buf to diff:', 0)
        if b0 <= 0
            return 0
        endif
    endif

    if b1 <= 0
        let b1 = s:bufnrChoose('choose [RIGHT] buf to diff:', b0)
        if b1 <= 0
            return 0
        endif
    endif

    if has('gui')
        set lines=9999 columns=9999
    endif
    if (has('win32') || has('win64')) && !has('unix')
        simalt ~x
    endif
    vsplit
    execute "normal! \<c-w>h"
    execute "b" . b0
    diffthis
    call s:ZF_DiffBufferSetup()
    execute "normal! \<c-w>l"
    execute "b" . b1
    diffthis
    call s:ZF_DiffBufferSetup()
    execute "normal! \<c-w>="

    return 1
endfunction
function! ZF_DiffBuffer_sortFunc(e0, e1)
    return a:e0['bufname'] < a:e1['bufname']
endfunction
function! s:bufnrChoose(title, exclude)
    let bufnrCur = bufnr('')
    let nameCur = fnamemodify(bufname(bufnrCur), ':t')

    let itemList = []
    let otherList = []
    for bufnr in range(1, bufnr('$'))
        if buflisted(bufnr) && bufnr != bufnrCur && bufnr != a:exclude
            call add(fnamemodify(bufname(bufnr), ':t') == nameCur ? itemList : otherList, {
                        \   'bufnr' : bufnr,
                        \   'bufname' : bufname(bufnr),
                        \ })
        endif
    endfor
    call sort(itemList, function('ZF_DiffBuffer_sortFunc'))
    call sort(otherList, function('ZF_DiffBuffer_sortFunc'))
    call extend(itemList, otherList)
    if bufnrCur != a:exclude
        call insert(itemList, {
                    \   'bufnr' : bufnrCur,
                    \   'bufname' : bufname(bufnrCur),
                    \ }, 0)
    endif

    let hintList = []
    for item in itemList
        if empty(item['bufname'])
            call add(hintList, printf("[%s]"
                        \ , item['bufnr']
                        \ ))
        else
            let limit = &columns - 16 - len(printf("[%s]\t%s\t=> %s"
                        \ , item['bufnr']
                        \ , fnamemodify(item['bufname'], ':t')
                        \ , ''
                        \ ))
            let info = substitute(fnamemodify(fnamemodify(item['bufname'], ':h'), ':.'), '\\', '/', 'g')
            while 1
                if len(info) < limit
                    break
                endif
                let p = stridx(info, '/')
                if p == -1
                    break
                endif
                let info = '...' . strpart(info, p + 1)
            endwhile
            call add(hintList, printf("[%s]\t%s\t=> %s"
                        \ , item['bufnr']
                        \ , fnamemodify(item['bufname'], ':t')
                        \ , info
                        \ ))
        endif
    endfor
    let choice = ZFChoice(a:title, hintList)
    if choice != -1
        return itemList[choice]['bufnr']
    else
        return 0
    endif
endfunction

" ============================================================
" ZFDiffExit
command! -nargs=0 ZFDiffExit :call ZF_DiffExit()

function! ZF_DiffExit()
    let tabIndex = tabpagenr()
    let winCount = tabpagewinnr(tabIndex, '$')
    if tabpagenr('$') >= 2
        let hasNoneDiff = 0
        for winIndex in range(1, winCount)
            if !gettabwinvar(tabIndex, winIndex, '&diff', 0)
                let hasNoneDiff = 1
                break
            endif
        endfor
        if !hasNoneDiff
            tabclose
            return
        endif
    endif

    let hasDiff = 1
    while hasDiff
        let hasDiff = 0
        for winIndex in range(1, tabpagewinnr(tabIndex, '$'))
            if gettabwinvar(tabIndex, winIndex, '&diff', 0)
                let hasDiff = 1
                execute winIndex . 'wincmd w'
                diffoff
                if tabpagewinnr(tabIndex, '$') == 1
                    if tabpagenr('$') >= 2
                        tabclose
                    endif
                    return
                endif
                if tabpagewinnr(tabIndex, '$') > 1
                    quit
                endif
                break
            endif
        endfor
    endwhile
endfunction

