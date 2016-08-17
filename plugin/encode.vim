
nnoremap <expr> <Plug>(encode) encode#begin()
vnoremap <expr> <Plug>(encode) encode#begin()


if get(g:,'vim_encode_default_mapping',1)

	" eh for html
	nmap <Leader>e <Plug>(encode)
	vmap <Leader>e <Plug>(encode)

endif

