if version < 700
  finish
endif

syn match winfilerInfoA  /^[0-9\/]\{10\}  */
syn match winfilerInfoB  /[0-9:]\{5\} */
syn match winfilerInfoC  /[0-9,]* /
syn match winfilerDir    /<DIR>.*/
syn match winfilerSym    /<SYMLINKD*/
syn match winfilerExt1   /\(\<exe$\|\<EXE$\|\<o$\|\<xml$\|\<doc$\|\<lzh$\|\<7z$\|\<jpg$\|\<lzma$\|\<vcproj$\)/
syn match winfilerExt2   /\(\<dll$\|\<DLL$\|\<h$\|\<php$\|\<xls$\|\<zip$\|\<gz$\|\<tif$\|\<html$\|\<class$\)/
syn match winfilerExt3   /\(\<obj$\|\<OBJ$\|\<C$\|\<XML$\|\<pdf$\|\<cab$\|\<pl$\|\<png$\|\<xaml$\|\<sln$\)/
syn match winfilerExt4   /\(\<cpp$\|\<CPP$\|\<c$\|\<ini$\|\<psd$\|\<tar$\|\<ps$\|\<bmp$\|\<java$\|\<txt$\)/
syn match winfilerExt5   /\(\<lnk$\|\<LNK$\|\<O$\|\<def$\|\<dws$\|\<bat$\|\<cc$\|\<ras$\|\<HTML$\)/
syn match winfilerExt6   /\(\<sys$\|\<SYS$\|\<H$\|\<log$\|\<DOC$\|\<vim$\|\<CC$\|\<gif$\|\<XML$\)/
syn match winfilerPath   /[a-zA-Z]:\\.*\\/
syn match winfilerUnc    /\\\\.*\\/
syn match winfilerYTitle '<< yanked files >>'
syn match winfilerYTitle '<< winfiner >>'
syn match winfilerCurrent /^Current:/
syn match winfilerToggle /^Toggle: /
syn match winfilerCont   /^sort=.*$/
syn match winfilerInfo1  /^.*個のファイル.* バイト$/
syn match winfilerInfo2  /^.*個のディレクトリ.* バイトの空き領域$/
syn match winfilerSort   /\(\<name$\|\<size$\|\<time$\|\<extension$\)/
syn match winfilerSelect /\*.*$/
syn match winfilerDiskPartLabel /^  Ltr Label            Fs       Size(MB) Free(MB) Status    /
syn match winfilerDiskPartSep   /^  --- ---------------- -------- -------- -------- ----------/
syn match winfilerSpecialLabel  /^  Label                Path                                 /
syn match winfilerSpecialSep    /^  -------------------- -------------------------------------/
syn match winfilerControlLabel  /^  Control panel tool             Command                           /
syn match winfilerControlSep    /^  ------------------------------ ----------------------------------/
syn match winfilerMenu0  /^->.0\. .*$/
syn match winfilerMenu1  /^->.1\. .*$/
syn match winfilerMenu2  /^->.2\. .*$/
syn match winfilerMenu3  /^->.3\. .*$/
syn match winfilerMenu4  /^->.4\. .*$/
syn match winfilerMenu5  /^->.5\. .*$/
syn match winfilerMenu6  /^->.6\. .*$/
syn match winfilerMenu7  /^->.7\. .*$/
syn match winfilerMenu8  /^->.8\. .*$/
syn match winfilerMenu9  /^->.9\. .*$/
syn match winfilertoggle /--->/

