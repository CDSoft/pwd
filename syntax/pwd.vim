" Copyright © 2013, 2016, 2017 Christophe Delord (cdsoft.fr)
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

highlight sectionName guifg=blue guibg=NONE gui=bold,underline ctermfg=blue ctermbg=NONE cterm=bold,underline
highlight sectionStartMarker guifg=blue guibg=NONE gui=NONE ctermfg=blue ctermbg=NONE cterm=NONE
highlight sectionStopMarker guifg=blue guibg=NONE gui=NONE ctermfg=blue ctermbg=NONE cterm=NONE

let b:current_syntax = "pwd"
