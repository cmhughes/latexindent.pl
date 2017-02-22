cmake_minimum_required(VERSION 2.8)
project(latexindent)

install(PROGRAMS ../latexindent.pl
        DESTINATION bin)

install(FILES ../defaultSettings.yaml
        DESTINATION bin)

install(DIRECTORY ../LatexIndent
        DESTINATION bin)

# uninstall target
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
