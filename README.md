FreeBASICVerbalExpressions
==================

## Regular Expressions made easy

Verbal Expressions is a FreeBASIC module that helps to construct difficult regular expressions.
It is a high level wrapper around the excellent PCRE library and will require linking to a compatible version of PCRE (as of FreeBASIC 1.09 this is PCRE 8).

This FreeBASIC module is based off of the original Javascript [Verbal expressions library](https://github.com/jehna/VerbalExpressions) by [jehna](https://github.com/jehna/).

## Examples

### Testing if we have a valid URL

```FreeBASIC

    'Create the object
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

    print expr

```

## Compiling

Use the provided build scripts, build.bat for Windows and build.sh for *nix.

## Installing

Copy the headers in include/freebasic to your FreeBASIC include directory.
Copy the built *.a in lib to your FreeBASIC lib directory.

## Using in your project

Include this library into your project with:

```FreeBASIC
#include once "vregex.bi"
```

## API

### Terms
* .anything()
* .anythingBut(string value)
* .something()
* .somethingBut(string value)
* .endOfLine()
* .find(string value)
* .maybe(string value)
* .startOfLine()
* ._then(string value)

### Special characters and groups
* ._any(string value)
* .anyOf(string value)
* .br()
* .lineBreak()
* .range(args() as string)
* .tab()
* .word()

### Modifiers
* .withAnyCase()
* .searchOneLine()
* .searchGlobal()

### Functions
* .replace(string source, string value)
* .test()

### Other
* .multiple(string value)
* .alt()

## Other implementations
You can view all implementations on [VerbalExpressions.github.io](http://VerbalExpressions.github.io)
