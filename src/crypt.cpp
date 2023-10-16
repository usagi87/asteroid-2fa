#include <crypt.h>
#include <iostream>
#include <sstream>
#include <QRandomGenerator>
#include <cstdlib>

#include "scrypt-kdf.h"
#include <libraries/Crypto/Crypto.h>
#include <libraries/Crypto/AES.h>
#include <libraries/Crypto/CTR.h>
#include <libraries/Crypto/Cipher.h>
#include <libraries/Crypto/SHA256.h>
#include <libraries/Crypto/HKDF.h>
#include <libraries/Crypto/BLAKE2b.h>

using namespace std;

Crypt::Crypt(){
salt_ = generateIV();
tag_ = generateIV();
nonce_ = generateIV();

}

string Crypt::scrypt(string password){
	
	const char * passwd = password.c_str();
	const char * salt = salt_.c_str();
	
	int N = 65536;
	int r = 8;
	int p = 1;
	
	int OUTPUT_BUFLEN = 64;
	uint8_t output[OUTPUT_BUFLEN];
	int exitcode;
	
	exitcode = scrypt_kdf((const uint8_t *)passwd, strlen(passwd),
	    (const uint8_t*)salt, strlen(salt), N, r, p,
	    output, OUTPUT_BUFLEN);
	string str = (char *) output;
	string tmp = "";
	for (int i=0;i<32;++i){
		tmp += str[i];
	}
	
	return tmp;
}

string Crypt::generateKey(string p){
	uint8_t plen = p.size();
	uint8_t password[plen]; 
	for(int i=0;i<plen;++i) password[i] = (uint8_t)p[i]; 
	
	uint8_t slen = salt_.size();
	uint8_t salt[slen]; 	
	for (int i=0;i<slen;++i) salt[i] = (uint8_t)salt_[i];
	
	uint8_t tlen = tag_.size();
	uint8_t tag[tlen]; 	
	for (int i=0;i<tlen;++i) tag[i] = (uint8_t)tag_[i]; 
	
	uint8_t klen = 32;
	uint8_t key[klen];
	
	
	HKDF<BLAKE2b> hkdf;

    hkdf.setKey(password, plen, salt, slen);
    hkdf.extract(key,klen,tag,tlen);
	
	string passwd = "";
	for(int i=0;i<klen;++i) passwd += key[i];
	
	return passwd;
}


string Crypt::encrypt(string data,string password){
	uint8_t klen = 32;
	uint8_t key[klen];
	for(int i=0;i<klen;++i) key[i] = (uint8_t)password[i]; 
	
    uint8_t ilen = 16;
    uint8_t iv[ilen];
    for(int i=0;i<ilen;++i) iv[i] = (uint8_t)nonce_[i];
    
    int slen = data.size();
    uint8_t txt[slen];
	uint8_t cypher[slen];
	for(int i=0;i<slen;++i)	txt[i] = (uint8_t)data[i];
   	
  	CTR<AES256> ctx;
  	ctx.clear();
	ctx.setKey(key, 32);
	ctx.setIV(iv, 16);
	
	int len = 0;
    int inc = 1;
	
    for (int posn = 0; posn < slen; posn += inc) {
        len = slen - posn;
        if (len > inc)
            len = inc;
        ctx.encrypt(cypher + posn, txt + posn, len);
    }
     
    data = "";
	
	for (int i=0;i<slen;++i){
 		data += cypher[i];
	}

 	return data;
	
}

string Crypt::decrypt(string data,string password){
	uint8_t klen = 32;
	uint8_t key[klen];
	for(int i=0;i<klen;++i) key[i] = (uint8_t)password[i]; 
	
    uint8_t ilen = 16;
    uint8_t iv[ilen]; 
    for(int i=0;i<ilen;++i) iv[i] = (uint8_t)nonce_[i];
    
    int slen = data.size();
    uint8_t txt[slen];
	uint8_t cypher[slen];
   
	for(int i=0;i<slen;++i){
		cypher[i] = (uint8_t)data[i];
	}
   
    CTR<AES256> ctx;
    ctx.clear();
    ctx.setKey(key, 32);
	ctx.setIV(iv, 16);
	
	int len = 0;
    int inc = 1;
	
    for (int posn = 0; posn < slen; posn += inc) {
        len = slen - posn;
        if (len > inc)
            len = inc;
        ctx.decrypt(txt + posn, cypher + posn, len);
    }
    data = ""; 
    for (int i=0;i<slen;++i){
 		data += txt[i];
	}

	return data;
	
}

string Crypt::generateIV(){
	quint64 seed1 =  QRandomGenerator::securelySeeded().generate64();
	quint64 seed2 =  QRandomGenerator::securelySeeded().generate64(); 
	
	string str = "";
	for (int i=0;i<8;++i){
		uint8_t tmp = seed1 >> i*8;
		str += (char)tmp;
	}
	for (int i=0;i<8;++i){
		uint8_t tmp = seed2 >> i*8;
		str += (char)tmp;
	}
	
	return str;	
}

string Crypt::getSalt(){
	return salt_;
}

string Crypt::getTag(){
	return tag_;
}

string Crypt::getNonce(){
	return nonce_;
}

void Crypt::setSalt(string salt){
	salt_ = salt;
}

void Crypt::setTag(string tag){
	tag_ = tag;
}

void Crypt::setNonce(string nonce){
	nonce_ = nonce;
}
