function cryptical#mixed_alphabet#create(alphabet, ...) abort
  let l:alphabet = type(a:alphabet) ==# v:t_string ? split(a:alphabet, '\zs') : a:alphabet

  let l:key = a:0 ==# 0 ? s:generate_key(l:alphabet) : a:1
  let l:key = type(l:key) ==# v:t_string ? split(a:1, '\zs') : l:key

  return {
    \ 'alphabet': a:alphabet,
    \ 'key': l:key,
    \ 'cipher': s:mixed_alphabet_cipher(l:alphabet, l:key),
  \ }
endfunction

function s:generate_key(alphabet) abort
  let l:key = copy(a:alphabet)

  let l:i = len(l:key)
  while l:i > 1
    let l:j = rand() % l:i
    let l:i -= 1
    let [l:key[l:i], l:key[l:j]] = [l:key[l:j], l:key[l:i]]
  endwhile

  return l:key
endfunction

function s:mixed_alphabet_cipher(alphabet, key) abort
  let [l:encrypt_table, l:decrypt_table] = s:create_tables(a:alphabet, a:key)

  let l:cipher = {}

  function l:cipher.encrypt(character) abort closure
    if !has_key(l:encrypt_table, a:character)
      return v:null
    endif

    return l:encrypt_table[a:character]
  endfunction

  function l:cipher.decrypt(character) abort closure
    if !has_key(l:decrypt_table, a:character)
      return v:null
    endif

    return l:decrypt_table[a:character]
  endfunction

  return cryptical#substitution#create(l:cipher.encrypt, l:cipher.decrypt)
endfunction

function s:create_tables(alphabet, key) abort
  let l:encrypt = {}
  let l:decrypt = {}

  let l:alphabet_i = 0
  let l:key_i = 0
  let l:remaining_alphabet_i = 0
  while l:alphabet_i < len(a:alphabet)
    " Loop through the entire key. Then, loop through the remaining alphabet.
    if l:key_i < len(a:key)
      let l:ciphered = a:key[l:key_i]
      let l:key_i += 1

      " Conventionally, repeats are ignored in keywords.
      if has_key(l:decrypt, l:ciphered)
        continue
      endif
    else
      let l:ciphered = a:alphabet[l:remaining_alphabet_i]
      let l:remaining_alphabet_i += 1

      " l:ciphered was already added to the table by the key.
      if has_key(l:decrypt, l:ciphered)
        continue
      endif
    endif

    let l:plain = a:alphabet[l:alphabet_i]
    if has_key(l:encrypt, l:plain)
      throw 'Duplicate character in alphabet, "' . l:plain . '"'
    endif

    let l:alphabet_i += 1
    let l:encrypt[l:plain] = l:ciphered
    let l:decrypt[l:ciphered] = l:plain
  endwhile

  return [l:encrypt, l:decrypt]
endfunction
