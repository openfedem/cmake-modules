# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# Detects if a valid pFUnit installation exists.
# The environment variable PFUNIT is used as a hint.

find_path ( PFUNIT_PATH
            NAMES pFUnitConfig.cmake PFUNITConfig.cmake
            PATHS "$ENV{PFUNIT}" "$ENV{PFUNIT}/cmake"
          )

if ( PFUNIT_PATH )
  if ( LINUX )
    list ( APPEND CMAKE_MODULE_PATH ${PFUNIT_PATH} )
  else ( LINUX )
    list ( APPEND CMAKE_PREFIX_PATH ${PFUNIT_PATH} )
  endif ( LINUX )
  # Change to parent directory, if we found a cmake-folder
  if ( PFUNIT_PATH MATCHES "cmake$" )
    get_filename_component ( PFUNIT_PATH "${PFUNIT_PATH}" PATH )
  endif ( PFUNIT_PATH MATCHES "cmake$" )
endif ( PFUNIT_PATH )
