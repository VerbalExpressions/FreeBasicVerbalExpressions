/'
* Verbal Expressions v0.1 ported to FreeBASIC from JavaScript version.
*
* https://github.com/VerbalExpressions
*
* @author Ebben Feagan <ebben.feagan@gmail.com>
* @version 0.1
* @date 2014-03-23
*
* The MIT License (MIT)
*
* Copyright (c) 2014 Ebben Feagan
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
'/
#include once "vregex.bi"

enum VRFlags explicit
    GLOBAL = 1
    MULTILINE = 2
    INSENSITIVE = 4
end enum

#define COMPILE_IF_DIRTY if dirty then compile()
#define MARK_DIRTY dirty = true

operator = ( byref lhs as VRegex, byref rhs as VRegex ) as integer
    return iif(cast(string,lhs) = cast(string,rhs),true,false)
end operator

operator <> ( byref lhs as VRegex, byref rhs as VRegex ) as integer
    return iif(cast(string,lhs) = cast(string,rhs),false,true)
end operator

constructor VRegex()
end constructor

constructor VRegex( byref rhs as const string )
    MARK_DIRTY
    pattern = rhs
end constructor

constructor VRegex( byref rhs as const VRegex )
    this = rhs
end constructor

operator VRegex.let( byref rhs as const VRegex )
    pattern = rhs.pattern
    is_case_sensitive = rhs.is_case_sensitive
    is_multiline = rhs.is_multiline
    MARK_DIRTY
end operator

operator VRegex.cast () as string
    return pattern
end operator

function VRegex.add( byref rhs as string ) as VRegex ptr
    source &= rhs
    pattern = prefixes & source & suffixes
    MARK_DIRTY
    return @this
end function

function VRegex.startOfLine( byval enable as bool = true) as VRegex ptr
    if enable then
        prefixes ="^"
    else
        prefixes = ""
    end if
    return add("")
end function

function VRegex.endOfLine( byval enable as bool = true ) as VRegex ptr
    if enable then
        suffixes = "$"
    else
        suffixes = ""
    end if
    return add("")
end function

function VRegex._then( byref rhs as string ) as VRegex ptr
    return add("(?:" & rhs & ")")
end function

function VRegex.find( byref rhs as string ) as VRegex ptr
    return _then(rhs)
end function

function VRegex.maybe( byref rhs as string ) as VRegex ptr
    return add("(?:" & rhs & ")?")
end function

function VRegex.anything() as VRegex ptr
    return add("(?:.*)")
end function

function VRegex.anythingBut( byref rhs as string ) as VRegex ptr
    return add("(?:[^" & rhs & "]*)")
end function

function VRegex.something() as VRegex ptr
    return add("(?:.+)")
end function

function VRegex.somethingBut( byref rhs as string ) as VRegex ptr
    return add("(?:[^" & rhs & "]+)")
end function

function VRegex.lineBreak() as VRegex ptr
    return add("(?:(?:\n)|(?:\r\n))")
end function

function VRegex.br() as VRegex ptr
    return lineBreak()
end function

function VRegex.tab() as VRegex ptr
    return add("\t")
end function

function VRegex.word() as VRegex ptr
    return add("\w+")
end function

function VRegex.anyOf( byref rhs as string ) as VRegex ptr
    return add("[" & rhs & "]")
end function

function VRegex._any( byref rhs as string ) as VRegex ptr
    return anyOf(rhs)
end function

function VRegex.range( args() as string ) as VRegex ptr
    var value = "["

    for n as uinteger = lbound(args) to ubound(args) step 2
        value = value & args(n) & "-" & args(n+1)
    next

    value &= "]"
    return add(value)
end function

function VRegex.addModifier( byref i as string ) as VRegex ptr
    select case i
        case "i"
            is_case_sensitive = false
        case "m"
            is_multiline = true
        case "g"
            modifiers = modifiers or VRFlags.GLOBAL
    end select
    return @this
end function

function VRegex.removeModifier( byref i as string ) as VRegex ptr
    select case i
        case "i"
            is_case_sensitive = true
        case "m"
            is_multiline = false
        case "g"
            modifiers = modifiers xor VRFlags.GLOBAL
    end select
    return @this
end function

function VRegex.withAnyCase( byval enable as bool ) as VRegex ptr
    if enable then
        return addModifier("i")
    else
        return removeModifier("i")
    end if
