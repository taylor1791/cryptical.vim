function cryptical#shift#create(alphabet, ...) abort
  let l:sequence = type(a:alphabet) == v:t_string ? split(a:alphabet, '\zs') : a:alphabet

  let l:positions = {}
  for i in range(len(l:sequence))
    let l:positions[l:sequence[i]] = i
  endfor

  let l:encrypt_key = a:0 == 1 ? a:1 : s:generate_key(l:sequence)
  let l:DecryptKey = type(l:encrypt_key[0]) == v:t_number ?
    \ len(l:sequence) - l:encrypt_key[0] :
    \ type(l:encrypt_key[0]) == v:t_func ?
      \ { character, n, group -> len(l:sequence) - l:encrypt_key[0](character, n, group) } :
      \ map(copy(l:encrypt_key[0]), {_, n -> len(l:sequence) - n})

  let l:alphabet = { 'sequence': l:sequence, 'positions': l:positions }
  let l:Encrypt = s:shift_cipher(l:alphabet, l:encrypt_key[0], l:encrypt_key[1])
  let l:Decrypt = s:shift_cipher(l:alphabet, l:DecryptKey, l:encrypt_key[1])
  return {
    \ 'alphabet': a:alphabet,
    \ 'key': l:encrypt_key,
    \ 'cipher': cryptical#substitution#create(l:Encrypt, l:Decrypt),
  \ }
endfunction

function s:generate_key(alphabet) abort
  let l:shifts = [rand() % len(a:alphabet)]
  let l:change = rand() % 6

  " 90% chance of adding a shift
  while rand() % 10 !=# 0
    let l:shifts += [rand() % len(a:alphabet)]
  endwhile

  return [l:shifts, l:change]
endfunction

function s:shift_cipher(alphabet, shift_n, change_shift) abort
  let l:character_n = 0
  let l:group_n = 0

  let l:shift = {}

  function l:shift.shift(character) abort closure
    if type(a:shift_n) ==# v:t_func
      let l:shift_n = a:shift_n(a:character, l:character_n, l:group_n)
    elseif type(a:shift_n) ==# v:t_list
      let l:shift_n = a:shift_n[l:group_n % len(a:shift_n)]
    else
      let l:shift_n = a:shift_n * (l:group_n + 1)
    endif

    let l:shift_n = l:shift_n % len(a:alphabet.sequence)
    let l:shifted = s:shift(a:alphabet, a:character, l:shift_n)

    if l:shifted !=# v:null
      let l:character_n += 1
      if type(a:change_shift) ==# v:t_number && a:change_shift == l:character_n
            \ || type(a:change_shift) ==# v:t_string && a:character =~# a:change_shift
        let l:character_n = 0
        let l:group_n += 1
      endif
    endif

    return l:shifted
  endfunction

  return l:shift.shift
endfunction

function s:shift(alphabet, character, n) abort
  if !has_key(a:alphabet.positions, a:character)
    return v:null
  endif

  let l:index = a:alphabet.positions[a:character]

  return a:alphabet.sequence[(l:index + a:n) % len(a:alphabet.sequence)]
endfunction
