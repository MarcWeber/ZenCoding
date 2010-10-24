"=============================================================================
" File: zencoding.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 08-Oct-2010.
" Version: 0.45
" WebPage: http://github.com/mattn/zencoding-vim
" Description: vim plugins for HTML and CSS hi-speed coding.
" SeeAlso: http://code.google.com/p/zen-coding/
" Usage:
"
"   This is vim script support expanding abbreviation like zen-coding.
"   ref: http://code.google.com/p/zen-coding/
"
"   Type abbreviation
"      +-------------------------------------
"      | html:5_
"      +-------------------------------------
"   "_" is a cursor position. and type "<c-y>," (Ctrl+y and Comma)
"   NOTE: Don't worry about key map. you can change it easily.
"      +-------------------------------------
"      | <!DOCTYPE HTML>
"      | <html lang="en">
"      | <head>
"      |     <title></title>
"      |     <meta charset="UTF-8">
"      | </head>
"      | <body>
"      |      _
"      | </body>
"      | </html>
"      +-------------------------------------
"   Type following
"      +-------------------------------------
"      | div#foo$*2>div.bar
"      +-------------------------------------
"   And type "<c-y>,"
"      +-------------------------------------
"      |<div id="foo1">
"      |    <div class="bar">_</div>
"      |</div>
"      |<div id="foo2">
"      |    <div class="bar"></div>
"      |</div>
"      +-------------------------------------
"
" Tips:
"
"   You can customize behavior of expanding with overriding config.
"   This configuration will be marged at loading plugin.
"
"     let g:user_zen_settings = {
"     \  'indentation' : '  ',
"     \  'perl' : {
"     \    'aliases' : {
"     \      'req' : 'require '
"     \    },
"     \    'snippets' : {
"     \      'use' : "use strict\nuse warnings\n\n",
"     \      'warn' : "warn \"|\";",
"     \    }
"     \  }
"     \}
"
"   You can set language attribute in html using 'zen_settings.lang'.
"
" GetLatestVimScripts: 2981 1 :AutoInstall: zencoding.vim
" script type: plugin


" changes: 
"  Marc Weber Oct 2010: 
"  moved code into autoload file renaming some functions Now this plugin only
"  contains the configuration. Everything else is loaded lazily when needed
"  using the autoload feature

if !exists('g:zencoding_debug')
  let g:zencoding_debug = 0
endif

if exists('g:use_zen_complete_tag') && g:use_zen_complete_tag
  setlocal completefunc=zen_coding#ZenCompleteTag
endif

if !exists('g:user_zen_leader_key')
  let g:user_zen_leader_key = '<c-y>'
endif

let s:target = expand('<sfile>:h') =~ '[\\/]plugin$' ? '' : '<buffer>'

