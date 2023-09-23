#ifndef VAULT_H
#define VAULT_H

#include <QObject>

#include <twofactor.h>

class Vault : public QObject
{	  
    Q_OBJECT
public:
	
	Q_INVOKABLE QString readDatabase(QString password);
	
	Q_INVOKABLE bool saveDatabase(QString password, QString db, int len);
	
	Q_INVOKABLE QString readData(QString data);	
	
	Q_INVOKABLE std::string saveData(QString data,int len);
	
	Q_INVOKABLE std::string hex2int(std::string hex);
	
	Q_INVOKABLE std::string int2hex(std::string text);
		
		
};

#endif
