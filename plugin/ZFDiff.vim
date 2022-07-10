
" ============================================================
" ZFDiffBuffer
command! -nargs=+ ZFDiffBuffer :call ZF_DiffBuffer(<f-args>)

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
function! ZF_DiffBuffer(b0, b1)
    if has('gui')
        set lines=9999 columns=9999
    endif
    if has('windows')
        simalt ~x
    endif
    vsplit
    execute "normal! \<c-w>h"
    execute "b" . a:b0
    diffthis
    call s:ZF_DiffBufferSetup()
    execute "normal! \<c-w>l"
    execute "b" . a:b1
    diffthis
    call s:ZF_DiffBufferSetup()
    execute "normal! \<c-w>="
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
                quit
                break
            endif
        endfor
    endwhile
endfunction

