if exists('b:shopify_dev_syntax')
  finish
endif

syntax match shopifydevKeyword "\v^(name|packages|integrations|up|env|type|open|commands):"

highlight link shopifydevKeyword Special

let b:shopify_dev_syntax = 1
