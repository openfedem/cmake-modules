# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# Functions for unit-testing of Fortran code using the pFUnit package.
# Also pFUnit 3 is supported here, for backward compatibility.
#
# The variable PFUNIT_PATH needs to point to the folder containing
# the pFUnit installation before including this file.

if ( PFUNIT_PATH )
  # Find the Fortran unit testing framework
  if ( PFUNIT_PATH MATCHES PFUNIT-4 )
    if ( POLICY CMP0074 )
      cmake_policy ( SET CMP0074 NEW ) # using <package>_ROOT variables
    endif ( POLICY CMP0074 )
    find_package ( PFUNIT )
    # Deactivate pFUnit 4 for Coverage build due to run-time problems.
    # Probably a gfortran compiler issue. Revisit this when upgrading the build OS.
    if ( PFUNIT_FOUND AND CMAKE_BUILD_TYPE STREQUAL "Coverage" )
      if ( CMAKE_HOST_SYSTEM_VERSION MATCHES "Microsoft" )
        message ( WARNING " pFUnit4 is disabled for Coverage build on Microsoft WSL.
 Therefore, all Fortran unit tests will be omitted." )
        set ( PFUNIT_FOUND OFF )
      else ( CMAKE_HOST_SYSTEM_VERSION MATCHES "Microsoft" )
        set ( pFUnit_FOUND ${PFUNIT_FOUND} )
      endif ( CMAKE_HOST_SYSTEM_VERSION MATCHES "Microsoft" )
    else ( PFUNIT_FOUND AND CMAKE_BUILD_TYPE STREQUAL "Coverage" )
      set ( pFUnit_FOUND ${PFUNIT_FOUND} )
    endif ( PFUNIT_FOUND AND CMAKE_BUILD_TYPE STREQUAL "Coverage" )
  else ( PFUNIT_PATH MATCHES PFUNIT-4 )
    # Check for pFUnit 3
    find_package ( PythonInterp 3 ) # enforce using python3
    if ( PythonInterp_FOUND )
      find_package ( pFUnit )
    else ( PythonInterp_FOUND )
      message ( WARNING " Python is not found - Fortran unit testing disabled" )
    endif ( PythonInterp_FOUND )
    set ( PFUNIT_FOUND FALSE )
  endif ( PFUNIT_PATH MATCHES PFUNIT-4 )
endif ( PFUNIT_PATH )
unset ( PFUNIT_DIR CACHE )
unset ( pFUnit_DIR CACHE )

if ( pFUnit_FOUND )
  message ( STATUS "NOTE : Configuring with Fortran unit tests." )
  get_filename_component ( PARENT_DIR ${CMAKE_CURRENT_LIST_DIR} PATH )
  get_filename_component ( PARENT_DIR ${PARENT_DIR} PATH )

  # Macro for specifying some additional fortran compiler flags for the unit tests
  macro ( enable_fortran_tests )
    cmake_parse_arguments ( USE SRCDIR "" "" ${ARGN} )
    if ( USE_SRCDIR )
      if ( PFUNIT_FOUND )
        # pFUnit 4 is used.
        if ( EXISTS ${PARENT_DIR}/pFUnit/pFUnitExtra.f90.in )
          # Enable use of the fUnitExtra::get_srcdir subroutine.
          configure_file ( ${PARENT_DIR}/pFUnit/pFUnitExtra.f90.in pFUnitExtra.f90 )
          string ( APPEND CMAKE_Fortran_FLAGS " -DPFUNIT_EXTRA_USE=fUnitExtra -DPFUNIT_EXTRA_INITIALIZE=get_srcdir" )
        endif ( EXISTS ${PARENT_DIR}/pFUnit/pFUnitExtra.f90.in )
      else ( PFUNIT_FOUND )
        # pFUnit 3 is used.
        # Enable use of the pFUnitArgs::get_srcdir function.
        string ( APPEND CMAKE_Fortran_FLAGS " -DPFUNIT_EXTRA_USAGE=pFUnitArgs -DPFUNIT_EXTRA_ARGS=get_srcdir" )
      endif ( PFUNIT_FOUND )
    endif ( USE_SRCDIR )
    if ( PFUNIT_FOUND )
      string ( APPEND CMAKE_Fortran_FLAGS " -DFT_PFUNIT=4" )
    endif ( PFUNIT_FOUND )
    if ( WIN )
      string ( APPEND CMAKE_EXE_LINKER_FLAGS " /MANIFEST:NO /NODEFAULTLIB:MSVCRTD" )
    elseif ( NOT USE_INTEL_FORTRAN )
      # Some of the pFUnit source files might have longer lines than 132 characters
      string ( APPEND CMAKE_Fortran_FLAGS " -ffree-line-length-256" )
      # Override the coverage compiler flags for the unit test source files themselves,
      # such that coverage results is not generated for these
      if ( PFUNIT_FOUND )
        set ( CMAKE_Fortran_FLAGS_COVERAGE "" )
      else ( PFUNIT_FOUND )
        # To avoid warning when compiling the driver.F90 file
        set ( CMAKE_Fortran_FLAGS_COVERAGE "-Wno-maybe-uninitialized" )
      endif ( PFUNIT_FOUND )
    endif ( WIN )
    include_directories ( ${PFUNIT_PATH}/include )
  endmacro ( enable_fortran_tests )

  # Wrapper for add_pfunit_test() taking care of the dependencies.
  # The option SRCDIR is used to pass the current source directory
  # to the test program when data files stored with the source are used.
  function ( add_fortran_test TEST_NAME PF_FILE )
    message ( STATUS "INFORMATION : Adding unit test from ${TEST_NAME}" )
    cmake_parse_arguments ( USE SRCDIR "" "" ${ARGN} )
    if ( USE_SRCDIR )
      if ( PFUNIT_FOUND AND EXISTS pFUnitExtra.f90 )
        # For pFUnit 4, using the configured f90-file
        set ( EXTRA_SRCS pFUnitExtra.f90 )
      elseif ( EXISTS ${PARENT_DIR}/pFUnit/pFUnitExtraArg.f90 )
        # For pFUnit 3, add the --srcdir option for passing the source directory
        set ( EXTRA_SRCS ${PARENT_DIR}/pFUnit/pFUnitExtraArg.f90 )
        set ( EXTRA_ARGS ARGS "--srcdir=${CMAKE_CURRENT_SOURCE_DIR}" )
      endif ( PFUNIT_FOUND AND EXISTS pFUnitExtra.f90 )
    else ( USE_SRCDIR )
      set ( EXTRA_SRCS "" )
    endif ( USE_SRCDIR )
    if ( PFUNIT_FOUND )   # pFUnit 4
      add_pfunit_ctest ( ${TEST_NAME} TEST_SOURCES "${PF_FILE}" OTHER_SOURCES "${EXTRA_SRCS}" "" )
    else ( PFUNIT_FOUND ) # pFUnit 3
      add_pfunit_test ( ${TEST_NAME} "${PF_FILE}" "${EXTRA_SRCS}" "" ${EXTRA_ARGS} )
    endif ( PFUNIT_FOUND )
    foreach ( DEPENDENCY ${USE_UNPARSED_ARGUMENTS} )
      target_link_libraries ( ${TEST_NAME} ${DEPENDENCY} )
    endforeach ( DEPENDENCY ${USE_UNPARSED_ARGUMENTS} )
    add_dependencies ( check ${TEST_NAME} )
  endfunction ( add_fortran_test )

endif ( pFUnit_FOUND )
