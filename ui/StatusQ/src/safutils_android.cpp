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

extern "C" Q_DECL_EXPORT const char* statusq_saf_createFileInTree(const char* treeUri,
                                                                  const char* mime,
                                                                  const char* displayName)
{
    if (!treeUri || !*treeUri)
        return nullptr;

    const auto jTree = jString(treeUri);
    const auto jMime = jString(mime ? mime : "application/octet-stream");
    const auto jName = jString(displayName ? displayName : "backup.bkp");

    QJniObject ctx = getAndroidContext();
    QJniObject jResult = QJniObject::callStaticObjectMethod(
        "app/status/mobile/SafHelper",
        "createFileInTree",
        "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
        ctx.object(), jTree.object<jstring>(), jMime.object<jstring>(), jName.object<jstring>()
    );

    const QString uri = jResult.isValid() ? jResult.toString() : QString();
    if (uri.isEmpty())
        return nullptr;

    QByteArray utf8 = uri.toUtf8();
    char* out = static_cast<char*>(std::malloc(static_cast<size_t>(utf8.size()) + 1));
    if (!out)
        return nullptr;
    std::memcpy(out, utf8.constData(), static_cast<size_t>(utf8.size()));
    out[utf8.size()] = '\0';
    return out;
}

extern "C" Q_DECL_EXPORT bool statusq_saf_writeBytesToUri(const char* documentUri,
                                                           const void* data,
                                                           int length)
{
    if (!documentUri || !*documentUri || !data || length <= 0)
        return false;

    const auto jUri = jString(documentUri);

    QJniEnvironment env;
    jbyteArray jBytes = env->NewByteArray(length);
    if (!jBytes)
        return false;
    env->SetByteArrayRegion(jBytes, 0, length, reinterpret_cast<const jbyte*>(data));

    QJniObject ctx = getAndroidContext();
    jboolean ok = QJniObject::callStaticMethod<jboolean>(
        "app/status/mobile/SafHelper",
        "writeBytesToUri",
        "(Landroid/content/Context;Ljava/lang/String;[B)Z",
        ctx.object(), jUri.object<jstring>(), jBytes
    );

    env->DeleteLocalRef(jBytes);
    return ok == JNI_TRUE;
}

extern "C" Q_DECL_EXPORT int statusq_saf_openWritableFd(const char* documentUri)
{
    if (!documentUri || !*documentUri)
        return -1;

    const auto jUri = jString(documentUri);

    // Signature: static int openWritableFd(String)
    jint fd = -1;
    QJniObject ctx = getAndroidContext();
    // openWritableFd throws in Java; wrap with try-catch by using exceptionCheck
    fd = QJniObject::callStaticMethod<jint>(
        "app/status/mobile/SafHelper",
        "openWritableFd",
        "(Landroid/content/Context;Ljava/lang/String;)I",
        ctx.object(), jUri.object<jstring>()
    );

    // If an exception occurred, Qt will print it in debug; return -1
    return static_cast<int>(fd);
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

    QByteArray utf8 = uri.toUtf8();
    char* out = static_cast<char*>(std::malloc(static_cast<size_t>(utf8.size()) + 1));
    if (!out)
        return nullptr;
    std::memcpy(out, utf8.constData(), static_cast<size_t>(utf8.size()));
    out[utf8.size()] = '\0';
    return out;
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
    QByteArray utf8 = s.toUtf8();
    char* out = static_cast<char*>(std::malloc(static_cast<size_t>(utf8.size()) + 1));
    if (!out)
        return nullptr;
    std::memcpy(out, utf8.constData(), static_cast<size_t>(utf8.size()));
    out[utf8.size()] = '\0';
    return out;
}

#else // non-Android stubs

extern "C" Q_DECL_EXPORT void statusq_saf_takePersistablePermission(const char*) {}
extern "C" Q_DECL_EXPORT const char* statusq_saf_createFileInTree(const char*, const char*, const char*) { return nullptr; }
extern "C" Q_DECL_EXPORT bool statusq_saf_writeBytesToUri(const char*, const void*, int) { return false; }
extern "C" Q_DECL_EXPORT int statusq_saf_openWritableFd(const char*) { return -1; }
extern "C" Q_DECL_EXPORT const char* statusq_saf_copyFromPathToTree(const char*, const char*, const char*, const char*) { return nullptr; }
extern "C" Q_DECL_EXPORT const char* statusq_saf_getReadableTreePath(const char*) { return nullptr; }

#endif
