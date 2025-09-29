command! P4luaInstall call <SID>p4lua_install()

function! s:vim_pack_get(name) abort
    let all_pkgs = luaeval("vim.pack.get()")
    for pkg in all_pkgs
        if pkg['spec']['name'] ==# a:name
            return pkg
        endif
    endfor
    return {}
endfunction

"---------------------------------------------------
" Main install function
"---------------------------------------------------
function! s:p4lua_install() abort
    let pkg = s:vim_pack_get('p4lua')
    if empty(pkg)
        echo "p4lua is not installed yet."
        return
    endif

    echom "Installing p4lua…"
    call s:build(pkg['path'])
endfunction

"---------------------------------------------------
" Build function: luarocks make --tree=target
"---------------------------------------------------
function! s:build(pkg_path) abort
    if empty(a:pkg_path)
        echo "Package path not provided"
        return
    endif

    let l:target = fnamemodify(a:pkg_path, ':p') . 'target'

    if exists('$LUAROCKS_CMD') && !empty($LUAROCKS_CMD)
        let l:luarocks_cmd = expand($LUAROCKS_CMD)
    else
        let l:luarocks_cmd = 'luarocks'
    endif

    let l:cmd = [l:luarocks_cmd, 'make', '--tree=' . l:target ]
    let l:env = copy(environ())

    if has_key(l:env, 'LUA_PATH')
        let l:env['LUA_PATH'] = l:env['LUA_PATH'] .. ';' .. l:target . '/share/lua/5.1/?.lua'
    else
        let l:env['LUA_PATH'] = l:target . '/share/lua/5.1/?.lua;;'
    endif
    if has_key(l:env, 'LUA_CPATH')
        let l:env['LUA_CPATH'] = l:env['LUA_CPATH'] .. ';' .. l:target . '/lib/lua/5.1/?.so'
    else
        let l:env['LUA_CPATH'] = l:target . '/lib/lua/5.1/?.so;;'
    endif

    call jobstart(l:cmd, {
                \ 'cwd': a:pkg_path,
                \ 'env': l:env,
                \ 'on_stdout': function('s:job_stdout'),
                \ 'on_stderr': function('s:job_stderr'),
                \ 'on_exit': { j, d, e -> s:job_build_exit(j, d, e, l:target, a:pkg_path) },
                \ })
endfunction

"---------------------------------------------------
" Job stdout callback
"---------------------------------------------------
function! s:job_stdout(job_id, data, event) abort
    for line in a:data
        if !empty(line)
            echom line
        endif
    endfor
endfunction

"---------------------------------------------------
" Job stderr callback
"---------------------------------------------------
function! s:job_stderr(job_id, data, event) abort
    for line in a:data
        if !empty(line)
            echohl ErrorMsg | echom line | echohl None
        endif
    endfor
endfunction

"---------------------------------------------------
" Job exit callback for build
"---------------------------------------------------
function! s:job_build_exit(job_id, code, event, target, pkg_path) abort
    if a:code != 0
        echohl ErrorMsg | echom "luarocks make failed!" | echohl None
        return
    endif

    echohl Question | echom "luarocks make completed successfully" | echohl None

    " Call install function (mv to lua)
    call s:install(a:target, a:pkg_path)
endfunction

"---------------------------------------------------
" Install function: move Lua modules to pkg_path/lua
"---------------------------------------------------
function! s:install(target, pkg_path) abort
    let l:src = fnamemodify(a:target, ':p') . 'share/lua/5.1'
    let l:dest   = fnamemodify(a:pkg_path, ':p') . 'lua'

    let move_cmd = ['cp', '-r', l:src, l:dest]
    call jobstart(move_cmd, {
                \ 'on_stdout': function('s:job_stdout'),
                \ 'on_stderr': function('s:job_stderr'),
                \ 'on_exit': { j, d, e -> s:job_install_exit(j, d, e, l:dest, a:target) },
                \ })
endfunction

"---------------------------------------------------
" Job exit callback for install
"---------------------------------------------------
function! s:job_install_exit(job_id, code, event, dest, target) abort
    if a:code != 0
        echohl ErrorMsg | echom "Failed to move Lua modules!" | echohl None
    else
        echohl Question | echom "Lua modules installed to " . a:dest | echohl None
    endif
    if isdirectory(a:target)
        call delete(a:target, 'rf')
    endif
endfunction
