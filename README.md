PassWord plugin for Vim
=======================

This Vim plugin helps managing password lists within Vim
in a very basic but efficient way.

The latest version of pwd can be found here: <http://cdsoft.fr/pwd>

It's based on:

- <http://davejlong.com/blog/2013/05/02/vim-as-a-password-manager/>
- <http://vim.wikia.com/wiki/Keep_passwords_in_encrypted_file>
- <http://pig-monkey.com/2013/04/4/password-management-vim-gnupg/>
- <http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line>
- <http://stackoverflow.com/questions/9458294/open-url-under-cursor-in-vim-with-browser>

Installation
============

pwd is distributed as a Vimball archive.

- download pwd.vmb
- open this file with vim and type « :so % »

Usage
=====

File type
---------

Files named `*.pwd` are open with the pwd plugin.

Syntax
------

* Passwords shall be in foldable sections.
* Sections can be folded and unfolded with space.

Shortcuts
---------

----------- ------------- ---------------------------------
Keyboard    Mouse         Description
----------- ------------- ---------------------------------
F5                        Creates a new entry
----------- ------------- ---------------------------------
F8                        generates a password
                            with letters and digits ([^1])
----------- ------------- ---------------------------------
Alt-F8                    generates a password
                            with letters, digits
                            and special characters ([^1])
----------- ------------- ---------------------------------
F7          Double click  copies the word under the
                            cursor to the clipboard
                            and starts the browser if
                            a URL is found
----------- ------------- ---------------------------------

[^1]: The password generator uses pwgen
      (« apt-get install pwgen » on debian).
      If pwgen is not found, an internal generator written
      in Vim script is used (may not be as strong as pwgen).

Encryption
----------

It may be wise to encrypt your password file.
Vim can do it with the '-x' option.

« gvim -x file.pwd » decrypts file.pwd when it is open
and encrypts it when it is saved.

Or save your file into an encrypted container.

Example
=======

A password file may look like this:

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

License
=======

Copyright © 2013, 2016, 2017 Christophe Delord (cdsoft.fr)

This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
