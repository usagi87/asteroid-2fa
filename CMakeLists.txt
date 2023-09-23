cmake_minimum_required(VERSION 3.20)

project(asteroid-authenticator
	VERSION 1.0.0
	DESCRIPTION "Two-factor authenticator for AsteroidOS")

cmake_policy(SET CMP0065 NEW)
include(FetchContent)
include(ExternalProject)
include(GNUInstallDirs)

FetchContent_Declare(
  arduinolibs
  GIT_REPOSITORY  https://github.com/rweather/arduinolibs.git
  GIT_TAG         1e13ef7b244caaa1b9151d5e41c4cdb029f4ea84
)

set(QZXING_USE_QML ON)
set(QZXING_USE_ENCODER ON)

FetchContent_Declare(
  qzxing
  GIT_REPOSITORY  https://github.com/ftylitak/qzxing.git
  GIT_TAG         641da3618b3c3e386d32c70a208a49df72839c0a
  SOURCE_SUBDIR   src
)

FetchContent_Declare(
  cpptotp
  GIT_REPOSITORY  https://github.com/RavuAlHemio/cpptotp.git
  GIT_TAG         696f618aec5c97970dd0948fef11cf46f7dfa255 
)

ExternalProject_Add(
  qrcode
  GIT_REPOSITORY  https://github.com/nayuki/QR-Code-generator.git
  GIT_TAG         49a66a2b8bb8f8852fd2e1deb00b8672f5760139
  CONFIGURE_COMMAND ""
  BUILD_COMMAND   VPATH=<SOURCE_DIR>/cpp $(MAKE) -f <SOURCE_DIR>/cpp/Makefile
  INSTALL_COMMAND ""
)

ExternalProject_Add(
  scrypt
  GIT_REPOSITORY  https://github.com/Tarsnap/scrypt.git
  GIT_TAG         81abc2a92bd3c1104925fd85185eacd2b179e6ab
  CONFIGURE_COMMAND autoreconf --install <SOURCE_DIR>
  COMMAND <SOURCE_DIR>/configure --host=arm-oe-linux-gnueabi --enable-libscrypt-kdf --prefix=<INSTALL_DIR>
  BUILD_COMMAND    $(MAKE) --quiet
  INSTALL_COMMAND  $(MAKE) --quiet install-libLTLIBRARIES
)

FetchContent_MakeAvailable(arduinolibs qzxing cpptotp)
ExternalProject_Get_Property(qrcode SOURCE_DIR)
set(qrcodeDir ${SOURCE_DIR}/cpp)
ExternalProject_Get_Property(qrcode BINARY_DIR)
set(qrcodeLinkDir ${BINARY_DIR})
ExternalProject_Get_Property(scrypt SOURCE_DIR)
set(scryptDir ${SOURCE_DIR})
ExternalProject_Get_Property(scrypt INSTALL_DIR)
set(scryptLinkDir ${INSTALL_DIR}/lib)

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(ECMFindQmlModule)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

add_subdirectory(src)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/runscript.in
	${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}
	@ONLY)

install(PROGRAMS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}
	DESTINATION ${CMAKE_INSTALL_BINDIR})

generate_desktop(${CMAKE_SOURCE_DIR} ${CMAKE_PROJECT_NAME})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CMAKE_INSTALL_SO_NO_EXE 0 CACHE INTERNAL "Install .so files with execute permission.")
set(CPACK_GENERATOR "DEB")
string(TOLOWER "${CMAKE_PROJECT_NAME}" lcproject_name)
set(CPACK_DEBIAN_FILE_NAME "${lcproject_name}-${CMAKE_PROJECT_VERSION}.ipk")
set(CPACK_STRIP_FILES TRUE)
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE armv7vehf-neon)
if (NOT CPACK_PACKAGE_CONTACT) 
    set(CPACK_PACKAGE_CONTACT bogus@example.org)
    message(WARNING "No package contact specified: using ${CPACK_PACKAGE_CONTACT}")
endif()
include(CPack)
