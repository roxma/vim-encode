
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
	return join(keys(g:encode#handlers),"\n")
endfunc


func! encode#begin()
	" echo "h(html) u(url) x(xml)"
	" let l:c = nr2char(getchar())
	let l:type = input("html/xml/url, please enter escape type: ", '', 'custom,encode#cmd_complete')
	let w:encode_handler = g:encode#handlers[l:type]
	let w:encode_curpos = getcurpos()
	let &g:opfunc = 'encode#op'
	return 'g@'
endfunc

func! s:lineSp()
	if &l:ff=="unix"
		return "\n"
	elseif &l:ff=="doc"
		return "\r\n"
	elseif &l:ff=="mac"
		return "\r"
	endif
	return "\n"
endfunc

func! encode#op(type)

	let l:bpos  = getpos("'[")
	let l:epos  = getpos("']")
	" don't know vim has any guarantee that `'[` is always greater than or equal to `']`
	if l:bpos[1]>l:epos[1] || (l:bpos[1]==l:epos[1] && l:bpos[2]>l:epos[2])
		let l:bpos  = getpos("']")
		let l:epos  = getpos("'[")
	endif
	let l:bl = l:bpos[1]
	let l:bc = l:bpos[2]
	let l:el = l:epos[1]
	let l:ec = l:epos[2]

	if a:type=="line"
		let l:raw     = join(getline(l:bl,l:el),s:lineSp())
		let l:encoded = w:encode_handler(l:raw)
		let l:lines   = split(l:encoded,s:lineSp(),1)
		execute l:bl.','.l:el.'delete'
		call append(l:bl-1,l:lines)
	elseif a:type=="char"
		if w:encode_curpos[4]+1<0
			" if cursor is at end of line, add a new line
			let l:el+=1
			let l:ec=0
		endif
		if l:bl == l:el
			let l:raw = strpart(getline(l:bl),l:bc-1,l:ec-l:bc+1)
		else
			let l:raw = join([strpart(getline(l:bl),l:bc-1)]+getline(l:bl+1,l:el-1)+[strpart(getline(l:el),0,l:ec)],s:lineSp())
		endif
		let g:raw = l:raw
		let l:encoded   = w:encode_handler(l:raw)
		let l:lines     = split(l:encoded,s:lineSp(),1)[0:1]
		let l:prefix    = strpart(getline(l:bl),0,l:bc-1)
		let l:postfix   = strpart(getline(l:el),l:ec)
		let l:lines[0]  = l:prefix . l:lines[0]
		let l:lines[-1] = l:lines[-1] . l:postfix
		execute l:bl.','.l:el.'delete'
		call append(l:bl-1,l:lines)
		call cursor(l:bl,l:bc)
	elseif a:type=="block"
		let l:i = l:bl
		while l:i <= l:el
			let l:line    = getline(l:i)
			let l:prefix  = strpart(l:line,0,l:bc-1)
			let l:postfix = ''
			let l:s       = strpart(l:line,l:bc-1)
			if w:encode_curpos[4]+1>0
				let l:postfix = strpart(l:line,l:ec)
				if len(l:line)-l:ec>=0
					let l:s       = strpart(l:s,0,len(l:s)-(len(l:line)-l:ec))
				endif
			endif
			call setline(l:i,l:prefix.w:encode_handler(l:s).l:postfix)
			let l:i += 1
		endwhile
	endif
endfunc


func! encode#html_encode(text)
	let l:find    = ['&'      , '<'    , '>'    , '"'      , "'"]
	let l:replace = ['&nbsp;' , '&lt;' , '&gt;' , '&quot;' , '&apos;']
	return encode#strreplace(a:text,l:find,l:replace)
endfunc


func! encode#xml_encode(text)
	let l:find    = ['&'      , '<'    , '>'    , '"'      , "'"]
	let l:replace = ['&nbsp;' , '&lt;' , '&gt;' , '&quot;' , '&apos;']
	return encode#strreplace(a:text,l:find,l:replace)
endfunc


" these stuff should moved into a standalone plugin

func! encode#strfind(s,find,start)
	if type(a:find)==1
		let l:i = a:start
		while l:i<len(a:s)
			if strpart(a:s,l:i,len(a:find))==a:find
				return l:i
			endif
			let l:i+=1
		endwhile
		return -1
	elseif type(a:find)==3
		" a:find is a list
		let l:i = a:start
		while l:i<len(a:s)
			let l:j=0
			while l:j<len(a:find)
				if strpart(a:s,l:i,len(a:find[l:j]))==a:find[l:j]
					return [l:i,l:j]
				endif
				let l:j+=1
			endwhile
			let l:i+=1
		endwhile
		return [-1,-1]
	endif
endfunc

func! encode#strreplace(s,find,replace)
	if len(a:find)==0
		return a:s
	endif
	if type(a:find)==1 && type(a:replace)==1
		let l:ret = a:s
		let l:i = encode#strfind(l:ret,a:find,0)
		while l:i!=-1
			let l:ret = strpart(l:ret,0,l:i).a:replace.strpart(l:ret,l:i+len(a:find))
			let l:i = encode#strfind(l:ret,a:find,l:i+len(a:replace))
		endwhile
		return l:ret
	elseif  type(a:find)==3 && type(a:replace)==3 && len(a:find)==len(a:replace)
		let l:ret = a:s
		let [l:i,l:j] = encode#strfind(l:ret,a:find,0)
		while l:i!=-1
			let l:ret = strpart(l:ret,0,l:i).a:replace[l:j].strpart(l:ret,l:i+len(a:find[l:j]))
			let [l:i,l:j] = encode#strfind(l:ret,a:find,l:i+len(a:replace[l:j]))
		endwhile
		return l:ret
	endif

endfunc

