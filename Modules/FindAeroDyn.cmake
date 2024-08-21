# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# This Find rule sets up for building the FEDEM dynamics solver with
# AeroDyn v13 from NREL (https://www.nrel.gov/wind/nwtc/aerodyn.html).
# The AeroDyn module is not part of the Open FEDEM project itself.
# Please contact developers@openfedem.org if you want to try out
# the wind turbine simulation capabilities with FEDEM and AeroDyn.

unset ( AeroDyn_INCLUDE CACHE )
unset ( AeroDyn_LIBRARY CACHE )
unset ( AeroDyn_DLL CACHE )
unset ( TURBSIM CACHE )

find_path ( AeroDyn_INCLUDE
            NAMES aerodyn.mod
            PATHS C:/NREL/include $ENV{NREL_HOME}/include
            ${HOME}/.local/include /usr/local/include
          )

if ( AeroDyn_INCLUDE )
  message ( STATUS "Found AeroDyn: ${AeroDyn_INCLUDE}" )
  find_library ( AeroDyn_LIBRARY
                 NAMES AeroDyn
                 PATHS C:/NREL/lib $ENV{NREL_HOME}/lib
                 ${HOME}/.local/lib /usr/local/lib
               )
endif ( AeroDyn_INCLUDE )

if ( AeroDyn_LIBRARY )
  if ( WIN )
    find_file ( AeroDyn_DLL
                NAMES AeroDyn.dll
                PATHS C:/NREL/bin $ENV{NREL_HOME}/bin
                ${HOME}/.local/bin /usr/local/bin
                NO_DEFAULT_PATH
              )
    message ( STATUS "Found AeroDyn: ${AeroDyn_LIBRARY} ${AeroDyn_DLL}" )
  else ( WIN )
    message ( STATUS "Found AeroDyn: ${AeroDyn_LIBRARY}" )
  endif ( WIN )
  include_directories ( ${AeroDyn_INCLUDE} )
  string ( APPEND CMAKE_Fortran_FLAGS " -DFT_HAS_AERODYN=13" )
  find_program ( TURBSIM
                 NAMES TurbSim
                 PATHS C:/NREL/bin $ENV{NREL_HOME}/bin
                 ${HOME}/.local/bin /usr/local/bin
                 NO_DEFAULT_PATH
               )
  if ( TURBSIM )
    message ( STATUS "Found TurbSim: ${TURBSIM}" )
  endif ( TURBSIM )
else ( AeroDyn_LIBRARY )
  message ( WARNING "Did NOT find AeroDyn library, configuring without it." )
endif ( AeroDyn_LIBRARY )
