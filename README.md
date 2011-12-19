Radare2 Regression Test Suite
=============================

A set of regression tests for Radare2 (http://radare.org).

Originally based on work by and now in collaboration with pancake.

Directory Hierarchy
-------------------

t/		Test scripts.
s/		Sample binaries.
test.sh		Test driver script sourced by tests.
		^------- Do not run this manually.

Requirements
------------

 * Radare2 installed and in $PATH (obviously).
 * bmake or gmake.

Usage
-----

 * Run 'make' in the top level directory to run *all* tests.
 * To run individual tests, cd into 't/' and execute the desired script.

Reporting Radare2 Bugs
----------------------

Please to not post Radare2 bugs on the r2-regressions github tracker. Instead
use te official r2 tracker:

http://radare.org/y/?p=bugtracker
