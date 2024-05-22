<!---
  SPDX-FileCopyrightText: 2023 SAP SE

  SPDX-License-Identifier: Apache-2.0

  This file is part of FEDEM - https://openfedem.org
--->

[![REUSE status](https://api.reuse.software/badge/github.com/openfedem/cmake-modules)](https://api.reuse.software/info/github.com/openfedem/cmake-modules)

# FEDEM cmake modules

## About this project

This project contains a set of general [CMake](https://cmake.org/)
configuration files, used for building the program modules of FEDEM.

## Requirements and Setup

This repository is consumed as a submodule by the other FEDEM repositories
to facilitate a common build setup for those, and therefore does not require
any setup for itself.

## The cmake files

Here is the list of `.cmake` files in the [Modules](Modules) folder
and what they do:

- `FedemConfig.cmake` contains general compiler flag setup for the builds.
  Currently, gcc on Linux (Ubuntu) and MS Visual Studio with Intel Fortran
  on Windows is supported. This file needs to be included in the top-level
  `CMakeLists.txt` file of the build project.
- `Date.cmake` defines the macro `date()` for creating time stamp source files
   that generates the build date in the compiled binaries.
- `GTest.cmake` defines the function `add_cpp_test()` for defining a C++
  unit test, if the [googletest](https://https://github.com/google/googletest/)
  framework is installed. It uses the environment variable `GTEST_ROOT`
  to determine whether the googletest package is available or not.
- `CheckPFUnit.cmake` detects if the package
  [pFUnit](https://github.com/Goddard-Fortran-Ecosystem/pFUnit/)
  has been installed for conducting Fortran unit tests.
  It uses the environment variable `PFUNIT` to check for valid installations.
- `pFUnit.cmake` defines the macro `enable_fortran_tests()` which adds some
  compiler flags needed for building the Fortran unit tests with pFUnit, and the
  function `add_fortran_test()` which defines a specific Fortran unit test.
- `CodeCoverage.cmake` contains some functions for generating code coverage
  reports using the tools [gcov](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html),
  [lcov](https://github.com/linux-test-project/lcov), and
  [gcovr](https://gcovr.com/en/stable/) (on Linux only).

## Contributing

This project is open to feature requests, suggestions, bug reports, etc.,
via [GitHub issues](https://github.com/openfedem/cmake-modules/issues).
Contributions and feedback are encouraged and always welcome.
For more information about how to contribute,
see our [Contribution Guidelines](.github/CONTRIBUTING.md).

## Licensing

Copyright 2023 SAP SE or an SAP affiliate company and cmake-modules contributors.
Please see our [LICENSE](LICENSE) for copyright and license information.
Detailed information including third-party components and their licensing/copyright information
is available via the [REUSE tool](https://api.reuse.software/info/github.com/openfedem/cmake-modules).
