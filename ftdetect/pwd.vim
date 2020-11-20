" Copyright © 2013, 2016, 2017, 2019, 2020 Christophe Delord (cdelord.fr)
" This work is free. You can redistribute it and/or modify it under the
" terms of the Do What The Fuck You Want To Public License, Version 2,
" as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

augroup filetypedetect
  au BufRead,BufNewFile     *.pwd setfiletype pwd | call SetupPwd()

  au BufReadPre,BufNewFile  *.pwd setl bin viminfo= noswapfile
  au BufReadPost,BufNewFile *.pwd let $PWD_PASS = inputsecret("Master password: ")
  au BufReadPost            *.pwd silent 1,$!sh -c 'ccrypt -cb -E PWD_PASS | gunzip'
  au BufReadPost,BufNewFile *.pwd set nobin

  au BufWritePre            *.pwd set bin
  au BufWritePre            *.pwd silent! 1,$!sh -c 'gzip | ccrypt -e -E PWD_PASS'
  au BufWritePost           *.pwd silent! u
  au BufWritePost           *.pwd set nobin

augroup END

