#!/bin/sh

# Parse arguments
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

CWD=$PWD/$(dirname $0)

#SDKs: iphonesimulator, iphoneos
SDK=${SDK:="iphonesimulator"}
IOS_TARGET=${IOS_TARGET:=12}
#Architectures: arm64, arm, x86_64. x86_64 is default for simulator
ARCH=${ARCH:="x86_64"}
#Setting CCompiler to clangwrap.sh
CC=${CC:=$CWD/clangwrap.sh}
#Setting CXXCompiler to clangwrap.sh
CXX=${CXX:=$CWD/clangwrap.sh}

LIB_FOLDER=$CWD/../wrapperApp/libs/$SDK_$ARCH
STATUS_DESKTOP=$CWD/../vendors/status-desktop
STATUSQ=$STATUS_DESKTOP/ui/StatusQ
STATUS_GO=$STATUS_DESKTOP/vendor/status-go
DOTHERSIDE=$STATUS_DESKTOP/vendor/DOtherSide
OPENSSL=$CWD/../vendors/OpenSSL-for-iPhone
QRCODEGEN=$STATUS_DESKTOP/vendor/QR-Code-generator/c
PCRE=$CWD/../vendors/pcre-8.45

mkdir -p $LIB_FOLDER

# #Build status-go
# (cd $STATUS_GO && CC=$CC ARCH=$ARCH $CWD/buildStatusGo.sh) || exit 1
# cp $STATUS_GO/build/bin/libstatus.a $LIB_FOLDER/libstatus.a

# #Build StatusQ
# (cd $STATUSQ && CC=$CC CXX=$CXX ARCH=$ARCH $CWD/buildStatusQ.sh) || exit 1
# cp $STATUSQ/build/lib/Release/libStatusQ.a $LIB_FOLDER/libStatusQ.a
# cp $STATUSQ/build/lib/Release/libqzxing.a $LIB_FOLDER/libqzxing.a

# #Build DOtherSide
# (cd $DOTHERSIDE && CC=$CC CXX=$CXX ARCH=$ARCH $CWD/buildDOtherSide.sh) || exit 1
# cp $DOTHERSIDE/build/lib/Release-$SDK/libDOtherSideStatic.a $LIB_FOLDER/libDOtherSideStatic.a

# #Build OpenSSL
# (cd $OPENSSL && ARCH=$ARCH IOS_TARGET=$IOS_TARGET $CWD/buildOpenSSL.sh) || exit 1
# if [ "$SDK" = "iphonesimulator" ]; then
#     cp $OPENSSL/lib/libcrypto-IOS-Sim.a $LIB_FOLDER/libcrypto.a
#     cp $OPENSSL/lib/libssl-IOS-Sim.a $LIB_FOLDER/libssl.a
# else
#     cp $OPENSSL/lib/libcrypto-IOS.a $LIB_FOLDER/libcrypto.a
#     cp $OPENSSL/lib/libssl-IOS.a $LIB_FOLDER/libssl.a
# fi

# #Build QR-Code-generator
# (cd $QRCODEGEN && CC=$CC ARCH=$ARCH $CWD/buildQRCodeGen.sh) || exit 1
# cp $QRCODEGEN/libqrcodegen.a $LIB_FOLDER/libqrcodegen.a

# #Build PCRE
# (cd $PCRE && ARCH=$ARCH $CWD/buildPCRE.sh) || exit 1
# cp $PCRE/build/Release-$SDK/libpcre.a $LIB_FOLDER/libpcre.a

#Build nim_status_client
(cd $STATUS_DESKTOP && CC=$CC ARCH=$ARCH $CWD/buildNimStatusClient.sh) || exit 1
cp $STATUS_DESKTOP/bin/libnim_status_client.a $LIB_FOLDER/libnim_status_client.a

#build app
($CWD/buildApp.sh) || exit 1