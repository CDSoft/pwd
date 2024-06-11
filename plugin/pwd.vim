" Copyright © 2013, 2016, 2017, 2019, 2020, 2024 Christophe Delord (cdelord.fr)
" This work is free. You can redistribute it and/or modify it under the
" terms of the Do What The Fuck You Want To Public License, Version 2,
" as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

if (exists("g:loaded_pwd"))
  finish
endif
let g:loaded_pwd = 1

let s:cpo_save = &cpo
set cpo&vim

" General setup
""""""""""""""""

function! SetupPwd()

    " Search setup
    """""""""""""""

    setlocal ic hlsearch

    " Encryption setup
    """""""""""""""""""

    " disable the swap file
    setlocal noswapfile         " keeps others from sniffing in the swapfile.
    setlocal bufhidden=wipe     " erases all session information when the file is left.
    " disable viminfo (global)
    setlocal viminfo=
    setlocal nobackup
    setlocal nowritebackup
    " enable folding
    setlocal foldmethod=marker
    " auto-close folds
    setlocal foldopen=insert    " will make it harder to accidentally open the fold with anything other than zo or i.
    setlocal foldlevel=0        " will fold only the auth, user and password lines.
    "setlocal foldclose=all      " will autoclose the folds on and deeper than the fdl parameter when leaving them.
    " make it harder to open folds by accident
    setlocal foldopen=""
    " move cursor over word and press 'e' to obfuscate/unobfuscate it
    noremap e g?iw

    " Shortcuts
    """"""""""""

    " Toggle folds with space
    nnoremap <Space> za
    " Use F8 to generate passwords
    nnoremap <F8> :call PwGen('')<CR>
    nnoremap <S-F8> :call PwGen('-y')<CR>
    nnoremap <C-F8> :call PwGen('-y')<CR>
    " Same for Neovim (F20 ↔ S-F8, F32 ↔ C-F8)
    nnoremap <F20> :call PwGen('-y')<CR>
    nnoremap <F32> :call PwGen('-y')<CR>
    " Double click / F7
    setlocal keywordprg=!
    nnoremap <2-LeftMouse> :call DoubleClick()<CR>
    nnoremap <F7> :call DoubleClick()<CR>
    " new entry: F5
    nnoremap <F5> :call NewEntry()<CR>
endfunction

" Password generator
"""""""""""""""""""""

function! PwGen(opts)
    if has("win32") || system("which pwgen") == ""
        call InternalPwGen(a:opts)
    else
        call ExternalPwGen(a:opts)
    endif
endfunction

function! ExternalPwGen(opts)
    let length = 12
    " build a password on 'length' characters
    " (with specific characters if opts is -y)
    let cmd = 'pwgen -B -n -c -N 1 ' . length . ' ' . a:opts
    let password = split(system(cmd))[0]
    " append the password to the current line
    let curline = getline('.')
    if match(curline, '\s$') < 0
        let curline = curline . ' '
    endif
    call setline(line('.'), curline . password)
endfunction

let rnd = localtime() % 0x10000
function! Random()
    let g:rnd = (g:rnd * 31421 + 6927)% 0x10000
    return g:rnd
endfunction

function! InternalPwGen(opts)
    let length = 12
    let chars = "AZERTYUIOPQSDFGHJKLMWXCVBNazertyuiopqsdfghjklmwxcvbn0123456789"
    let specialchars = "_'\"!~:+-*/\\%()[]{}|$.<=>;,&?#@`^"
    " try to randomize a little bit the random seed
    for i in range((Random() + localtime()) % 100)
        let i = Random()
    endfor
    " build a password with 'length' regular characters
    let password = ""
    for i in range(length)
        let password = chars[Random()%len(chars)] . password
    endfor
    " replace some characters with some specific ones if required
    if a:opts == '-y'
        " one or two specific characters
        for i in range(Random() % 2 + 1)
            let pos = Random() % length
            let password = password[0:pos-1] . specialchars[Random()%len(specialchars)] . password[pos+1:]
        endfor
    endif
    " append the password to the current line
    let curline = getline('.')
    if match(curline, '\s$') < 0
        let curline = curline . ' '
    endif
    call setline(line('.'), curline . password)
endfunction

" Web browser
""""""""""""""

function! Browse()
    let url = matchstr(expand("<cWORD>"), '[a-z]*:\/\/[^ >,;:]*')
    if url != ""
        echo "browse " . url
        if has("win32")
            let browser = "cmd /C start"
            let bg = ""
        elseif has("unix") && system("uname") == "Darwin"
            let browser = "open"
            let bg = "&"
        else
            let browser = "xdg-open"
            let bg = "&"
        endif
        silent exec '!'.browser.' '.url.' '.bg | redraw!
    endif
endfunction

" Double click handle
""""""""""""""""""""""

function! DoubleClick()
    " get the word (eg: user name, password, ...) or the URL under the cursor
    let text_under_cursor = expand("<cWORD>")
    " put it in the clipboard
    echo 'copy "' . text_under_cursor . '" to the clipboard'
    let @* = text_under_cursor
    " and start the browser if it looks like a URL
    call Browse()
endfunction

" New empty entry
""""""""""""""""""

function! NewEntry()
    " empty section template
    exec "normal o{{{\nUser:   \nPass:   \nUrl:    \n}}}"
    " back to the start of the section and add a space
    exec "normal %I "
    " continue in insert mode to enter the section name
    startinsert
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

