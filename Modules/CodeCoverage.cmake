# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# Functions for generation of code coverage reports.

include ( CMakeParseArguments )

# Program check
find_program ( GCOV_PATH NAMES gcov )
find_program ( LCOV_PATH NAMES lcov )
find_program ( GENHTML_PATH NAMES genhtml )
find_program ( CPPFILT_PATH NAMES c++filt )
find_program ( GCOVR_PATH NAMES gcovr HINTS $ENV{HOME}/.local/bin )

if ( GCOVR_PATH )
  # Extract the gcovr version, we need (at least) version 4.2
  execute_process ( COMMAND ${GCOVR_PATH} --version OUTPUT_VARIABLE GCOVR_OUTPUT )
  string ( REGEX MATCH "^gcovr *[1-9]+.[0-9]+.?[0-9]*" GCOVR_VERSION ${GCOVR_OUTPUT} )
  if ( "${GCOVR_VERSION}" MATCHES "gcovr" )
    string ( REGEX REPLACE "gcovr |\n" "" GCOVR_VERSION ${GCOVR_VERSION} )
    message ( STATUS "Found gcovr : ${GCOVR_PATH} version ${GCOVR_VERSION}" )
    if ( GCOVR_VERSION VERSION_LESS "4.2" )
      message ( STATUS "NOTE : Version ${GCOVR_VERSION} is too old, coverage reports will not be generated." )
      unset ( GCOVR_PATH CACHE )
    endif ( GCOVR_VERSION VERSION_LESS "4.2" )
  else ( "${GCOVR_VERSION}" MATCHES "gcovr" )
    message ( STATUS "NOTE : ${GCOVR_VERSION} can not be used, coverage reports will not be generated." )
    unset ( GCOVR_PATH CACHE )
  endif ( "${GCOVR_VERSION}" MATCHES "gcovr" )
endif ( GCOVR_PATH )

# Creating html report for code coverage with the lcov tool
function ( lcov_html_target )

  set ( options NO_DEMANGLE )
  set ( oneValueArgs BASE_DIRECTORY NAME )
  set ( multiValueArgs EXCLUDE EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES LCOV_ARGS GENHTML_ARGS )
  cmake_parse_arguments ( Coverage "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  # Set base directory
  if ( ${Coverage_BASE_DIRECTORY} )
    get_filename_component ( BASEDIR ${Coverage_BASE_DIRECTORY} ABSOLUTE )
  else ( ${Coverage_BASE_DIRECTORY} )
    set ( BASEDIR ${PROJECT_SOURCE_DIR} )
  endif ( ${Coverage_BASE_DIRECTORY} )

  set ( EXCLUDES )
  foreach ( EXCLUDE ${Coverage_EXCLUDE} )
    if ( NOT EXCLUDE MATCHES "^\\*" AND CMAKE_VERSION VERSION_GREATER 3.4 )
      # Replace by absolute path for exact matching only
      get_filename_component ( EXCLUDE ${EXCLUDE} ABSOLUTE BASE_DIR ${BASEDIR} )
    endif ( NOT EXCLUDE MATCHES "^\\*" AND CMAKE_VERSION VERSION_GREATER 3.4 )
    list ( APPEND EXCLUDES "${EXCLUDE}*" )
  endforeach ( EXCLUDE ${Coverage_EXCLUDE} )
  list ( REMOVE_DUPLICATES EXCLUDES )

  if ( CPPFILT_PATH AND NOT ${Coverage_NO_DEMANGLE} )
    set ( GENHTML_EXTRA_ARGS "--demangle-cpp" )
  endif ( CPPFILT_PATH AND NOT ${Coverage_NO_DEMANGLE} )

  if ( GCOV_PATH AND LCOV_PATH AND GENHTML_PATH )

    add_custom_target ( ${Coverage_NAME}
      # Cleanup lcov
      COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS} --gcov-tool ${GCOV_PATH} -d . -b ${BASEDIR} -z
      # Create baseline to make sure untouched files show up in the report
      COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS} --gcov-tool ${GCOV_PATH} -d . -b ${BASEDIR} -c -i -o ${Coverage_NAME}.base

      # Run the tests
      COMMAND ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}

      # Capturing lcov counters and generating report
      COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS} --gcov-tool ${GCOV_PATH} -d . -b ${BASEDIR} -c -o ${Coverage_NAME}.capture
      # Add baseline counters
      COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS} --gcov-tool ${GCOV_PATH} -a ${Coverage_NAME}.base -a ${Coverage_NAME}.capture -o ${Coverage_NAME}.total
      # Filter collected data to final coverage report
      COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS} --gcov-tool ${GCOV_PATH} -r ${Coverage_NAME}.total ${EXCLUDES} -o ${Coverage_NAME}.info

      # Generate HTML output
      COMMAND ${GENHTML_PATH} ${GENHTML_EXTRA_ARGS} ${Coverage_GENHTML_ARGS} -o ${Coverage_NAME} ${Coverage_NAME}.info

      # Set output files as GENERATED (will be removed on 'make clean')
      BYPRODUCTS ${Coverage_NAME}.base ${Coverage_NAME}.capture ${Coverage_NAME}.total ${Coverage_NAME}.info ${Coverage_NAME}
      DEPENDS ${Coverage_DEPENDENCIES}
      VERBATIM # Protect arguments to commands
      COMMENT "Reset code coverage counters to zero."
      COMMENT "Processing code coverage counters and generating report."
    )

    add_custom_command ( TARGET ${Coverage_NAME} POST_BUILD COMMAND ;
      # Show info where to find the lcov info report
      COMMENT "Code coverage info (lgov) report saved in file ${Coverage_NAME}.info." )
    add_custom_command ( TARGET ${Coverage_NAME} POST_BUILD COMMAND ;
      # Show info where to find the html report
      COMMENT "Open ./${Coverage_NAME}/index.html in your browser to view the coverage report." )

  endif ( GCOV_PATH AND LCOV_PATH AND GENHTML_PATH )

