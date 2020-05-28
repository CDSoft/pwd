" Copyright © 2013, 2016, 2017, 2019, 2020 Christophe Delord (cdelord.fr)
" This work is free. You can redistribute it and/or modify it under the
" terms of the Do What The Fuck You Want To Public License, Version 2,
" as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

autocmd BufRead,BufNewFile *.pwd set filetype=pwd | call SetupPwd()
augroup filetypedetect
  au BufRead,BufNewFile *.pwd setfiletype pwd | call SetupPwd()
augroup END

