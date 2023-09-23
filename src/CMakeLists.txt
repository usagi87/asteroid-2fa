add_library(${CMAKE_PROJECT_NAME} main.cpp resources.qrc
    crypt.cpp
    main.cpp
    qrcode.cpp
    twofactor.cpp
    vault.cpp
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${qrcodeDir} ${scryptDir}/lib-platform ${scryptDir}/libscrypt-kdf)
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE ${qrcodeLinkDir} ${scryptLinkDir})

target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    QZXING_QML 
    ENABLE_ENCODER_GENERIC
    QMLTYPES
)

target_include_directories (qzxing 
    PUBLIC "${qzxing_SOURCE_DIR}/src"
)

set(ARD "${arduinolibs_SOURCE_DIR}/libraries/Crypto/")

add_library(arduinolibs SHARED 
    ${ARD}/Crypto.cpp
    ${ARD}/AES256.cpp
    ${ARD}/AESCommon.cpp
    ${ARD}/BlockCipher.cpp
    ${ARD}/Cipher.cpp
    ${ARD}/CTR.cpp
    ${ARD}/HKDF.cpp
    ${ARD}/Hash.cpp
    ${ARD}/SHA256.cpp
    ${ARD}/BLAKE2b.cpp
)

target_include_directories (arduinolibs 
    PUBLIC "${arduinolibs_SOURCE_DIR}"
)

set(OTP "${cpptotp_SOURCE_DIR}/src/libcppotp")
add_library(cpptotp SHARED
    ${OTP}/bytes.cpp 
    ${OTP}/otp.cpp
    ${OTP}/sha1.cpp
)

target_include_directories (${CMAKE_PROJECT_NAME}
    PUBLIC "${cpptotp_SOURCE_DIR}/src"
)

target_link_libraries(${CMAKE_PROJECT_NAME} 
    PUBLIC
	AsteroidApp
    PRIVATE
        arduinolibs
        cpptotp
        qzxing
        scrypt-kdf
    INTERFACE
        qrcodegencpp
)

install(TARGETS ${CMAKE_PROJECT_NAME} arduinolibs cpptotp qzxing
       DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES "${scryptLinkDir}/libscrypt-kdf.so.1.0.0" TYPE LIB)
