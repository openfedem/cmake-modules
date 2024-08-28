# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

cmake_minimum_required ( VERSION 2.8...3.5 )

# Project setup

project ( cmake-test CXX )

message ( STATUS "Generating build project for ${PROJECT_SOURCE_DIR}" )
find_path ( _MODULES FedemConfig.cmake
            PATHS $ENV{CMAKE_MODULES} ../Modules )
if ( _MODULES )
  message ( STATUS "NOTE : Using ${_MODULES}" )
  list ( APPEND CMAKE_MODULE_PATH ${_MODULES} )
else ( _MODULES )
  message ( STATUS "ERROR : Missing path to FedemConfig.cmake" )
  message ( FATAL_ERROR "Set environment variable CMAKE_MODULES and try again" )
endif ( _MODULES )
unset ( _MODULES CACHE )

include ( FedemConfig )

# Enable unit testing

enable_testing ()
set ( CTEST_OPTIONS --force-new-ctest-process --output-on-failure -O CTest.txt )
add_custom_target ( check COMMAND ${CMAKE_CTEST_COMMAND} ${CTEST_OPTIONS} )

include ( GTest ) # Using the google test framework for C++ unit tests

if ( GTest_FOUND )
  add_executable ( test_cmake test_gtest.C )
  add_cpp_test ( test_cmake )
else ( GTest_FOUND )
  message ( FATAL_ERROR "The google test framework was not found" )
endif ( GTest_FOUND )
