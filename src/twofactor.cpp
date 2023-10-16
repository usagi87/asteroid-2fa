#include <twofactor.h>
#include "libcppotp/otp.h"
#include "libcppotp/bytes.h"
#include <iostream>
#include <string>
#include <cstdlib>

using namespace std;

using namespace CppTotp;


string normalizedBase32String(const string & unnorm)
{
	string ret;

	for (char c : unnorm)
	{
		if (c == ' ' || c == '\n' || c == '-')
		{
			// skip separators
		}
		else if (islower(c))
		{
			// make uppercase
			char u = toupper(c);
			ret.push_back(u);
		}
		else
		{
			ret.push_back(c);
		}
	}
	return ret;
}


int TwoFactor::getCode(QString key) {
    string normalizedKey = normalizedBase32String(key.toStdString());
    Bytes::ByteString qui = Bytes::fromUnpaddedBase32(normalizedKey);
    return totp(qui, time(NULL), 0, 30, 6);
}









