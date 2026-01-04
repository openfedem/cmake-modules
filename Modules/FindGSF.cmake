# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# This Find rule sets up for building the FEDEM solvers with
# the GSF linear equation solver with out-of-core capabilities from DNVS.
# The GSF module is not part of the Open FEDEM project itself.
# Please contact developers@openfedem.org if you want to try it out.

unset ( GSF_INCLUDE CACHE )
unset ( GSF_LIBRARY CACHE )
unset ( GSF_DLL CACHE )

find_path ( GSF_INCLUDE
            NAMES felinearsolver.mod
            PATHS C:/DNVS/include $ENV{DNVS_HOME}/include
            ${HOME}/.local/include /usr/local/include
          )

if ( GSF_INCLUDE )
  message ( STATUS "Found GSF: ${GSF_INCLUDE}" )
  find_library ( GSF_LIBRARY
                 NAMES GSF
                 PATHS C:/DNVS/lib $ENV{DNVS_HOME}/lib
                 ${HOME}/.local/lib /usr/local/lib
               )
endif ( GSF_INCLUDE )

if ( GSF_LIBRARY )
  if ( WIN )
    find_file ( GSF_DLL
                NAMES GSF.dll
                PATHS C:/DNVS/bin $ENV{DNVS_HOME}/bin
                ${HOME}/.local/bin /usr/local/bin
                NO_DEFAULT_PATH
              )
    message ( STATUS "Found GSF: ${GSF_LIBRARY} ${GSF_DLL}" )
  else ( WIN )
    message ( STATUS "Found GSF: ${GSF_LIBRARY}" )
  endif ( WIN )
  include_directories ( ${GSF_INCLUDE} )
else ( GSF_LIBRARY )
  message ( WARNING "Did NOT find GSF library, configuring without it." )
endif ( GSF_LIBRARY )
