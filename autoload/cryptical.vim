let s:alphabet = 'abcdefghijklmnopqrstuvwxyz'

let g:cryptical#atbash = cryptical#affine#create(s:alphabet, [-1, -1]).cipher
let g:cryptical#caesar = cryptical#affine#create(s:alphabet, [1, 3]).cipher