end function

function VRegex.searchOneLine( byval enable as bool ) as VRegex ptr
    if not enable then
        return addModifier("m")
    else
        return removeModifier("m")
    end if
end function

function VRegex.searchGlobal( byval enable as bool ) as VRegex ptr
    if enable then
        return addModifier("g")
    else
        return removeModifier("g")
    end if
end function

function VRegex.multiple( byref rhs as string ) as VRegex ptr
    if rhs[0] <> asc("*") andalso rhs[0] <> asc("+") then
        var t = this.add("+")
    end if
    return add(rhs)
end function

function VRegex.alt( byref rhs as string ) as VRegex ptr
    if instr(prefixes,"(") < 1 then prefixes &= "("
    if instr(suffixes,")") < 1 then suffixes = ")" & suffixes
    var t=add(")|(")
    return _then(rhs)
end function

function VRegex.reduceLines( byref rhs as string ) as string
    var ret = rhs
    var pos_ = instr(ret,!"\n")
    if pos_ < 1 then return ret
    return mid(ret,1,pos_-1)
end function

function VRegex.checkFlags() as uinteger
    var ret = 0u
    if is_case_sensitive then
        ret = ret or PCRE_CASELESS
    end if
    if is_multiline then
        ret = ret or PCRE_MULTILINE
    end if
    return ret
end function

sub VRegex.compile()
    if re <> 0 then
        pcre_free(re)
    end if
    if re_study <> 0 then
        pcre_free_study(re_study)
    end if
    re = pcre_compile(pattern,checkFlags(),@error_string,@error_offset,0)
    if re <> 0 then
        re_study = pcre_study(re,PCRE_STUDY_JIT_COMPILE,@error_string)
    else
        re_study = 0
    end if
    dirty = false
end sub

destructor VRegex()
    if re <> 0 then
        pcre_free(re)
    end if
    if re_study <> 0 then
        pcre_free_study(re_study)
    end if
end destructor

function VRegex.test( byref rhs as string ) as bool
    COMPILE_IF_DIRTY
    var toTest = ""
    if modifiers and VRFlags.MULTILINE then
        toTest = rhs
    else
        toTest = reduceLines(rhs)
    end if

    dim result as bool
    var errors = pcre_exec(re,re_study,rhs,len(rhs),0,checkFlags(),0,0)
    if errors >= 0 then
        result = true
    else
        ? using "Options: &"; checkFlags()
        ? using "Error: &"; errors
        result = false
    end if
    return result
end function

function VRegex.replace( byref source as string, byref v as string ) as string
    COMPILE_IF_DIRTY
    var buf = ""
    var cmatches = 8
    var matches = new integer[cmatches]
    var errors = 0
    runregex:
    errors = pcre_exec(re,re_study,source,len(source),0,0,matches,cmatches)
    if errors < 0 then
        error_string = @"No matches found or other error, code in offset."
        error_offset = errors
        delete[] matches
        return source
    elseif errors = 0 then
        delete[] matches
        cmatches *= 2
        matches = new integer[cmatches]
        goto runregex
    end if
    var last_i = 1
    for n as integer = 0 to (errors*2)-1 step 2
        buf = buf & mid(source,last_i,matches[n]) & v & mid(source,matches[n+1]+1)
        last_i = matches[n] + len(v) + 1
    next

    delete[] matches
    return buf
end function


#ifdef __FB_MAIN__
sub test_url( byref url as string )
    var expr = VRegex()
    with expr
        .searchOneLine()
        .startOfLine()
        ._then("http")
        .maybe("s")
        ._then("://")
        .maybe("www.")
        .anythingBut(" ")
        .endOfLine()
    end with

    if expr.test(url) then
        print url & " is a valid url."
    else
        print url & " is NOT a valid url."
    end if
    if expr.error_string <> 0 then
        ? *(expr.error_string)
    end if
    print expr
end sub

sub test_replace( )
    var expr = VRegex()
    expr.find("red")
    print expr.replace("The house is red.","blue")
    print expr.replace("My name is Fred.","rank")
    print expr
end sub

var turl = "https://www.google.com"
if command(1) <> "" then
    turl = command(1)
end if

print "URL Test:"
test_url(turl)
print

print "Replace Test:"
test_replace
#endif
