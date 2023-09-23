#ifndef CRYPT_H
#define CRYPT_H

#include <QObject>

class Crypt : public QObject
{	  
    Q_OBJECT
public:

	Q_INVOKABLE Crypt();
	
	Q_INVOKABLE std::string decrypt(std::string data,std::string password);
	
	Q_INVOKABLE std::string encrypt(std::string data,std::string passsword);
	
	Q_INVOKABLE std::string generateKey(std::string p);
	
	Q_INVOKABLE	std::string scrypt(std::string password);
	
	Q_INVOKABLE std::string generateIV();
	
	Q_INVOKABLE std::string getSalt();
	Q_INVOKABLE std::string getTag();
	Q_INVOKABLE std::string getNonce();
	
	Q_INVOKABLE void setSalt(std::string salt);
	Q_INVOKABLE void setTag(std::string tag);
	Q_INVOKABLE void setNonce(std::string nonce);
	
private:

std::string salt_;
std::string tag_;
std::string nonce_;	
		
};

#endif
