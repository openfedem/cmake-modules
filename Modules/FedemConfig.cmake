# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

###############################################
# General cmake configuration setup for FEDEM #
###############################################

set ( WIN NO )
set ( LINUX NO )
if ( WIN32 OR WIN64 )
  set ( WIN YES )
elseif ( UNIX )
  set ( LINUX YES )
endif ( WIN32 OR WIN64 )

# Define some optional configuration settings

option ( FTENV_VERBOSE "Enable more output during Configure" OFF )
option ( FTENV_WARNINGS "Enable extra compiler warnings" ON )
option ( BUILD_TESTS "Build and execute unit/regression tests" ON )

option ( PLATFORM_BITSIZE_IS_64_BIT "Use default bitsize of 64 bit" ON )
mark_as_advanced ( PLATFORM_BITSIZE_IS_64_BIT )
if ( LINUX )
  option ( USE_INTEL_FORTRAN "Use the Intel Fortran compiler" OFF )
  mark_as_advanced ( USE_INTEL_FORTRAN )
else ( LINUX )
  set ( USE_INTEL_FORTRAN ON )
endif ( LINUX )

# Platform dependent compiler setup

if ( FTENV_WARNINGS )
  set ( GCC_FLAGS "-fPIC -Wall -Wextra" )
else ( FTENV_WARNINGS )
  set ( GCC_FLAGS "-fPIC" )
endif ( FTENV_WARNINGS )

set ( UNIX_GFORTRAN_COMPILER_FLAGS "-cpp -frecursive -fwhole-file ${GCC_FLAGS}" )
set ( UNIX_IFORT_COMPILER_FLAGS    "-nologo -libs:dll -fpp -threads" )
set ( WIN_IFORT_COMPILER_FLAGS     "/nologo /libs:dll /fpp /threads /guard:cf /GS /Qdiag-disable:10448" )
set ( WIN_C_COMPILER_FLAGS         "/Zc:wchar_t /guard:cf /GS /EHsc /MD" )

if ( USE_INTEL_FORTRAN )
  set ( UNIX_FORTRAN_COMPILER_FLAGS "${UNIX_IFORT_COMPILER_FLAGS}" )
else ( USE_INTEL_FORTRAN )
  set ( UNIX_FORTRAN_COMPILER_FLAGS "${UNIX_GFORTRAN_COMPILER_FLAGS}" )
endif ( USE_INTEL_FORTRAN )

if ( FTENV_WARNINGS AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.0 )
  string ( APPEND GCC_FLAGS " -Wimplicit-fallthrough=0" )
endif ( FTENV_WARNINGS AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 7.0 )

if ( PLATFORM_BITSIZE_IS_64_BIT )
  set ( WIN_FORTRAN_COMPILER_FLAGS  "${WIN_IFORT_COMPILER_FLAGS} /Dwin64" )
  set ( WIN_C_COMPILER_FLAGS        "${WIN_C_COMPILER_FLAGS} /Dwin64" )
  set ( UNIX_FORTRAN_COMPILER_FLAGS "${UNIX_FORTRAN_COMPILER_FLAGS} -Dlinux64" )
  set ( UNIX_C_COMPILER_FLAGS       "${GCC_FLAGS} -Dlinux64" )
else ( PLATFORM_BITSIZE_IS_64_BIT )
  set ( WIN_FORTRAN_COMPILER_FLAGS  "${WIN_IFORT_COMPILER_FLAGS} /Dwin32" )
  set ( WIN_C_COMPILER_FLAGS        "${WIN_C_COMPILER_FLAGS} /Dwin32" )
  set ( UNIX_FORTRAN_COMPILER_FLAGS "${UNIX_FORTRAN_COMPILER_FLAGS} -Dlinux" )
  set ( UNIX_C_COMPILER_FLAGS       "${GCC_FLAGS} -Dlinux" )
endif ( PLATFORM_BITSIZE_IS_64_BIT )

