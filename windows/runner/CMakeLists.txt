cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)
if(CMAKE_GENERATOR_PLATFORM MATCHES "ARM64|Win32")
  message(FATAL_ERROR "The bundled exam OCR runtime requires a Windows x64 build.")
endif()

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "exam_ocr_channel.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

apply_standard_settings(${BINARY_NAME})
get_target_property(RUNNER_DEFINITIONS ${BINARY_NAME} COMPILE_DEFINITIONS)
list(REMOVE_ITEM RUNNER_DEFINITIONS "_HAS_EXCEPTIONS=0")
set_property(TARGET ${BINARY_NAME} PROPERTY COMPILE_DEFINITIONS ${RUNNER_DEFINITIONS})
target_compile_definitions(${BINARY_NAME} PRIVATE "_HAS_EXCEPTIONS=1")

target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib" "windowsapp.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

add_dependencies(${BINARY_NAME} flutter_assemble)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${CMAKE_CURRENT_SOURCE_DIR}/../ocr"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/ocr"
)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../ocr"
  DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
