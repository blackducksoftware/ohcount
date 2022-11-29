![Coverity Scan Build](https://github.com/blackducksoftware/ohcount/actions/workflows/coverity.yml/badge.svg?branch=main)
![Build Status](https://github.com/blackducksoftware/ohcount/actions/workflows/ci.yml/badge.svg?branch=main)

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
the reports at www.openhub.net.

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

Language Support
-------------------

See: [src/languages.h](https://github.com/blackducksoftware/ohcount/blob/main/src/languages.h)

System Requirements
-------------------

Ohcount is supported on Ubuntu 18.04 LTS. It has also been tested on Fedora 29.
Other unix-like environments should also work, but your mileage may vary.

Ohcount does not support Windows.

Building Ohcount
----------------

```
$ git clone git://github.com/blackducksoftware/ohcount.git
$ cd ohcount
```

#### Dockerfile

One may use the bundled Dockerfile to build ohcount for Ubuntu:

```
$ docker build -t ohcount:ubuntu .
```

#### Manual build

> Last updated: 2021-12-09

Ohcount needs `Ruby 2.*` to run tests. The ruby dev headers provided by Ubuntu/Fedora
package managers were found to be missing a `config.h` header file. If the
default ruby and ruby-dev packages do not work, install ruby using
brew/rbenv/asdf/rvm, which work reliably with ohcount.

You will need ragel 7.0 or higher, bash, gperf, libpcre3-dev, libmagic-dev,
gcc(version 7.3 or greater) and swig (>=3.0.0).
For older gcc versions one could try [this fix](https://github.com/blackducksoftware/ohcount/pull/70/commits/c7511b9810a8660a8268a958fee0e365fb9af18f).

##### Ubuntu/Debian

```
$ sudo apt-get install libpcre3 libpcre3-dev libmagic-dev gperf gcc ragel swig
$ ./build
```

##### Fedora

```
$ sudo dnf install gcc file-devel gperf ragel swig pcre-devel
$ ./build
```

##### OSx

```
$ brew install libmagic pcre ragel swig
$ ./build
```

##### Other Unix systems

* If build fails with a missing `ohcount.so` error and any `ruby/x86.../` folder has the file, copy it to `ruby/` folder.

Using Ohcount
-------------

Once you've built ohcount, the executable program will be at bin/ohcount. The most basic use is to count lines of code in a directory tree:

```
$ bin/ohcount path/to/directory
```

Ohcount support several options. Run `ohcount --help` for more information.

Building Ruby and Python Libraries
----------------------------------

To build the ruby wrapper:

```
$ ./build ruby
```

To build the python wrapper, run

```
$ python python/setup.py build
$ python python/setup.py install
```

The python wrapper is currently unsupported.


Contributing
-------------

* Observe any existing PR contribution and emulate the pattern. For e.g. see [this](https://github.com/blackducksoftware/ohcount/pull/76/files).
* While writing the **test/expected_dir** files, disable any whitespace/tab replacing options from your editor.
* Ohcount output has tabs in it, so the **test/expected_dir** also needs to contain tab characters.
* Sample format of **test/expected_dir** is as follows. There is a tab character after dart, code & comment:
```
dart	code	void main() {
dart	comment	  // Line comment
```
* Run tests with `./build tests`.
