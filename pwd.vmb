" Vimball Archiver by Charles E. Campbell
UseVimball
finish
doc/pwd.txt	[[[1
112
PassWord plugin for Vim {{{

    This Vim plugin helps managing password lists within Vim/Neovim
    in a very basic but efficient way.

    The latest version of pwd can be found here: http://cdelord.fr/pwd

    It's based on {{{
    * http://davejlong.com/blog/2013/05/02/vim-as-a-password-manager/
    * http://vim.wikia.com/wiki/Keep_passwords_in_encrypted_file
    * http://pig-monkey.com/2013/04/4/password-management-vim-gnupg/
    * http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
    * http://stackoverflow.com/questions/9458294/open-url-under-cursor-in-vim-with-browser
    }}}

    And uses {{{
    * ccrypt
    * gzip
    * pwgen (optional)
    }}}
}}}

Installation {{{

    pwd is distributed as a Vimball archive.

    * download pwd.vmb
    * open this file with vim and type « :so % »

    ccrypt and gzip shall also be installed.
}}}

Usage {{{

    File type {{{
    * Files named *.pwd are open with the pwd plugin.
    }}}

    Syntax {{{
    * Passwords shall be in foldable sections.
    * Sections can be folded and unfolded with space.
    }}}
}}}

Shortcuts {{{

    ----------- ------------- ---------------------------
    Keyboard    Mouse         Description
    ----------- ------------- ---------------------------
    F5                        Creates a new entry
    ----------- ------------- ---------------------------
    F8                        generates a password
                              with letters and digits (*)
    ----------- ------------- ---------------------------
    Ctrl-F8                   generates a password
    Shift-F8                  with letters, digits
                              and special characters (*)
    ----------- ------------- ---------------------------
    F7          Double click  copies the word under the
                              cursor to the clipboard
                              and starts the browser if
                              a URL is found
    ----------- ------------- ---------------------------

    (*) The password generator uses pwgen
        (« apt-get install pwgen » on debian).
        If pwgen is not found, an internal generator written
        in Vim script is used (may not be as strong as pwgen).
}}}

Encryption {{{

    pwd files are encrypted with ccrypt.
    This requires an external dependency but works
    for both vim and neovim.

    Migration of old files (encrypted with «vim -X») {{{
        - rename old_file.pwd to old_file.pwd-old
        - create a new empty file:  vim new_file.pwd
        - import the old file:      :r old_file.pwd-old
        - save the new file:        :wq
    }}}
}}}

Example {{{

    A password file may look like this.

    Home {{{
        ISP {{{
            user my_user_name
            pass oeToob7J (fake password generated with <F8> ;-)
        }}}
        Bank {{{
            account 123456789
            pass 123456789
        }}}
    }}}
    Work {{{
        ...
    }}}
}}}

License {{{

    Copyright © 2013, 2016, 2017, 2019, 2020, 2024 Christophe Delord (cdelord.fr)
    This work is free. You can redistribute it and/or modify it under the
    terms of the Do What The Fuck You Want To Public License, Version 2,
    as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
}}}

# vim: set filetype=pwd foldmethod=manual :
syntax/pwd.vim	[[[1
19
" Copyright © 2013, 2016, 2017, 2019, 2020, 2024 Christophe Delord (cdelord.fr)
" This work is free. You can redistribute it and/or modify it under the
" terms of the Do What The Fuck You Want To Public License, Version 2,
" as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

if exists("b:current_syntax")
  finish
endif

syntax match sectionStart "^.*{{{" contains=sectionName,sectionStartMarker
syntax match sectionName "^\s*\zs.\{-}\ze\s*{{{" contained
syntax match sectionStartMarker "{{{"
syntax match sectionStopMarker "}}}"

highlight sectionName guifg=red guibg=NONE gui=bold,underline ctermfg=red ctermbg=NONE cterm=bold,underline
highlight sectionStartMarker guifg=orange guibg=NONE gui=NONE ctermfg=red ctermbg=NONE cterm=NONE
highlight sectionStopMarker guifg=orange guibg=NONE gui=NONE ctermfg=red ctermbg=NONE cterm=NONE

let b:current_syntax = "pwd"
plugin/pwd.vim	[[[1
173
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

ftdetect/pwd.vim	[[[1
21
" Copyright © 2013, 2016, 2017, 2019, 2020, 2024 Christophe Delord (cdelord.fr)
" This work is free. You can redistribute it and/or modify it under the
" terms of the Do What The Fuck You Want To Public License, Version 2,
" as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

augroup filetypedetect
  au BufRead,BufNewFile     *.pwd setfiletype pwd | call SetupPwd()

  au BufReadPre,BufNewFile  *.pwd setl bin viminfo= noswapfile
  au BufReadPost,BufNewFile *.pwd let $PWD_PASS = inputsecret("Master password: ")
  au BufReadPost            *.pwd silent 1,$!sh -c 'ccrypt -cb -E PWD_PASS | gunzip'
  au BufReadPost,BufNewFile *.pwd set nobin
  au BufReadPost,BufNewFile *.pwd normal! zM

  au BufWritePre            *.pwd set bin
  au BufWritePre            *.pwd silent! 1,$!sh -c 'gzip | ccrypt -e -E PWD_PASS'
  au BufWritePost           *.pwd silent! u
  au BufWritePost           *.pwd set nobin

augroup END

