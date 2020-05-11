SQLCipher - Nim / NOTES
===

This will compile sqlcipher. It assumes `libssl-dev` is installed in Ubuntu, and will do a dynamic linking: the final user will have to install openssl before. The code will have to be changed to use static linking instead after compiling OpenSSL. There are some implications: gclib should be installed in the OS that will run the static linked. This is probably an non-issue. Ubuntu is providing this lib since 2013. It might be the same for other operative systems

```
git clone https://github.com/sqlcipher/sqlcipher.git

cd sqlcipher/
./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"
make sqlite3.c

cp sqlite3.* ../.
cd ..
```

The make command will generate `sqlite3.c` and `sqlite3.h` which are copied into this folder, I tried to use [c2nim](https://github.com/nim-lang/c2nim) to generate a small wrapper for SQLite using the header but I wasn't successful. Someone please try using that software to see if it works for them


**Compiling sqlite3.c to a shared library**
```
gcc -lpthread -DSQLITE_HAS_CODEC -lcrypto -c sqlite3.c
```

I found this nim library: [Tiny_SQLite](https://github.com/GULPF/tiny_sqlite/blob/master/src/tiny_sqlite/sqlite_wrapper.nim) that already provides a wrapper for SQLite. It assumes SQLite works dinamically linked. I changed it to static linking and added a new function:

```nim
# In sqlite_wrapper.nim
proc key*(para1: PSqlite3, para2: cstring, para3: int32): int32{.cdecl, importc: "sqlite3_key".}

# In tiny_sqlite.nim
proc key*(db: DbConn, password: string) =
    let rc = sqlite.key(db, password, int32(password.len))
    db.checkRc(rc)
```

**Compile / Run**
```
make build
./main
```

This will ask for a passwd to encrypt/decrypt the DB. and then insert a timestamp in a table, and select all records from that table


