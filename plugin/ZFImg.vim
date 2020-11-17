
if has('python3')
    let s:python_EOF='python3 << python_EOF'
elseif has('python')
    let s:python_EOF='python << python_EOF'
else
    let s:python_EOF='echo "python not available" | return 0 | python << python_EOF'
endif


" ============================================================
" ZFImgScale
command! -nargs=+ -complete=file ZFImgScale :call ZFImgScale(<f-args>)

function! ZFImgScale(toFile, fromFile, maxWidth, ...)
execute s:python_EOF

import vim
from PIL import Image

toFile = vim.eval('a:toFile')
fromFile = vim.eval('a:fromFile')
maxWidth = int(vim.eval('a:maxWidth'))
maxHeight = int(vim.eval('get(a:, 1, a:maxWidth)'))
exactMode = int(vim.eval('get(a:, 2, 0)')) == 1

img = Image.open(fromFile)

origWidth = img.size[0]
origHeight = img.size[1]
if exactMode:
    if origWidth != maxWidth or origHeight != maxHeight:
        img = img.resize((maxWidth, maxHeight))
else:
    if origWidth > maxWidth or origHeight > maxHeight:
        if origWidth * maxHeight > maxWidth * origHeight:
            height = int(origHeight * maxWidth / origWidth)
            width = maxWidth
        else:
            width = int(origWidth * maxHeight / origHeight)
            height = maxHeight
        img = img.resize((width, height))

img.save(toFile, optimize=True)
img.close()

python_EOF
endfunction

