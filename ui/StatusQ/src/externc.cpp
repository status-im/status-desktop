#include <QtGlobal>

#include <StatusQ/typesregistration.h>

extern "C" {

Q_DECL_EXPORT void statusq_registerQmlTypes() {
    registerStatusQTypes();
}

} // extern "C"
