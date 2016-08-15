
" TODO: char type, line type should encode '\n' if necessary
" TODO: url string encode
" TODO: c string encode
" TODO: json string encode

let g:encode#handlers = {
			\ 'html': function('encode#html_encode')
			\ , 'xml': function('encode#html_encode')
			\}

func! encode#add(type,handler)
	let g:encode#handlers[type] = function(handler)
endfunc

func! encode#cmd_complete(A,L,P)
	" new-line separated string
	return "html\nurl"
endfunc


func! encode#begin()
	" echo "h(html) u(url) x(xml)"
	" let l:c = nr2char(getchar())
	let l:type = input("html/xml/url, please enter escape type: ", '', 'custom,encode#cmd_complete')
	let w:encode_handler = g:encode#handlers[l:type]
	let w:encode_curpos = getcurpos()
	let &g:opfunc = 'encode#op'
	return 'g@'
endfunction


func! encode#op(type)

	let l:begin = getpos("'[")
	let l:end   = getpos("']")
	let l:bl    = l:begin[1]
	let l:el    = l:end[1]

	if a:type=="line"
		let l:i = l:bl
		while l:i <= l:el
			call setline(l:i,w:encode_handler(getline(l:i)))
			let l:i += 1
		endwhile
	elseif a:type=="char"
		let l:i = l:bl
		while l:i <= l:el
			let l:line    = getline(l:i)
			let l:s       = l:line
			let l:prefix  = ''
			let l:postfix = ''
			if l:i==l:bl
				let l:prefix = strpart(l:line,0,l:begin[2]-1)
				let l:s      = strpart(l:line,l:begin[2]-1)
			endif
			if l:i==l:el
				let l:postfix = strpart(l:line,l:end[2])
				let l:s       = strpart(l:s,0,len(l:s)-(len(l:line)-l:end[2]))
			endif
			call setline(l:i,l:prefix.w:encode_handler(l:s).l:postfix)
			let l:i += 1
		endwhile
	elseif a:type=="block"
		let l:i = l:bl
		while l:i <= l:el
			let l:line    = getline(l:i)
			let l:prefix  = strpart(l:line,0,l:begin[2]-1)
			let l:postfix = ''
			let l:s       = strpart(l:line,l:begin[2]-1)
			if w:encode_curpos[4]+1>0
				let l:postfix = strpart(l:line,l:end[2])
				if len(l:line)-l:end[2]>=0
					let l:s       = strpart(l:s,0,len(l:s)-(len(l:line)-l:end[2]))
				endif
			endif
			call setline(l:i,l:prefix.w:encode_handler(l:s).l:postfix)
			let l:i += 1
		endwhile
	endif
endfunction


function! encode#html_encode(text)
	let l:s = a:text
	" `\&` here for fucking vim magic
	let l:s = substitute(l:s,'\V&','\&nbsp;','g')
	let l:s = substitute(l:s,'\V<','\&lt;','g')
	let l:s = substitute(l:s,'\V>','\&gt;','g')
	let l:s = substitute(l:s,'\V"','\&quot;','g')
	let l:s = substitute(l:s,"\V'",'\&apos;','g')
	return l:s
endfunction


function! encode#xml_encode(text)
	let l:s = a:text
	" `\&` here for fucking vim magic
	let l:s = substitute(l:s,'\V&','\&nbsp;','g')
	let l:s = substitute(l:s,'\V<','\&lt;','g')
	let l:s = substitute(l:s,'\V>','\&gt;','g')
	let l:s = substitute(l:s,'\V"','\&quot;','g')
	let l:s = substitute(l:s,"\V'",'\&apos;','g')
	return l:s
endfunction

