## DoxygenProlog: dox4pl
### A doxygen filter to use with Prolog

#### Summary

A filter done in LEX (.l) to convert _PROLOG_ programs into simple tokens of _C/C++_ that can be used to generate documentation of Prolog programs with Doxygen.

#### Description

You need to install this filter into your machine's __PATH__, and tells doxygen to use it by associating the file extension _\*.pl_ with __doxygenprolog__

##### How To?

To setup doxygen, you need:

> OPTIMIZE_OUTPUT_FOR_C = NO

> INPUT                 = README.md groups.dox yourprologsource.pl

> EXTRACT_ALL           = YES

> EXTRACT_STATIC        = YES

> FILE_PATTERNS         = *.pl *.prolog *.swipl

> FILTER_PATTERNS       = *.pl="dox4pl"

##### What is it like?

Take a look at the wiki site here in github, and follow to the example link.

[Pl2Dox Wiki](https://github.com/drbeco/doxygenprolog/wiki)


This is still a starting prototype, but it is working very well. 

_Enjoy!_

__Dr Beco__
_________________________________________________________________

####Change Log

##### Build 20150628.131912
* Corrected the name to dox4pl (means doxygen for prolog)

After realizing dox2pl was inverted, and trying to change to pl2dox, I observed that github repository
is named DoxygenProlog. Renaming the repository was not an option, since it would break all links
kind people over the world added into some sites 

(speciall thanks to Dimitri [Doxygen Official](http://www.stack.nl/~dimitri/doxygen/helpers.html) and
Jam [SWI-Prolog Official](http://www.swi-prolog.org/news/3b9546ec-1d66-11e5-9067-00163e357fe2)).

So, changing to dox4pl solves all the problems. And as a 2 plus, its 4, not 2! ;)

##### Build 20150628.125352
* Corrected the name to pl2dox (means prolog converted to doxygen)

##### Version 20150627.125100
* Read from file
* Optarg keys: hVvq and [filename]
* makefile without -Wno-unused-function
* IFDEBUG defined
* License and copyright information available in source (opensource complying)
* Doxygen comments
* Better format of output

##### Version 20150626
* First release
* Read only from stdin (redirect < operator needed)


####Program details
* Version 20150627.125100
* Date 2015-06-27
* Author Ruben Carlo Benante <<rcb@beco.cc>> (beco)
* Webpage <[www.beco.cc](www.beco.cc)>

_________________________________________________________________

####Copyright, License and Warranty

__copyright (c) 2015 GNU GPL v3__

This program is free software: you can redistribute it
and/or modify it under the terms of the
GNU General Public License as published by
the Free Software Foundation version 3 of the License.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.
If not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA. 02111-1307, USA.
Or read it online at <<http://www.gnu.org/licenses/>>.

_________________________________________________________________

_Template by Dr. Beco < rcb at beco dot cc > Version 20150619.231433_

