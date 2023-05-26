function cryptical#affine#create(alphabet, ...)
  let l:alphabet = type(a:alphabet) ==# v:t_string ? split(a:alphabet, '\zs') : a:alphabet

  let l:key = a:0 ==# 1 ? a:1 : s:generate_key(l:alphabet)

  return { 'key': l:key, 'cipher': s:affine_cipher(l:alphabet, key[0], key[1]) }
endfunction

function s:generate_key(alphabet)
  while v:true
    let l:a = rand() % len(a:alphabet)
    let l:b = rand() % len(a:alphabet)

    if s:egcd(l:a, len(a:alphabet)).gcd ==# 1
      return [l:a, l:b]
    endif
  endwhile
endfunction

function s:affine_cipher(alphabet, a, b)
  let l:egcd = s:egcd(a:a, len(a:alphabet))
  if l:egcd.gcd !=# 1
    throw 'a and alphabet length must be coprime'
  endif

  let l:a_inverse = l:egcd.x
  let l:ns = {}
  for i in range(len(a:alphabet))
    let l:ns[a:alphabet[i]] = i
  endfor

  let l:cipher = {}

  function l:cipher.encrypt(character) closure
    if !has_key(l:ns, a:character)
      return v:null
    endif

    let l:n = (a:a * l:ns[a:character] + a:b) % len(l:ns)

    return a:alphabet[l:n]
  endfunction

  function l:cipher.decrypt(character) closure
    if !has_key(l:ns, a:character)
      return v:null
    endif

    let l:n = l:a_inverse * (l:ns[a:character] - a:b) % len(l:ns)

    return a:alphabet[l:n]
  endfunction

  return cryptical#substitution#create(l:cipher.encrypt, l:cipher.decrypt)
endfunction

function s:egcd(a, b)
  let [l:r_old, l:r] = [a:a, a:b]
  let [l:s_old, l:s] = [1, 0]
  let [l:t_old, l:t] = [0, 1]

  while l:r != 0
    let l:q = l:r_old / l:r
    let [l:r_old, l:r] = [l:r, l:r_old - l:q * l:r]
    let [l:s_old, l:s] = [l:s, l:s_old - l:q * l:s]
    let [l:t_old, l:t] = [l:t, l:t_old - l:q * l:t]
  endwhile

  return { 'gcd': l:r_old, 'x': l:s_old, 'y': l:t_old }
endfunction
