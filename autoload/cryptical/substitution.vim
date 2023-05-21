function! cryptical#substitution#create(encrypt, decrypt)
  let l:cipher = {}

  function l:cipher.encrypt(plaintext) closure
    let l:plaintext = g:cryptical_case_convention ? tolower(a:plaintext) : a:plaintext
    let l:encrypted = s:Crypt(a:encrypt, l:plaintext)
    let l:encrypted = g:cryptical_case_convention ? toupper(l:encrypted) : l:encrypted

    return l:encrypted
  endfunction

  function l:cipher.decrypt(ciphertext) closure
    let l:ciphertext = g:cryptical_case_convention ? tolower(a:ciphertext) : a:ciphertext
    let l:plaintext = s:Crypt(a:decrypt, l:ciphertext)
    let l:plaintext = g:cryptical_case_convention ? tolower(l:plaintext) : l:plaintext

    return l:plaintext
  endfunction

  return l:cipher
endfunction

function s:Crypt(crypt, starting)
  let l:Tokenize = function('s:CrypticalTokenizeChars')
  let l:Detokenizer = function('s:CrypticalDetokenizeNull')

  let l:ciphered = []
  for token in l:Tokenize(a:starting)
    let l:crypted = a:crypt(l:token)

    if l:crypted ==# v:null && g:cryptical_unknown_character_policy ==? 'strip'
      let l:crypted = []
    elseif l:crypted ==# v:null && g:cryptical_unknown_character_policy ==? 'preserve'
      let l:crypted = l:token
    endif

    let l:crypted = type(l:crypted) !=# type([]) ? [l:crypted] : l:crypted
    let l:ciphered += l:crypted
  endfor

  let l:ciphered = l:Detokenizer(l:ciphered)
  return l:ciphered
endfunction

function s:CrypticalTokenizeChars(plaintext)
  return split(a:plaintext, '\zs')
endfunction

function s:CrypticalDetokenizeNull(ciphertext)
  return join(a:ciphertext, '')
endfunction
