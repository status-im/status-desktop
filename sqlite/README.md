SQLCipher - Nim / NOTES
===

**Notes:**
This is a experimental project to test how to use SQLCipher with Nim. I tried to use [c2nim](https://github.com/nim-lang/c2nim) to generate a small wrapper for SQLite using the header file generated during the SQLCipher compilation process but I wasn't successful. Someone please try using that software to see if it works for them

[Tiny_SQLite](https://github.com/GULPF/tiny_sqlite/blob/master/src/tiny_sqlite/sqlite_wrapper.nim) that already provides a wrapper for SQLite. It assumes SQLite is dynamically linked. I changed it to static linking so I can use it with SQLCipher and added new functions.

```nim
# In sqlite_wrapper.nim
proc key*(db: PSqlite3, pKey: cstring, nKey: int32): int32{.cdecl, importc: "sqlite3_key".}
proc rekey*(db: PSqlite3, pKey: cstring, nKey: int32): int32{.cdecl, importc: "sqlite3_rekey".}

# In tiny_sqlite.nim
proc key*(db: DbConn, password: string) =
    let rc = sqlite.key(db, password, int32(password.len))
    db.checkRc(rc)

proc rekey*(db: DbConn, password: string) =
    let rc = sqlite.rekey(db, password, int32(password.len))
    db.checkRc(rc)

```

We can either fork this library, or create a new .nim file with the required functions, and use Tiny_SQLite along with the SQLCipher specific functions. Docs for Tiny_SQLite are available here: https://gulpf.github.io/tiny_sqlite/tiny_sqlite.html


### Statically Linked OpenSSL

There are some implications: gclib should be installed in the OS that will run the static linked. This is probably an non-issue. Ubuntu is providing this lib since 2013. It might be the same for other operative systems

```
rm -rf lib
mkdir lib


# Compiling libcrypto.o
wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxvf openssl-1.1.1g.tar.gz
rm openssl-1.1.1g.tar.gz
cd openssl-1.1.1g/
./config -shared
make -j`nproc`
cp libcrypto.a ../lib/.
cd ..
rm -rf openssl-1.1.1g/


# Generating sqlite3.c
git clone https://github.com/sqlcipher/sqlcipher.git
cd sqlcipher/
./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="../lib/libcrypto.a"
make sqlite3.c
cp sqlite3.c ../lib/.
cd ..
rm -rf sqlcipher


# Compiling sqlite3.c
gcc -lpthread -DSQLITE_HAS_CODEC -L./lib/libcrypto.a -c ./lib/sqlite3.c -o ./lib/sqlite3.a
rm ./lib/sqlite3.c
```

## Compile / Run
```
make build
./main
```

This will ask for a passwd to encrypt/decrypt the DB. and then insert a timestamp in a table, and select all records from that table. 


## Dynamic linking 

Depends on the requirements / security considerations. It assumes `libssl-dev` is installed in Ubuntu, and will do a dynamic linking: the final user will have to install openssl before running the executable.

```
sudo apt install libssl-dev
```


```
rm -rf lib
mkdir lib



# Generating sqlite3.c
git clone https://github.com/sqlcipher/sqlcipher.git
cd sqlcipher/
./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
make sqlite3.c
cp sqlite3.c ../lib/.
cd ..
rm -rf sqlcipher



#Compiling sqlite3.c**
gcc -lpthread -DSQLITE_HAS_CODEC -lcrypto -c ./lib/sqlite3.c -o ./lib/sqlite3.a
rm ./lib/sqlite3.c

```

The build command changes:
```
nim c -d:release -L:./lib/sqlite3.a -L:-lm -L:"-lcrypto" --threads --outdir:. main.nim
./main
```

