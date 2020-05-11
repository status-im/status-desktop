SQLCipher - Nim / NOTES
===


This will compile sqlcipher. It assumes `libssl-dev` is installed in the OS, and will do a dynamic linking: the final user will have to install openssl before. This needs to be adapted for static linking to avoid this requirement. 
There are some implications: gclib should be installed in the OS that will run the static linked. This is probably an non-issue. Ubuntu is providing this lib since 2013. It might be the same for other OSs
```
git clone https://github.com/sqlcipher/sqlcipher.git

cd sqlcipher/
./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
make sqlite3.c

cp sqlite3.* ../.
cd ..
```

This copies sqlite3.c and sqlite3.h to this folder, I tried to use [c2nim](https://github.com/nim-lang/c2nim) to generate a small wrapper for SQL but I wasn't successful. Someone please try this approach. I ended up using https://github.com/GULPF/tiny_sqlite/blob/master/src/tiny_sqlite/sqlite_wrapper.nim adapted for static linking.

```
gcc -lpthread -DSQLITE_HAS_CODEC -lcrypto -c sqlite3.c
```


