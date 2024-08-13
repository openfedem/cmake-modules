# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# Notice: The VTF API library is an old version of Ceetron's
# library for writing VTF files for visualization in GLview.
# Although it is not an open source module, we maintain the
# coupling to it through this Find rule.
# If you should have a need for it, please contact someone in
# the Open Fedem team (https://openfedem.org/developer_area/)
# and we'll see what we can do about it.

unset ( VTF_INCLUDE CACHE )
unset ( VTF_LIBRARY CACHE )

find_path ( VTF_INCLUDE
            NAMES VTFAPI.h
            PATHS C:/VTFAPI/include
            ${HOME}/.local/include /usr/local/include
          )

if ( VTF_INCLUDE )
  message ( STATUS "Found VTF API: ${VTF_INCLUDE}" )
  find_library ( VTF_LIBRARY
                 NAMES VTFExpressAPI
                 PATHS C:/VTFAPI/lib ${HOME}/.local/lib /usr/local/lib
               )
endif ( VTF_INCLUDE )

if ( VTF_LIBRARY )
  message ( STATUS "Found VTF API: ${VTF_LIBRARY}" )
  include_directories ( ${VTF_INCLUDE} )
  string ( APPEND CMAKE_CXX_FLAGS " -DFT_HAS_VTF" )
else ( VTF_LIBRARY )
  message ( WARNING "Did NOT find VTF API library, configuring without it." )
endif ( VTF_LIBRARY )
