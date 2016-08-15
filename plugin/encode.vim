
" range to avoid errors
" command! -range -nargs=0 EscapeHtml  call s:escapeHtmlCmd()

function! EncodeOp(type)
	let g:type = a:type

	let l:begin = getpos("'[")
	let l:end = getpos("']")
	let g:begin = getpos("'[")
	let g:end = getpos("']")
	let l:bl = l:begin[1]
	let l:el = l:end[1]

	if a:type=="line"
		let l:i = l:bl
		while l:i <= l:el
			call setline(l:i,s:Encode(getline(l:i)))
			let l:i += 1
		endwhile
	elseif a:type=="char"
		let l:i = l:bl
		while l:i <= l:el
			let l:prefix = ''
			let l:line = getline(l:i)
			let l:s = l:line
			let l:postfix = ''
			if l:i==l:bl
				let l:prefix = strpart(l:line,0,l:begin[2]-1)
				let l:s = strpart(l:line,l:begin[2]-1)
			endif
			if l:i==l:el
				let l:postfix = strpart(l:line,l:end[2])
				let l:s = strpart(l:s,0,len(l:s)-(len(l:line)-l:end[2]))
			endif
			call setline(l:i,l:prefix.s:Encode(l:s).l:postfix)
			let l:i += 1
		endwhile
	elseif a:type=="block"

		let l:i = l:bl
		while l:i <= l:el
			call setline(l:i,s:Encode(getline(l:i)))
			let l:i += 1
		endwhile

		" let l:useArea = 0
		" if l:end[2]<=len(getline(l:el))
		" 	let l:useArea = 1
		" endif

		" let l:i = l:bl
		" while l:i <= l:el
		" 	let l:prefix = ''
		" 	let l:line = getline(l:i)
		" 	let l:s = l:line
		" 	let l:postfix = ''
		" 	if l:useArea==1
		" 		let l:prefix = strpart(l:line,0,l:begin[2]-1)
		" 		let l:postfix = strpart(l:line,l:end[2])
		" 		let l:s = strpart(l:line,l:begin[2]-1)
		" 		let l:s = strpart(l:s,0,len(l:s)-(len(l:line)-l:end[2]))
		" 	endif
		" 	call setline(l:i,l:prefix.s:Encode(l:s).l:postfix)
		" 	let l:i += 1
		" endwhile
	endif
endfunction

function! s:Encode(text)
	let l:s = a:text
	" `\&` here for fucking vim magic
	let l:s = substitute(l:s,'\V&','\&nbsp;','g')
	let l:s = substitute(l:s,'\V<','\&lt;','g')
	let l:s = substitute(l:s,'\V>','\&gt;','g')
	let l:s = substitute(l:s,'\V"','\&quot;','g')
	let l:s = substitute(l:s,"\V'",'\&apos;','g')
	let g:s=l:s
	return l:s
endfunction


function s:EncodeSetup()
	let &opfunc = 'EncodeOp'
	return ''
endfunction

" eh for html
nnoremap <expr> <Leader>eh <SID>EncodeSetup().'g@'
vnoremap <expr> <Leader>eh <SID>EncodeSetup().'g@'

