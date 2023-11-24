# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# This cmake file adds the wrapper function add_cpp_test()
# which adds a C++ unit test using the google test framwork
# to the build project, if the googletest package is installed.

# Needed to get google test working
if ( POLICY CMP0057 )
  cmake_policy ( SET CMP0057 NEW ) # allow the IN_LIST keyword
endif ( POLICY CMP0057 )
if ( POLICY CMP0074 )
  cmake_policy ( SET CMP0074 NEW ) # using <package>_ROOT variables
endif ( POLICY CMP0074 )

# Find the google unit testing framework
find_path ( GTEST_ROOT gtest.h PATHS "$ENV{GTEST_ROOT}/include/gtest" )
if ( GTEST_ROOT )
  find_package ( GTest )
endif ( GTEST_ROOT )

if ( GTest_FOUND )
  message ( STATUS "NOTE : Configuring with C++ unit tests." )
  # Wrapper for gtest_add_tests
  function ( add_cpp_test TARGET )
    message ( STATUS "INFORMATION : Adding unit tests from ${TARGET}" )
    gtest_add_tests ( ${TARGET} "--srcdir=${CMAKE_CURRENT_SOURCE_DIR}" AUTO )
    if ( ${ARGC} GREATER 1 )
      target_link_libraries ( ${TARGET} ${ARGN} )
    endif ( ${ARGC} GREATER 1 )
    target_link_libraries ( ${TARGET} ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES} )
    if ( LINUX )
      target_link_libraries ( ${TARGET} pthread )
    endif ( LINUX )
    if ( TARGET check )
      add_dependencies ( check ${TARGET} )
    endif ( TARGET check )
  endfunction ( add_cpp_test )
endif ( GTest_FOUND )
