#ifndef EXPORT_H
#define EXPORT_H

#include <QObject>
#include "qrcodegen.hpp"

class QRCode : public QObject
{	  
    Q_OBJECT
public:
	
	Q_INVOKABLE void generateQRCode();
	Q_INVOKABLE std::string toSvgString(const qrcodegen::QrCode &qr, int border);
	Q_INVOKABLE void generateQRCodeTest();	
		
		
};

#endif
