# OpenROAD UnitTest Framework

Needs:

  * OpenROAD 6.2 (due to renameapp requirement)
  * Cygwin (from https://www.cygwin.com/)
      * bash (some bash extensions have been used)
      * diffutils (diff)
  * Some tests expect a hard coded temporary path location needs to exist:
      * Windows; `C:\temp`
      * Unix; `/tmp`

Sample usage:

    # Windows/Cygwin specific
    # Ensure Cygwin is in the path, assuming default location for 32-bit or 64-bit:
    path C:\cygwin\bin;%PATH%
    path C:\cygwin64\bin;%PATH%

    # allow Windows new lines in shell scripts
    set SHELLOPTS=igncr

    md C:\temp

    destroydb -uingres orunit
    createdb -uingres orunit
    bash or_tests.bash orunit
    #bash or_tests.bash localXI::orunit

## Instructions

  1. Create a new application:
       1. Include `UnitTestFramework`.
  2. Create new Userclass:
       1. Inherit from `testcase`.
       2. Create Method in Userclass editor, that starts with the word `test` (NOTE lowercase).
       3. Create Method code in script editor.
  3. Create 4gl procedure named `runtests` (or import from another test)
      1. Ensure `runtests` calls Userclass name defined from above
      2. Ensure `runtests` is the starting component for the application

