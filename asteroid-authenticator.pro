TARGET = asteroid-authenticator
CONFIG += asteroidapp 
CONFIG += qzxing_qml

SOURCES +=	main.cpp \
	arduinolibs/libraries/Crypto/Crypto.cpp \
    arduinolibs/libraries/Crypto/AES256.cpp \
    arduinolibs/libraries/Crypto/AESCommon.cpp \
    arduinolibs/libraries/Crypto/BlockCipher.cpp \
	arduinolibs/libraries/Crypto/Cipher.cpp \
	arduinolibs/libraries/Crypto/CTR.cpp \
    arduinolibs/libraries/Crypto/HKDF.cpp \
    arduinolibs/libraries/Crypto/Hash.cpp \
    arduinolibs/libraries/Crypto/SHA256.cpp \
    arduinolibs/libraries/Crypto/BLAKE2b.cpp \
    libcppotp/bytes.cpp \
    libcppotp/otp.cpp \
    libcppotp/sha1.cpp \
    qrcode/qrcodegen.cpp \
    twofactor.cpp \
    vault.cpp \
    crypt.cpp \
    qrcode.cpp
    
    
    

RESOURCES +=   resources.qrc
OTHER_FILES += main.qml  


lupdate_only{ SOURCES += i18n/asteroid-authenticator.desktop.h }
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)

HEADERS += \
	arduinolibs/libraries/Crypto/Crypto.h \
	arduinolibs/libraries/Crypto/AES.h \
	arduinolibs/libraries/Crypto/BlockCipher.h \
	arduinolibs/libraries/Crypto/Cipher.h \
	arduinolibs/libraries/Crypto/CTR.h \
	arduinolibs/libraries/Crypto/HKDF.h \
	arduinolibs/libraries/Crypto/SHA256.h \
	arduinolibs/libraries/Crypto/Hash.h \
	arduinolibs/libraries/Crypto/BLAKE2b.h \
	libcppotp/bytes.h \
    libcppotp/otp.h \
    libcppotp/sha1.h \
    qrcode/qrcodegen.h \
    twofactor.h \
    vault.h \
    crypt.h \
    qrcode.h

include(QZXing/QZXing.pri)    
    
CONFIG += qmltypes
QML_IMPORT_NAME = com.asteroidos.authenticator
QML_IMPORT_MAJOR_VERSION = 1