endfunction ( lcov_html_target )

# Creating code coverage reports with the gcovr tool
function ( gcovr_target )

  set ( options HTML XML SONAR ALL )
  set ( oneValueArgs BASE_DIRECTORY NAME )
  set ( multiValueArgs EXCLUDE DEPENDENCIES )
  cmake_parse_arguments ( Coverage "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  # Set base and root directories
  if ( ${Coverage_BASE_DIRECTORY} )
    get_filename_component ( BASEDIR ${Coverage_BASE_DIRECTORY} ABSOLUTE )
  else ( ${Coverage_BASE_DIRECTORY} )
    set ( BASEDIR ${PROJECT_SOURCE_DIR})
  endif ( ${Coverage_BASE_DIRECTORY} )
  set ( ROOTDIR ${CMAKE_CURRENT_BINARY_DIR} )

  # Combine excludes
  set ( EXCLUDES )
  foreach ( EXCLUDE ${Coverage_EXCLUDE} )
    if ( EXCLUDE MATCHES "^\\*" )
      # A leading asterisk means we want to filter away all files matching ${EXCLUDE}
      string ( REPLACE "*" "^.*" EXCLUDE ${EXCLUDE} )
    elseif ( CMAKE_VERSION VERSION_GREATER 3.4 )
      # Replace by absolute path for exact matching only
      get_filename_component ( EXCLUDE ${EXCLUDE} ABSOLUTE BASE_DIR ${BASEDIR} )
    endif ( EXCLUDE MATCHES "^\\*" )
    list ( APPEND EXCLUDES "${EXCLUDE}" )
  endforeach ( EXCLUDE ${Coverage_EXCLUDE} )
  list ( REMOVE_DUPLICATES EXCLUDES )
  set ( GCOVR_EXCLUDES )
  foreach ( EXCLUDE ${EXCLUDES} )
    list ( APPEND GCOVR_EXCLUDES "-e" "${EXCLUDE}" )
  endforeach ( EXCLUDE ${EXCLUDES} )

  if ( GCOVR_PATH )
    if ( ${Coverage_HTML} )

      add_custom_target ( html_${Coverage_NAME}
        # Running gcovr with html
        COMMAND ${CMAKE_COMMAND} -E make_directory ${Coverage_NAME}
        COMMAND ${GCOVR_PATH} --html ${Coverage_NAME}/index.html --html-details
                              --root ${ROOTDIR} --filter ${BASEDIR} ${GCOVR_EXCLUDES}

        BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}
        DEPENDS ${Coverage_DEPENDENCIES}
        VERBATIM # Protect arguments to commands
        COMMENT "Running gcovr to produce HTML code coverage report ..." )

      add_custom_command ( TARGET html_${Coverage_NAME} POST_BUILD COMMAND ;
        # Show - where to find the report
        COMMENT "Open ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}/index.html in your browser to view the report." )

    endif ( ${Coverage_HTML} )
    if ( ${Coverage_XML} )

      add_custom_target ( xml_${Coverage_NAME}
        # Running gcovr with xml
        COMMAND ${GCOVR_PATH} --xml ${Coverage_NAME}.xml --xml-pretty
                              --root ${ROOTDIR} --filter ${BASEDIR} ${GCOVR_EXCLUDES}

        BYPRODUCTS ${Coverage_NAME}.xml
        DEPENDS ${Coverage_DEPENDENCIES}
        VERBATIM # Protect arguments to commands
        COMMENT "Running gcovr to produce XML code coverage report ..." )

      add_custom_command ( TARGET xml_${Coverage_NAME} POST_BUILD COMMAND ;
        # Show - where to find the report
        COMMENT "Cobertura code coverage report saved in ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}.xml" )

    endif ( ${Coverage_XML} )
    if ( ${Coverage_SONAR} )

      add_custom_target ( sonar_${Coverage_NAME}
        # Running gcovr with sonarqube
        COMMAND ${GCOVR_PATH} --sonarqube ${Coverage_NAME}_sonar.xml
                              --root ${ROOTDIR} --filter ${BASEDIR} ${GCOVR_EXCLUDES}

        BYPRODUCTS ${Coverage_NAME}_sonar.xml
        DEPENDS ${Coverage_DEPENDENCIES}
        VERBATIM # Protect arguments to commands
        COMMENT "Running gcovr to produce Sonarqube code coverage report ..." )

      add_custom_command ( TARGET sonar_${Coverage_NAME} POST_BUILD COMMAND ;
        # Show - where to find the report
        COMMENT "Sonarqube code coverage report saved in ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}_sonar.xml" )

    endif ( ${Coverage_SONAR} )
    if ( ${Coverage_ALL} )

      add_custom_target ( all_${Coverage_NAME}
        # Running gcovr with sonar, xml and html output
        COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/${Coverage_NAME}
        COMMAND ${GCOVR_PATH} --sonarqube ${Coverage_NAME}_sonar.xml
                              --xml ${Coverage_NAME}.xml --xml-pretty
                              --html ${Coverage_NAME}/index.html --html-details
                              --root ${ROOTDIR} --filter ${BASEDIR} ${GCOVR_EXCLUDES}

        BYPRODUCTS ${Coverage_NAME}_sonar.xml ${Coverage_NAME}.xml ${PROJECT_BINARY_DIR}/${Coverage_NAME}
        DEPENDS ${Coverage_DEPENDENCIES}
        VERBATIM # Protect arguments to commands
        COMMENT "Creating Sonarqube, XML and HTML code coverage reports ..." )

      add_custom_command ( TARGET all_${Coverage_NAME} POST_BUILD COMMAND ;
        COMMENT "Cobertura code coverage report saved in ${Coverage_NAME}.xml" )
      add_custom_command ( TARGET all_${Coverage_NAME} POST_BUILD COMMAND ;
        COMMENT "Sonarqube code coverage report saved in ${Coverage_NAME}_sonar.xml" )
      add_custom_command ( TARGET all_${Coverage_NAME} POST_BUILD COMMAND ;
        COMMENT "Open ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}/index.html in your browser to view the report." )

    endif ( ${Coverage_ALL} )
  endif ( GCOVR_PATH )

endfunction ( gcovr_target )