if ( LINUX )
  set ( _Fortran_FLAGS ${UNIX_FORTRAN_COMPILER_FLAGS} )
  set ( _C_FLAGS       ${UNIX_C_COMPILER_FLAGS} )
  if ( USE_INTEL_FORTRAN )
    set ( _CXX_FLAGS   ${UNIX_C_COMPILER_FLAGS} )
  else ( USE_INTEL_FORTRAN )
    # These flags apply for the GNU compilers only
    set ( _CXX_FLAGS     "${UNIX_C_COMPILER_FLAGS}" )
    set ( _F_FLAGS_DEBUG "-g -fcheck=all" )
    set ( _C_FLAGS_DEBUG "-g" )
    set ( _C_FLAGS_COV   "--coverage" )
  endif ( USE_INTEL_FORTRAN )
  set ( CMAKE_PATH_SEP ":" )
elseif ( WIN )
  set ( _Fortran_FLAGS ${WIN_FORTRAN_COMPILER_FLAGS} )
  set ( _C_FLAGS       ${WIN_C_COMPILER_FLAGS} )
  set ( _CXX_FLAGS     ${WIN_C_COMPILER_FLAGS} )
  set ( _F_FLAGS_DEBUG "/Od /debug:full /dbglibs" )
  set ( _C_FLAGS_DEBUG "/Od /Zi /RTC1" )
  set ( _LINKER_FLAGS  "/guard:cf" )
  set ( CMAKE_PATH_SEP "\\;" )
endif ( LINUX )

set ( FT_DEBUG 1 CACHE STRING "Flag for additional debug output (more output the higher value)" )

set ( CMAKE_Fortran_FLAGS        ${_Fortran_FLAGS} CACHE STRING "Flags needed for Fortran compiler" FORCE )
set ( CMAKE_C_FLAGS              ${_C_FLAGS}       CACHE STRING "Flags needed for C compiler" FORCE )
set ( CMAKE_CXX_FLAGS            ${_CXX_FLAGS}     CACHE STRING "Flags needed for C++ compiler" FORCE )

set ( CMAKE_Fortran_FLAGS_DEBUG "${_F_FLAGS_DEBUG} -DFT_DEBUG=${FT_DEBUG}"               CACHE STRING "Debug flags for Fortran compiler" FORCE )
set ( CMAKE_C_FLAGS_DEBUG       "${_C_FLAGS_DEBUG}"                                      CACHE STRING "Debug flags for C compiler" FORCE )
set ( CMAKE_CXX_FLAGS_DEBUG     "${_C_FLAGS_DEBUG} -DFT_DEBUG=${FT_DEBUG} -DFFA_DEBUG=1" CACHE STRING "Debug flags for C++ compiler" FORCE )

if ( WIN )

  set ( CMAKE_EXE_LINKER_FLAGS "${_LINKER_FLAGS}" CACHE STRING "Flags needed for linker" FORCE )

elseif ( NOT USE_INTEL_FORTRAN )

  # Set flags for the Coverage build type on Linux/gcc
  set ( CMAKE_Fortran_FLAGS_COVERAGE ${_C_FLAGS_COV} CACHE STRING "Coverage flags for Fortran compiler" FORCE )
  set ( CMAKE_C_FLAGS_COVERAGE       ${_C_FLAGS_COV} CACHE STRING "Coverage flags for C compiler" FORCE )
  set ( CMAKE_CXX_FLAGS_COVERAGE     ${_C_FLAGS_COV} CACHE STRING "Coverage flags for C++ compiler" FORCE )

  set ( CMAKE_EXE_LINKER_FLAGS_COVERAGE    ${_C_FLAGS_COV}                      CACHE STRING "Coverage flags for linker" FORCE )
  set ( CMAKE_MODULE_LINKER_FLAGS_COVERAGE ${CMAKE_MODULE_LINKER_FLAGS_RELEASE} CACHE STRING "Coverage flags for linker" FORCE )
  set ( CMAKE_SHARED_LINKER_FLAGS_COVERAGE ${CMAKE_SHARED_LINKER_FLAGS_RELEASE} CACHE STRING "Coverage flags for linker" FORCE )
  set ( CMAKE_STATIC_LINKER_FLAGS_COVERAGE ${CMAKE_STATIC_LINKER_FLAGS_RELEASE} CACHE STRING "Coverage flags for linker" FORCE )

endif ( WIN )

# Enforce the C++17 language standard
set ( CMAKE_CXX_STANDARD 17 )
set ( CMAKE_CXX_STANDARD_REQUIRED ON )
