function! cryptical#substitution#create(encrypt, decrypt) abort
  let l:cipher = {}

  function l:cipher.encrypt(plaintext) abort closure
    let l:case_convention = cryptical#get_case_convention()
    let l:plaintext = l:case_convention ? tolower(a:plaintext) : a:plaintext
    let l:encrypted = s:Crypt(a:encrypt, l:plaintext)
    let l:encrypted = l:case_convention ? toupper(l:encrypted) : l:encrypted

    return l:encrypted
  endfunction

  function l:cipher.decrypt(ciphertext) abort closure
    let l:case_convention = cryptical#get_case_convention()
    let l:ciphertext = l:case_convention ? tolower(a:ciphertext) : a:ciphertext
    let l:plaintext = s:Crypt(a:decrypt, l:ciphertext)
    let l:plaintext = l:case_convention ? tolower(l:plaintext) : l:plaintext

    return l:plaintext
  endfunction

  return l:cipher
endfunction

function s:Crypt(crypt, starting) abort
  let l:unknown_character_policy = cryptical#get_unknown_character_policy()
  let l:Tokenize = function('s:CrypticalTokenizeChars')
  let l:Detokenizer = function('s:CrypticalDetokenizeNull')

  let l:ciphered = []
  for token in l:Tokenize(a:starting)
    let l:crypted = a:crypt(l:token)

    if l:crypted ==# v:null && l:unknown_character_policy ==? 'strip'
      let l:crypted = []
    elseif l:crypted ==# v:null && l:unknown_character_policy ==? 'preserve'
      let l:crypted = l:token
    endif

    let l:crypted = type(l:crypted) !=# v:t_list ? [l:crypted] : l:crypted
    let l:ciphered += l:crypted
  endfor

  let l:ciphered = l:Detokenizer(l:ciphered)
  return l:ciphered
endfunction

function s:CrypticalTokenizeChars(plaintext) abort
  return split(a:plaintext, '\zs')
endfunction

function s:CrypticalDetokenizeNull(ciphertext) abort
  return join(a:ciphertext, '')
endfunction
