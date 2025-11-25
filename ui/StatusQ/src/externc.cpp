#include <QtGlobal>

#include <StatusQ/typesregistration.h>
#include <MobileUI>

extern "C" {

Q_DECL_EXPORT void statusq_registerQmlTypes() {
    registerStatusQTypes();
}

Q_DECL_EXPORT float statusq_getMobileUIScaleFactor(float baseWidth, float baseDpi, float baseScale) {
    return MobileUI::getSmartScaleFactor(baseWidth, baseDpi, baseScale);
}

} // extern "C"
