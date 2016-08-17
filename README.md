# vim-encode

## description

Provides simple stirng encode/escape functionality inside vim.

supported encode/escape type:

- html
- xml
- url
- hex
- cstring
- cstring_pretty

## usage

press `<Leader>e` the way you use vim's standard operators like `d`(delete)

screen cast here:

[![asciicast](https://asciinema.org/a/ew105rtskuxg65a1f442stegg.png)](https://asciinema.org/a/ew105rtskuxg65a1f442stegg)


## key mapping

If you don't want default mapping, add `let g:vim_encode_default_mapping=0`
into your vimrc. Use `<Plug>(encode)` for your own mapping.

