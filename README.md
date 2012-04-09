Ohcount
=======

Ohloh's source code line counter.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License Version 2 as
published by the Free Software Foundation.

License
-------

Ohcount is specifically licensed under GPL v2.0, and no later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Overview
--------

Ohcount is a library for counting lines of source code.
It was originally developed at Ohloh, and is used to generate
the reports at www.ohloh.net.

Ohcount supports multiple languages within a single file: for example,
a complex HTML document might include regions of both CSS and JavaScript.

Ohcount has two main components: a detector which determines the primary
language family used by a particular source file, and a parser which
provides a line-by-line breakdown of the contents of a source file.

Ohcount includes a command line tool that allows you to count individual
files or whole directory trees. It also allows you to find source code
files by language family, or to create a detailed annotation of an
individual source file.

Ohcount includes a Ruby binding which allows you to directly access its
language detection features from a Ruby application.

System Requirements
-------------------

Ohcount is supported on Mac OS X 10.4 and 10.5 and Ubuntu 10.04 LTS. Other Linux
environments should also work, but your mileage may vary.

Ohcount does not support Windows.

Ohcount targets Ruby 1.8.7. The build script requires a bash shell. You
also need a C compiler to build the native extensions.

Source Code
-----------

Ohcount source code is available as a Git repository:

  git clone git://github.com/blackducksw/ohcount.git

Building Ohcount
----------------

You will need ragel 6.3 or higher, bash, pcre, magic, gcc (version 4.1.2 or greater)
and SWIG. Once you have them, go to the top directory of ohcount and run

```
./build
```

Using Ohcount
-------------

Once you've built ohcount, the executable program will be at bin/ohcount. The most basic use is to count lines of code in a directory tree. run:

```
bin/ohcount
```

Ohcount support several options. Run `ohcount --help` for more information.

Building Ruby and Python Libraries
----------------------------------

To build the ruby wrapper:

```
./build ruby
```

To build the python wrapper, run

```
python python/setup.py build
python python/setup.py install
```

The python wrapper is currently unsupported.
