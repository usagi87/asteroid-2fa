#ifndef CONTACTMODEL_H
#define CONTACTMODEL_H

#include <QObject>

class TwoFactor : public QObject
{	  
    Q_OBJECT
public:
    Q_INVOKABLE static int getCode(QString key);
    
};

#endif
