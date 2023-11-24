# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

#################### CMAKE FUNCTION DEFINITIONS ################################

function ( do_install TARGET_LIST ROOT_DIR )

  # Install all targets in TARGET_LIST to the ROOT_DIR folder.
  # Optionally under sub-folders if DOMAIN_HOLDER and PACKAGE_HOLDER
  # are provided as additional arguments.
  # Targets are executables, shared object libraries and static libraries.

  if ( ${ARGC} GREATER 3 )
    set ( LOCALPATH "${ROOT_DIR}/${ARGV2}/${ARGV3}" )
  elseif ( ${ARGC} GREATER 2 )
    set ( LOCALPATH "${ROOT_DIR}/${ARGV2}" )
  else ( ${ARGC} GREATER 3 )
    set ( LOCALPATH "${ROOT_DIR}" )
  endif ( ${ARGC} GREATER 3 )

  if ( FTENV_VERBOSE )
    message ( STATUS "INSTALLING targets ${TARGET_LIST} to ${LOCALPATH}" )
  endif ( FTENV_VERBOSE )

  foreach ( TARGET_ID ${TARGET_LIST} )
    if ( WIN )
      install_targets ( /${LOCALPATH}/lib
      RUNTIME_DIRECTORY /${LOCALPATH}/bin ${TARGET_ID} )
    else ( WIN )
      install ( TARGETS ${TARGET_ID}
                RUNTIME DESTINATION ${LOCALPATH}/bin
                LIBRARY DESTINATION ${LOCALPATH}/lib
                ARCHIVE DESTINATION ${LOCALPATH}/lib
               )
    endif ( WIN )
  endforeach ( TARGET_ID ${TARGET_LIST} )

endfunction ( do_install )

#################### END FUNCTION DEFINITIONS ##################################
