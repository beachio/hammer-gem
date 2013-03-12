# Joker #

<http://karottenreibe.github.com/joker>

Joker is a simple Wildcard (a.k.a Glob Pattern) implementition
for Ruby.

## Features ##

*   Behaves much like Regexp
*   ` * ` and ` ? ` as wildcard characters
*   ` \ ` for escaping:
    ` \? ` matches ` ? `,
    ` \* ` matches ` * `,
    ` \[ ` matches ` [ `,
    ` \] ` matches ` ] `,
*   But for all other characters:
    ` \a ` matches ` \a `, but not ` a `
*   Wildcards must always match whole string
    (thus ` uiae ` will only match the string ` uiae `)
*   Wildcards can be case insensitive

## Installation ##

    gem install joker

## Usage ##

    require 'rubygems'
    require 'joker'


    wild = Wildcard['Fairy?ake*']

    wild =~ 'Fairycake'                     #=> true
    wild =~ 'Fairyfakes'                    #=> true
    wild =~ 'Fairylake is a cool place'     #=> true

    wild =~ 'Dairycake'                     #=> false
    wild =~ 'Fairysteakes'                  #=> false
    wild =~ 'fairycake'                     #=> false

    wildi = Wildcard['Fairy?ake*\?', true]

    wildi =~ 'FairyCake?'                   #=> true
    wildi =~ 'fairyfakes?'                  #=> true
    wildi =~ 'FairyLake IS A COOL Place?'   #=> true

    Wildcard.quote('*?\\')                  #=> '\\*\\?\\\\'

## License ##

    Copyright (c) 2009 Fabian Streitel

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

