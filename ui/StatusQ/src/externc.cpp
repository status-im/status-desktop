#include <QtGlobal>

#include <StatusQ/typesregistration.h>
#include <StatusQ/stringutilsinternal.h>

extern "C" {

Q_DECL_EXPORT void statusq_registerQmlTypes() {
    registerStatusQTypes();
}

Q_DECL_EXPORT bool statusq_isCompressedPubKey(const char* pubKey) {
    return StringUtilsInternal().isCompressedPubKey(pubKey);
}

} // extern "C"
