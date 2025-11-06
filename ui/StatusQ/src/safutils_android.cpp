#include "StatusQ/safutils.h"

#include <cstring>

#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QJniEnvironment>
#include <QDebug>

static inline QJniObject jString(const char* s) {
    return QJniObject::fromString(QString::fromUtf8(s ? s : ""));
}

static QJniObject getAndroidContext() {
    // Use Qt's Java helper to get the Activity; Activity is-a Context
    QJniObject activity = QJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;"
    );
    return activity;
}

extern "C" Q_DECL_EXPORT void statusq_saf_takePersistablePermission(const char* treeUri)
{
    Q_UNUSED(treeUri);
    if (!treeUri || !*treeUri)
        return;

    const auto jTree = jString(treeUri);
    QJniObject ctx = getAndroidContext();
    QJniObject::callStaticMethod<void>(
        "app/status/mobile/SafHelper",
        "takePersistablePermission",
        "(Landroid/content/Context;Ljava/lang/String;)V",
        ctx.object(), jTree.object<jstring>()
    );
}

#include <cstdlib>

extern "C" Q_DECL_EXPORT const char* statusq_saf_copyFromPathToTree(const char* srcPath,
                                                                     const char* treeUri,
                                                                     const char* mime,
                                                                     const char* displayName)
{
    if (!srcPath || !*srcPath || !treeUri || !*treeUri)
        return nullptr;

    const auto jSrc = jString(srcPath);
    const auto jTree = jString(treeUri);
    const auto jMime = jString(mime ? mime : "application/octet-stream");
    const auto jName = jString(displayName ? displayName : "backup.bkp");

    QJniObject ctx = getAndroidContext();
    QJniObject jResult = QJniObject::callStaticObjectMethod(
        "app/status/mobile/SafHelper",
        "copyFromPathToTree",
        "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
        ctx.object(), jSrc.object<jstring>(), jTree.object<jstring>(), jMime.object<jstring>(), jName.object<jstring>()
    );

    const QString uri = jResult.isValid() ? jResult.toString() : QString();
    if (uri.isEmpty())
        return nullptr;

    QByteArray text = uri.toUtf8();
    char *data = new char[text.size() + 1];
    strcpy(data, text.data());
    return data; // <--  needs to be freed with `delete [] data;`
}

extern "C" Q_DECL_EXPORT const char* statusq_saf_getReadableTreePath(const char* treeUri)
{
    if (!treeUri || !*treeUri)
        return nullptr;
    const auto jTree = jString(treeUri);
    QJniObject jResult = QJniObject::callStaticObjectMethod(
        "app/status/mobile/SafHelper",
        "getReadableTreePath",
        "(Ljava/lang/String;)Ljava/lang/String;",
        jTree.object<jstring>()
    );
    const QString s = jResult.isValid() ? jResult.toString() : QString();
    if (s.isEmpty())
        return nullptr;

    QByteArray text = s.toUtf8();
    char *data = new char[text.size() + 1];
    strcpy(data, text.data());
    return data; // <--  needs to be freed with `delete [] data;`
}

#else // non-Android stubs

extern "C" Q_DECL_EXPORT void statusq_saf_takePersistablePermission(const char*) {}
extern "C" Q_DECL_EXPORT const char* statusq_saf_copyFromPathToTree(const char*, const char*, const char*, const char*) { return nullptr; }
extern "C" Q_DECL_EXPORT const char* statusq_saf_getReadableTreePath(const char*) { return nullptr; }

#endif
