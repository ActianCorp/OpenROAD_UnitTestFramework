# OpenROAD UnitTest Framework

Needs:

  * OpenROAD 6.2 (due to renameapp requirement)
       * Ingres (for example Ingres 10.2 + latest patch) for test database
  * Cygwin (from https://www.cygwin.com/)
      * bash (some bash extensions have been used)
      * diffutils (diff)
  * Some tests expect a hard coded temporary path location needs to exist:
      * Windows; `C:\temp`
      * Unix; `/tmp`

Sample usage:

    destroydb -uingres orunit
    createdb -uingres orunit
    bash or_tests.bash orunit

Windows users can call bash directly as above (assuming Cygwin in the path) or instead use the convience wrapper script `or_tests.bat`

    destroydb -uingres orunit
    createdb -uingres orunit
    or_tests orunit


## Instructions

  1. Create a new application:
       1. Include `UnitTestFramework`.
  2. Create new Userclass:
       1. Inherit from `testcase`.
       2. Create Method in Userclass editor, that starts with the word `test`.
       3. Create Method code in script editor.
  3. Create 4gl procedure named `runtests` (or import from another test)
      1. Ensure `runtests` calls Userclass name defined from above
      2. Ensure `runtests` is the starting component for the application

