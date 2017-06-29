" For vim8 or later
" Have minpac installed first.

packadd minpac

call minpac#init()

" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
call minpac#add('k-takata/minpac', {'type': 'opt'})

" my packages
call minpac#add('tpope/vim-sensible')
call minpac#add('vim-syntastic/syntastic')
