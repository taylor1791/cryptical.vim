let s:alphabet = 'abcdefghijklmnopqrstuvwxyz'

let g:cryptical#atbash = cryptical#affine#create(s:alphabet, [-1, -1]).cipher
let g:cryptical#caesar = cryptical#affine#create(s:alphabet, [1, 3]).cipher

function! cryptical#get_unknown_character_policy()
  return exists('b:cryptical_unknown_character_policy') ?
    \ b:cryptical_unknown_character_policy :
    \ get(g:, 'cryptical_unknown_character_policy', 'preserve')
endfunction

function! cryptical#get_case_convention()
  return exists('b:cryptical_case_convention') ?
    \ b:cryptical_case_convention :
    \ get(g:, 'cryptical_case_convention', v:false)
endfunction