if exists('g:colors_name') && g:colors_name =~ "neon"
hi winfilerInfoA   guibg=#000505 guifg=#5060FF gui=none
hi winfilerInfoB   guibg=#001010 guifg=#7090FF gui=none
hi winfilerInfoC   guibg=#001515 guifg=#90A0FF gui=none
hi winfilerDir     guibg=#001515 guifg=#5080F0 gui=none
hi winfilerSym     guibg=#050560 guifg=#9090FF gui=none
hi winfilerExt1    guibg=#000000 guifg=#FF0000 gui=none
hi winfilerExt2    guibg=#000000 guifg=#00FF00 gui=none
hi winfilerExt3    guibg=#000000 guifg=#0080FF gui=none
hi winfilerExt4    guibg=#000000 guifg=#FFFF00 gui=none
hi winfilerExt5    guibg=#000000 guifg=#008000 gui=none
hi winfilerExt6    guibg=#000000 guifg=#00FFFF gui=none
hi winfilerPath    guibg=#000000 guifg=#6688AA gui=none
hi winfilerUnc     guibg=#000000 guifg=#6688AA gui=none
hi winfilerYTitle  guibg=#000000 guifg=#6699FF gui=underline
hi winfilerCurrent guibg=#050560 guifg=#9090FF gui=none
hi winfilertoggle  guibg=#050560 guifg=#9090FF gui=none
hi winfilerCont    guibg=#000030 guifg=#EEEEEE gui=none
hi winfilerInfo1   guibg=#000000 guifg=#666666 gui=none
hi winfilerInfo2   guibg=#000000 guifg=#666666 gui=none
hi winfilerSort    guibg=#000000 guifg=#80EEEE
hi winfilerDiskPartLabel guibg=#004080 guifg=#B0D0FF gui=none
hi winfilerDiskPartSep   guibg=#001515 guifg=#5080F0 gui=none
hi winfilerSpecialLabel  guibg=#004080 guifg=#B0D0FF gui=none
hi winfilerSpecialSep    guibg=#001515 guifg=#5080F0 gui=none
hi winfilerControlLabel  guibg=#004080 guifg=#B0D0FF gui=none
hi winfilerControlSep    guibg=#001515 guifg=#5080F0 gui=none
hi winfilerMenu0   guibg=#000505 guifg=#5060FF gui=none
hi winfilerMenu1   guibg=#001515 guifg=#90A0FF gui=none
hi winfilerMenu2   guibg=#000505 guifg=#5060FF gui=none
hi winfilerMenu3   guibg=#001515 guifg=#90A0FF gui=none
hi winfilerMenu4   guibg=#000505 guifg=#5060FF gui=none
hi winfilerMenu5   guibg=#001515 guifg=#90A0FF gui=none
hi winfilerMenu6   guibg=#000505 guifg=#5060FF gui=none
hi winfilerMenu7   guibg=#001515 guifg=#90A0FF gui=none
hi winfilerMenu8   guibg=#000505 guifg=#5060FF gui=none
hi winfilerMenu9   guibg=#001515 guifg=#90A0FF gui=none
else
hi link winfilerInfoA   Keyword
hi link winfilerInfoB   Type
hi link winfilerInfoC   PreProc
hi link winfilerDir     Directory
hi link winfilerSym     String
hi link winfilerExt1    Number
hi link winfilerExt2    Boolean
hi link winfilerExt3
hi link winfilerExt4
hi link winfilerExt5
hi link winfilerExt6
hi link winfilerPath    Comment
hi link winfilerUnc     Comment
hi link winfilerYTitle  Title
hi link winfilerFTitle  Title
hi link winfilerCTitle  Title
hi link winfilerBTitle  Title
hi link winfilerMTitle  Title
hi link winfilerGTitle  Title
hi link winfilerSTitle  Title
hi link winfilerCurrent Title
hi link winfilerToggle  Title
hi link winfilerCont    Repeat
hi link winfilerInfo1   Define
hi link winfilerInfo2   Macro
hi link winfilerSort    Statement
hi link winfilerDiskPartLabel  Title
hi link winfilerDiskPartSep    Directory
hi link winfilerSpecialLabel   Title
hi link winfilerSpecialSep     Directory
hi link winfilerControlLabel   Title
hi link winfilerControlSep     Directory
hi link winfilerMenu0  Keyword
hi link winfilerMenu1  PreProc
hi link winfilerMenu2  Keyword
hi link winfilerMenu3  PreProc
hi link winfilerMenu4  Keyword
hi link winfilerMenu5  PreProc
hi link winfilerMenu6  Keyword
hi link winfilerMenu7  PreProc
hi link winfilerMenu8  Keyword
hi link winfilerMenu9  PreProc
hi link winfilertoggle Function
endif
hi winfilerSelect               guifg=#0000FF gui=bold 
