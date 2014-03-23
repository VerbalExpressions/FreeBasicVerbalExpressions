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

#ifndef __VERBAL_REGULAR_EXPRESSIONS_BI__
#define __VERBAL_REGULAR_EXPRESSIONS_BI__ -1

#include once "pcre.bi"

#ifndef bool
#ifdef false
#undef false
#endif
#ifdef true
#undef true
#endif
enum bool
    false = 0
    true = not false
end enum
#endif

type VRegex
    declare constructor()
    declare constructor( byref s as const string )
    declare constructor( byref rhs as const VRegex )
    declare operator let( byref rhs as const VRegex )
    declare destructor
    declare operator cast() as string
    declare function replace( byref source as string, byref v as string ) as string
    declare function test( byref rhs as string ) as bool

    declare function _then( byref rhs as string ) as VRegex ptr
    declare function startOfLine( byval enable as bool = true ) as VRegex ptr
    declare function endOfLine( byval enable as bool = true ) as VRegex ptr
    declare function find( byref rhs as string ) as VRegex ptr
    declare function maybe( byref rhs as string ) as VRegex ptr
    declare function anything() as VRegex ptr
    declare function anythingBut( byref rhs as string ) as VRegex ptr
    declare function something() as VRegex ptr
    declare function somethingBut( byref rhs as string ) as VRegex ptr
    declare function lineBreak() as VRegex ptr
    declare function br() as VRegex ptr
    declare function tab() as VRegex ptr
    declare function word() as VRegex ptr
    declare function anyOf( byref rhs as string ) as VRegex ptr
    declare function _any( byref rhs as string ) as VRegex ptr
    declare function range( args() as string ) as VRegex ptr
    declare function addModifier( byref i as string ) as VRegex ptr
    declare function removeModifier( byref i as string ) as VRegex ptr
    declare function withAnyCase( byval enable as bool = true ) as VRegex ptr
    declare function searchOneLine( byval enable as bool = true ) as VRegex ptr
    declare function searchGlobal( byval enable as bool = true ) as VRegex ptr
    declare function multiple( byref rhs as string ) as VRegex ptr
    declare function alt( byref rhs as string ) as VRegex ptr

    as zstring ptr error_string
    as integer error_offset

    private:
        declare function add( byref rhs as string ) as VRegex ptr
        declare function checkFlags() as uinteger
        declare function reduceLines( byref rhs as string ) as string
        declare sub compile()
        dirty as bool
        re as pcre ptr
        re_study as pcre_extra_ ptr
        is_multiline as bool
        is_case_sensitive as bool
        prefixes as string
        source as string
        suffixes as string
        pattern as string
        modifiers as uinteger
end type

declare operator = ( byref lhs as VRegex, byref rhs as VRegex ) as integer
declare operator <> ( byref lhs as VRegex, byref rhs as VRegex ) as integer

#inclib "fbvregex"
#endif '__VERBAL_REGULAR_EXPRESSIONS_BI__