for s:item in [
\ {'mode': 'i', 'var': 'user_zen_expandabbr_key', 'key': ',', 'plug': 'ZenCodingExpandAbbr', 'func': '<c-g>u<esc>:call zen_coding#Zen_expandAbbr(0)<cr>a'},
\ {'mode': 'v', 'var': 'user_zen_expandabbr_key', 'key': ',', 'plug': 'ZenCodingExpandVisual', 'func': ':call zen_coding#Zen_expandAbbr(2)<cr>'},
\ {'mode': 'n', 'var': 'user_zen_expandabbr_key', 'key': ',', 'plug': 'ZenCodingExpandNormal', 'func': ':call zen_coding#Zen_expandAbbr(3)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_expandword_key', 'key': ';', 'plug': 'ZenCodingExpandWord', 'func': '<c-g>u<esc>:call zen_coding#Zen_expandAbbr(1)<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_expandword_key', 'key': ',', 'plug': 'ZenCodingExpandWord', 'func': ':call zen_coding#Zen_expandAbbr(1)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_balancetaginward_key', 'key': 'd', 'plug': 'ZenCodingBalanceTagInwardInsert', 'func': '<esc>:call zen_coding#Zen_balanceTag(1)<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_balancetaginward_key', 'key': 'd', 'plug': 'ZenCodingBalanceTagInwardNormal', 'func': ':call zen_coding#Zen_balanceTag(1)<cr>'},
\ {'mode': 'v', 'var': 'user_zen_balancetaginward_key', 'key': 'd', 'plug': 'ZenCodingBalanceTagInwardVisual', 'func': ':call zen_coding#Zen_balanceTag(2)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_balancetagoutward_key', 'key': 'D', 'plug': 'ZenCodingBalanceTagOutwardInsert', 'func': '<esc>:call zen_coding#Zen_balanceTag(-1)<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_balancetagoutward_key', 'key': 'D', 'plug': 'ZenCodingBalanceTagOutwardNormal', 'func': ':call zen_coding#Zen_balanceTag(-1)<cr>'},
\ {'mode': 'v', 'var': 'user_zen_balancetagoutward_key', 'key': 'D', 'plug': 'ZenCodingBalanceTagOutwardVisual', 'func': ':call zen_coding#Zen_balanceTag(-2)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_next_key', 'key': 'n', 'plug': 'ZenCodingNext', 'func': '<esc>:call zen_coding#Zen_moveNextPrev(0)<cr>'},
\ {'mode': 'n', 'var': 'user_zen_next_key', 'key': 'n', 'plug': 'ZenCodingNext', 'func': ':call zen_coding#Zen_moveNextPrev(0)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_prev_key', 'key': 'N', 'plug': 'ZenCodingPrev', 'func': '<esc>:call zen_coding#Zen_moveNextPrev(1)<cr>'},
\ {'mode': 'n', 'var': 'user_zen_prev_key', 'key': 'N', 'plug': 'ZenCodingPrev', 'func': ':call zen_coding#Zen_moveNextPrev(1)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_imagesize_key', 'key': 'i', 'plug': 'ZenCodingImageSize', 'func': '<esc>:call zen_coding#Zen_imageSize()<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_imagesize_key', 'key': 'i', 'plug': 'ZenCodingImageSize', 'func': ':call zen_coding#Zen_imageSize()<cr>'},
\ {'mode': 'i', 'var': 'user_zen_togglecomment_key', 'key': '/', 'plug': 'ZenCodingToggleComment', 'func': '<esc>:call zen_coding#Zen_toggleComment()<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_togglecomment_key', 'key': '/', 'plug': 'ZenCodingToggleComment', 'func': ':call zen_coding#Zen_toggleComment()<cr>'},
\ {'mode': 'i', 'var': 'user_zen_splitjointag_key', 'key': 'j', 'plug': 'ZenCodingSplitJoinTagInsert', 'func': '<esc>:call zen_coding#Zen_splitJoinTag()<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_splitjointag_key', 'key': 'j', 'plug': 'ZenCodingSplitJoinTagNormal', 'func': ':call zen_coding#Zen_splitJoinTag()<cr>'},
\ {'mode': 'i', 'var': 'user_zen_removetag_key', 'key': 'k', 'plug': 'ZenCodingRemoveTag', 'func': '<esc>:call zen_coding#Zen_removeTag()<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_removetag_key', 'key': 'k', 'plug': 'ZenCodingRemoveTag', 'func': ':call zen_coding#Zen_removeTag()<cr>'},
\ {'mode': 'i', 'var': 'user_zen_anchorizeurl_key', 'key': 'a', 'plug': 'ZenCodingAnchorizeURL', 'func': '<esc>:call zen_coding#Zen_anchorizeURL(0)<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_anchorizeurl_key', 'key': 'a', 'plug': 'ZenCodingAnchorizeURL', 'func': ':call zen_coding#Zen_anchorizeURL(0)<cr>'},
\ {'mode': 'i', 'var': 'user_zen_anchorizesummary_key', 'key': 'A', 'plug': 'ZenCodingAnchorizeSummary', 'func': '<esc>:call zen_coding#Zen_anchorizeURL(1)<cr>a'},
\ {'mode': 'n', 'var': 'user_zen_anchorizesummary_key', 'key': 'A', 'plug': 'ZenCodingAnchorizeSummary', 'func': ':call zen_coding#Zen_anchorizeURL(1)<cr>'},
\]

  if !hasmapto('<plug>'.s:item.plug, s:item.mode)
    exe s:item.mode . 'noremap <plug>' . s:item.plug . ' ' . s:item.func
  endif
  if !exists('g:' . s:item.var)
    exe 'let g:' . s:item.var . " = '" . g:user_zen_leader_key . s:item.key . "'"
  endif
  if len(maparg(eval('g:' . s:item.var), s:item.mode)) == 0
    exe s:item.mode . 'map ' . s:target . ' ' . eval('g:' . s:item.var) . ' <plug>' . s:item.plug
  endif
endfor
unlet s:target
unlet s:item
