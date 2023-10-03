/*
    Copyright (C) 2019 Filippo Cucchetto.
    Contact: https://github.com/filcuc/dotherside

    This file is part of the DOtherSide library.

    The DOtherSide library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the license, or (at your opinion) any later version.

    The DOtherSide library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with the DOtherSide library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "DOtherSide/DOtherSide.h"

#include <iostream>

#include <QtGlobal>
#include <QtCore/QDir>
#include <QtCore/QDebug>
#include <QtCore/QModelIndex>
#include <QtCore/QHash>
#include <QtCore/QResource>
#include <QtCore/QFile>
#include <QSslConfiguration>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkDiskCache>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QSslSocket>
#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlNetworkAccessManagerFactory>
#include <QClipboard>
#include <QtGui/QPixmap>
#include <QtGui/QImage>
#include <QtGui/QColorSpace>
#include <QtGui/QTextDocumentFragment>
#include <QtCore/QUuid>
#include <QtQml/QQmlApplicationEngine>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickImageProvider>
#include <QTranslator>
#include <QSettings>
#include <QTimer>
#include <QSysInfo>
#include <QMimeDatabase>
#include <QSaveFile>
#ifdef QT_QUICKCONTROLS2_LIB
#include <QtQuickControls2/QQuickStyle>
#endif
#include <QtWebView>
#include <stdio.h>
#include <stdlib.h>

#include "DOtherSide/DOtherSideTypesCpp.h"
#include "DOtherSide/DosQMetaObject.h"
#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQObjectImpl.h"
#include "DOtherSide/DosQAbstractItemModel.h"
#include "DOtherSide/DosQDeclarative.h"
#include "DOtherSide/DosQQuickImageProvider.h"
#include "DOtherSide/DOtherSideSingleInstance.h"

#include "DOtherSide/Status/OSThemeEvent.h"
#include "DOtherSide/Status/UrlSchemeEvent.h"
#include "DOtherSide/Status/OSNotification.h"
#include "DOtherSide/Status/KeychainManager.h"
#include "DOtherSide/Status/SoundManager.h"
#include "DOtherSide/Status/AppDelegate.h"

#ifdef MONITORING
#include <QProcessEnvironment>
#include "StatusDesktop/Monitoring/Monitor.h"
#endif

namespace {

void register_meta_types()
{
    qRegisterMetaType<QVector<int>>();

#ifdef MONITORING
    qmlRegisterSingletonType<Monitor>("Monitoring", 1 , 0, "Monitor", &Monitor::qmlInstance);
#endif
}

}

// jrainville: I'm not sure where to put this, but it works like so
namespace {
    QTranslator g_translator;
}

class QMLNetworkAccessFactory : public QQmlNetworkAccessManagerFactory
{
    public:
        static QString tmpPath;

        QMLNetworkAccessFactory()
        : QQmlNetworkAccessManagerFactory()
        {

        }

        QNetworkAccessManager* create(QObject* parent) override;
};

QString QMLNetworkAccessFactory::tmpPath = "";

QNetworkAccessManager* QMLNetworkAccessFactory::create(QObject* parent)
{
    QNetworkAccessManager* manager = new QNetworkAccessManager(parent);
    QNetworkDiskCache* cache = new QNetworkDiskCache(manager);
    qDebug() << "Network Cache Dir: " << QMLNetworkAccessFactory::tmpPath ;
    cache->setCacheDirectory(QMLNetworkAccessFactory::tmpPath);
    manager->setCache(cache);
    return manager;
}

void dos_add_self_signed_certificate(const char* pemCertificateContent) {
    QSslConfiguration defaultConfig = QSslConfiguration::defaultConfiguration();
    QList<QSslCertificate> certList = defaultConfig.caCertificates();
    QByteArray data(pemCertificateContent);
    const auto certs = QSslCertificate::fromData(data, QSsl::Pem);
    for (const QSslCertificate &cert : certs) {
        certList += cert;
    }
    // According to the docs, caCertificates() should have returned
    // the system certificates (https://doc.qt.io/archives/qt-5.14/qsslconfiguration.html#systemCaCertificates)
    // but looks like there's a bug in QT, because caCertificates() 
    // returns an empty list. Without this, we end up not being
    // able to load stickers or gifs
    certList.append(defaultConfig.systemCaCertificates());

    defaultConfig.setCaCertificates(certList);
    QSslConfiguration::setDefaultConfiguration(defaultConfig);
}

char *convert_to_cstring(const QByteArray &array)
{
    return qstrdup(array.data());
}

char *convert_to_cstring(const QString &source)
{
    return convert_to_cstring(source.toUtf8());
}

char *dos_qguiapplication_application_dir_path()
{
    return convert_to_cstring(QGuiApplication::applicationDirPath());
}

void dos_qguiapplication_enable_hdpi(const char *uiScaleFilePath)
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QFile scaleFile(QString::fromUtf8(uiScaleFilePath));
    if (scaleFile.open(QIODevice::ReadOnly)) {
        const auto scale = scaleFile.readAll();
        qputenv("QT_SCALE_FACTOR", scale);
    }
}

void dos_qguiapplication_initialize_opengl()
{
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
}

void dos_qtwebview_initialize()
{
    QtWebView::initialize();
}

void dos_qguiapplication_try_enable_threaded_renderer()
{
    if(QSysInfo::kernelType() == "darwin" && QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
    {
        //Threaded renderer is crashing on M1 Macs
        return;
    }
    qputenv("QSG_RENDER_LOOP", "threaded");
}

// This catches the QT and QML logs and outputs them.
// This is necessary on Windows, because otherwise we do not get any logs at all
void myMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();
    const char *file = context.file ? context.file : "";
    const char *function = context.function ? context.function : "";
    switch (type) {
    case QtDebugMsg:
        fprintf(stderr, "Debug: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtInfoMsg:
        fprintf(stderr, "Info: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtWarningMsg:
        fprintf(stderr, "Warning: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    default:
        fprintf(stderr, "Default: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    }
}

void dos_qguiapplication_create()
{
    // The parameters argc and argv and the strings pointed to by the argv array shall be modifiable by the program,
    // and retain their last-stored values between program startup and program termination.
    // In other words: argv strings can't be string literals!
    const auto toCharPtr = [](const QString& str) {
        auto bytes = str.toLocal8Bit();
        char *data = new char[bytes.size() + 1]; 
        strcpy(data, bytes.data());
        return data; // we don't care about memory leak here
    };

#ifdef QML_DEBUG_PORT
    static int argc = 2;
    static char *argv[] = {toCharPtr(QStringLiteral("Status")), toCharPtr(QString("-qmljsdebugger=port:%1,block").arg(QML_DEBUG_PORT))};
#else
    static int argc = 1;
    static char *argv[] = {toCharPtr(QStringLiteral("Status"))};
#endif

    // NOTE: https://github.com/status-im/status-desktop/issues/6930
    // We increase js stack size to prevent "Maximum call stack size exceeded" on UI loading.
    qputenv("QV4_JS_MAX_STACK_SIZE", "10485760");
    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", "1");
    qInstallMessageHandler(myMessageOutput);

    new QGuiApplication(argc, argv);
#ifdef Q_OS_MACOS
    app_delegate::install();
#endif
    register_meta_types();
}

void dos_qguiapplication_clipboard_setText(const char* text)
{
    QGuiApplication::clipboard()->setText(text);
}

char* dos_qguiapplication_clipboard_getText()
{
    auto clipboardText = QGuiApplication::clipboard()->text();
    return convert_to_cstring(clipboardText);
}

void dos_qguiapplication_clipboard_setImage(const char* text)
{
    QByteArray btArray =  QString(text).split("base64,")[1].toUtf8();
    QImage image;
    image.loadFromData(QByteArray::fromBase64(btArray));
    Q_ASSERT(!image.isNull());
    QGuiApplication::clipboard()->setImage(image);
}

void dos_qguiapplication_clipboard_setImageByUrl(const char* url)
{
    static thread_local QNetworkAccessManager manager;
    manager.setAutoDeleteReplies(true);

    QNetworkReply *reply = manager.get(QNetworkRequest(QUrl(url)));

    QObject::connect(reply, &QNetworkReply::finished, [reply]() {
        if(reply->error() == QNetworkReply::NoError) {
            QByteArray btArray = reply->readAll();
            QImage image;
            image.loadFromData(btArray);
            Q_ASSERT(!image.isNull());
            QGuiApplication::clipboard()->setImage(image);
        }
        else {
            qWarning() << "dos_qguiapplication_clipboard_setImageByUrl: Downloading image failed!";
        }
    });
}

void dos_qguiapplication_download_image(const char *imageSource, const char *filePath)
{
    // Extract file path that can be used to save the image
    const QString fileL = QFile::decodeName(filePath);

    // Get current Date/Time information to use in naming of the image file
    const QString dateTimeString = QDateTime::currentDateTime().toString("dd-MM-yyyy_hh-mm-ss");

    // Extract the image data to be able to load and save into a QImage
    const QByteArray btArray =  QString(imageSource).split("base64,")[1].toUtf8();
    QImage image;
    image.loadFromData(QByteArray::fromBase64(btArray));
    image.save(fileL + "/image_" + dateTimeString + ".png");
}

void dos_qguiapplication_download_imageByUrl(const char *url, const char *filePath)
{
    static thread_local QNetworkAccessManager manager;
    manager.setAutoDeleteReplies(true);

    QNetworkReply *reply = manager.get(QNetworkRequest(QUrl(url)));
    auto targetDir = QUrl::fromUserInput(filePath).toLocalFile();  // accept both "file:/foo/bar" and "/foo/bar"
    if (targetDir.isEmpty())
        targetDir = QDir::homePath();

    QObject::connect(reply, &QNetworkReply::finished, [reply, targetDir] {
        if(reply->error() == QNetworkReply::NoError) {
            // Extract the image data to be able to load and save it
            const auto btArray = reply->readAll();
            Q_ASSERT(!btArray.isEmpty());

            // Get current Date/Time information to use in naming of the image file
            const auto dateTimeString = QDateTime::currentDateTime().toString(QStringLiteral("dd-MM-yyyy_hh-mm-ss"));

            // Get the preferred extension
            QMimeDatabase mimeDb;
            auto ext = mimeDb.mimeTypeForData(btArray).preferredSuffix();
            if (ext.isEmpty())
                ext = QStringLiteral("jpg");

            // Construct the target path
            const auto targetFile = QStringLiteral("%1/image_%2.%3").arg(targetDir, dateTimeString, ext);

            // Save the image in a safe way
            QSaveFile image(targetFile);
            if (!image.open(QIODevice::WriteOnly)) {
                qWarning() << "dos_qguiapplication_download_imageByUrl: Downloading image failed while opening the save file:" << targetFile;
                return;
            }

            if (image.write(btArray) != -1)
                image.commit();
            else
                qWarning() << "dos_qguiapplication_download_imageByUrl: Downloading image failed while saving to file:" << targetFile;
        }
        else {
            qWarning() << "dos_qguiapplication_download_imageByUrl: Downloading image" << reply->request().url() << "failed!";
        }
    });
}

void dos_qguiapplication_delete()
{
    delete qGuiApp;
}

void dos_qguiapplication_exec()
{
    qGuiApp->exec();
}

void dos_qguiapplication_quit()
{
    // This way we will be safe for quitting the app (avoid potential crashes).
    QMetaObject::invokeMethod(qGuiApp, "quit", Qt::QueuedConnection);
}

void dos_qguiapplication_icon(const char *filename)
{
    qGuiApp->setWindowIcon(QIcon(filename));
}

void dos_qguiapplication_installEventFilter(::DosEvent* vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    qGuiApp->installEventFilter(qobject);
}

::DosQQmlApplicationEngine *dos_qqmlapplicationengine_create()
{
#ifdef MONITORING
    auto engine = new QQmlApplicationEngine();
    auto disabledValue = QStringLiteral("0");

    if (QProcessEnvironment::systemEnvironment().value(
            QStringLiteral("DISABLE_MONITORING_WINDOW"), disabledValue) == disabledValue)
        Monitor::instance().initialize(engine);

    return engine;
#else
    return new QQmlApplicationEngine();
#endif
}

::DosQQmlNetworkAccessManagerFactory *dos_qqmlnetworkaccessmanagerfactory_create(const char* tmpPath)
{
    QMLNetworkAccessFactory::tmpPath = tmpPath;
    return new QMLNetworkAccessFactory();
}

void dos_qqmlnetworkaccessmanager_clearconnectioncache(::DosQQmlNetworkAccessManager *vptr)
{
    auto netAccMgr = static_cast<QNetworkAccessManager *>(vptr);
    netAccMgr->clearConnectionCache();
}
void dos_qqmlnetworkaccessmanager_setnetworkaccessible(::DosQQmlNetworkAccessManager *vptr, int accessibility)
{
    auto netAccMgr = static_cast<QNetworkAccessManager *>(vptr);
    auto accessible = static_cast<QNetworkAccessManager::NetworkAccessibility>(accessibility);
    netAccMgr->setNetworkAccessible(accessible);
}

::DosQQmlNetworkAccessManager dos_qqmlapplicationengine_getNetworkAccessManager(::DosQQmlApplicationEngine *vptr)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    engine->networkAccessManager();
}

void dos_qqmlapplicationengine_setNetworkAccessManagerFactory(::DosQQmlApplicationEngine *vptr, ::DosQQmlNetworkAccessManagerFactory *factory)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    auto namFactory = static_cast<QMLNetworkAccessFactory *>(factory);
    engine->setNetworkAccessManagerFactory(namFactory);
}

void dos_qqmlapplicationengine_load(::DosQQmlApplicationEngine *vptr, const char *filename)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    QObject::connect(
        engine, &QQmlApplicationEngine::objectCreated, qGuiApp,
        [](QObject *obj, const QUrl &objUrl) {
          if (!obj) {
            qWarning() << "Error while loading QML:" << objUrl;
            QCoreApplication::exit(EXIT_FAILURE);
          }
        },
        Qt::QueuedConnection);
    engine->load(QUrl::fromLocalFile(QGuiApplication::applicationDirPath() + QDir::separator() + QString(filename)));
}

void dos_qqmlapplicationengine_load_url(::DosQQmlApplicationEngine *vptr, ::DosQUrl *url)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    auto qurl = static_cast<QUrl *>(url);
    QObject::connect(
        engine, &QQmlApplicationEngine::objectCreated, qGuiApp,
        [](QObject *obj, const QUrl &objUrl) {
          if (!obj) {
            qWarning() << "Error while loading QML:" << objUrl;
            QCoreApplication::exit(EXIT_FAILURE);
          }
        },
        Qt::QueuedConnection);
    engine->load(*qurl);
}

void dos_qqmlapplicationengine_load_data(::DosQQmlApplicationEngine *vptr, const char *data)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    engine->loadData(data);
}

void dos_qguiapplication_load_translation(::DosQQmlApplicationEngine *vptr, const char* translationPackage, bool shouldRetranslate)
{
    if (!g_translator.isEmpty()) {
        QGuiApplication::removeTranslator(&g_translator);
    }
    if (g_translator.load(translationPackage)) {
        bool success = QGuiApplication::installTranslator(&g_translator);
        auto engine = static_cast<QQmlApplicationEngine *>(vptr);
        if (engine && success && shouldRetranslate)
            engine->retranslate();
    } else {
        printf("Failed to load translation file %s\n", translationPackage);
    }
}

void dos_qqmlapplicationengine_add_import_path(::DosQQmlApplicationEngine *vptr, const char *path)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    engine->addImportPath(QString(path));
}

::DosQQmlContext *dos_qqmlapplicationengine_context(::DosQQmlApplicationEngine *vptr)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    engine->rootContext();
    return engine->rootContext();
}

void dos_qqmlapplicationengine_addImageProvider(DosQQmlApplicationEngine *vptr, const char* name, DosQQuickImageProvider *vptr_i)
{
  auto engine = static_cast<QQmlApplicationEngine *>(vptr);
  auto provider = static_cast<DosImageProvider *>(vptr_i);
  engine->addImageProvider(QString(name), provider);
}

void dos_qqmlapplicationengine_delete(::DosQQmlApplicationEngine *vptr)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    delete engine;
}


::DosQQuickImageProvider *dos_qquickimageprovider_create(RequestPixmapCallback callback)
{
    return new DosImageProvider(callback);
}

void dos_qquickimageprovider_delete(::DosQQuickImageProvider *vptr)
{
    auto provider = static_cast<DosImageProvider *>(vptr);
    delete provider;
}

::DosPixmap *dos_qpixmap_create()
{
    return new QPixmap();
}

::DosPixmap *dos_qpixmap_create_qpixmap(const DosPixmap *other)
{
    auto pixmap = static_cast<const QPixmap *>(other);
    return new QPixmap(pixmap ? *pixmap : QPixmap());
}

::DosPixmap *dos_qpixmap_create_width_and_height(int width, int height)
{
    return new QPixmap(width, height);
}

void dos_qpixmap_delete(DosPixmap *vptr)
{
    auto pixmap = static_cast<QPixmap *>(vptr);
    delete pixmap;
}

void dos_qpixmap_load(DosPixmap *vptr, const char* filepath, const char* format)
{
    auto pixmap = static_cast<QPixmap *>(vptr);
    pixmap->load(QString(filepath), format);
}

void dos_qpixmap_loadFromData(DosPixmap *vptr, const unsigned char* data, unsigned int len)
{
    auto pixmap = static_cast<QPixmap *>(vptr);
    pixmap->loadFromData(data, len);
}

void dos_qpixmap_fill(DosPixmap *vptr, unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
    auto pixmap = static_cast<QPixmap *>(vptr);
    pixmap->fill(QColor(r, g, b, a));
}

void dos_qpixmap_assign(DosPixmap *vptr, const DosPixmap *other)
{
    if (vptr) {
        auto lhs = static_cast<QPixmap *>(vptr);
        auto rhs = static_cast<const QPixmap *>(other);
        *lhs = rhs ? *rhs : QPixmap();
    }
}

bool dos_qpixmap_isNull(DosPixmap *vptr)
{
    auto pixmap = static_cast<QPixmap *>(vptr);
    return pixmap->isNull();
}

::DosQQuickView *dos_qquickview_create()
{
    return new QQuickView();
}

void dos_qquickview_show(::DosQQuickView *vptr)
{
    auto view = static_cast<QQuickView *>(vptr);
    view->show();
}

void dos_qquickview_delete(::DosQQuickView *vptr)
{
    auto view = static_cast<QQuickView *>(vptr);
    delete view;
}

char *dos_qquickview_source(const ::DosQQuickView *vptr)
{
    auto view = static_cast<const QQuickView *>(vptr);
    QUrl url = view->source();
    return convert_to_cstring(url.toString());
}

void dos_qquickview_set_source(::DosQQuickView *vptr, const char *filename)
{
    auto view = static_cast<QQuickView *>(vptr);
    view->setSource(QUrl::fromLocalFile(QGuiApplication::applicationDirPath() + QDir::separator() + QString(filename)));
}

void dos_qquickview_set_source_url(::DosQQuickView *vptr, ::DosQUrl *url)
{
    auto view = static_cast<QQuickView *>(vptr);
    auto _url = static_cast<QUrl *>(url);
    view->setSource(*_url);
}

void dos_qquickview_set_resize_mode(::DosQQuickView *vptr, int resizeMode)
{
    auto view = static_cast<QQuickView *>(vptr);
    view->setResizeMode(static_cast<QQuickView::ResizeMode>(resizeMode));
}

::DosQQmlContext *dos_qquickview_rootContext(::DosQQuickView *vptr)
{
    auto view = static_cast<QQuickView *>(vptr);
    return view->rootContext();
}

void dos_chararray_delete(char *ptr)
{
    if (ptr) delete[] ptr;
}

void dos_qvariantarray_delete(DosQVariantArray *ptr)
{
    if (!ptr || !ptr->data)
        return;
    // Delete each variant
    for (int i = 0; i < ptr->size; ++i)
        dos_qvariant_delete(ptr->data[i]);
    // Delete the array
    delete[] ptr->data;
    ptr->data = nullptr;
    ptr->size = 0;
    // Delete the wrapped struct
    delete ptr;
}

char *dos_qqmlcontext_baseUrl(const ::DosQQmlContext *vptr)
{
    auto context = static_cast<const QQmlContext *>(vptr);
    QUrl url = context->baseUrl();
    return convert_to_cstring(url.toString());
}

void dos_qqmlcontext_setcontextproperty(::DosQQmlContext *vptr, const char *name, ::DosQVariant *value)
{
    auto context = static_cast<QQmlContext *>(vptr);
    auto variant = static_cast<QVariant *>(value);
    context->setContextProperty(QString::fromUtf8(name), *variant);

#ifdef MONITORING
    Monitor::instance().addContextPropertyName(QString::fromUtf8(name));
#endif
}

::DosQVariant *dos_qvariant_create()
{
    return new QVariant();
}

::DosQVariant *dos_qvariant_create_int(int value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_longlong(long long value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_ulonglong(unsigned long long value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_bool(bool value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_string(const char *value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_qvariant(const ::DosQVariant *other)
{
    auto otherQVariant = static_cast<const QVariant *>(other);
    auto result = new QVariant();
    *result = *otherQVariant;
    return result;
}

::DosQVariant *dos_qvariant_create_qobject(::DosQObject *value)
{
    auto qobject = static_cast<QObject *>(value);
    auto result = new QVariant();
    result->setValue<QObject *>(qobject);
    return result;
}

::DosQVariant *dos_qvariant_create_float(float value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_double(double value)
{
    return new QVariant(value);
}

::DosQVariant *dos_qvariant_create_array(int size, ::DosQVariant **array)
{
    QList<QVariant> data;
    data.reserve(size);
    for (int i = 0; i < size; ++i)
        data << *(static_cast<QVariant *>(array[i]));
    return new QVariant(data);
}

bool dos_qvariant_isnull(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->isNull();
}

void dos_qvariant_delete(::DosQVariant *vptr)
{
    auto variant = static_cast<QVariant *>(vptr);
    delete variant;
}

void dos_qvariant_assign(::DosQVariant *vptr, const DosQVariant *other)
{
    auto leftQVariant = static_cast<QVariant *>(vptr);
    auto rightQVariant = static_cast<const QVariant *>(other);
    *leftQVariant = *rightQVariant;
}

int dos_qvariant_toInt(const ::DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toInt();
}

long long dos_qvariant_toLongLong(const ::DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toLongLong();
}

unsigned long long dos_qvariant_toULongLong(const ::DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toULongLong();
}

bool dos_qvariant_toBool(const ::DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toBool();
}

float dos_qvariant_toFloat(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toFloat();
}

double dos_qvariant_toDouble(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->toDouble();
}

char *dos_qvariant_toString(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return convert_to_cstring(variant->toString());
}

DosQVariantArray *dos_qvariant_toArray(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    QVariantList data = variant->toList();
    auto result = new DosQVariantArray();
    result->size = data.size();
    result->data = new DosQVariant*[result->size];
    for (int i = 0; i < result->size; ++i)
        result->data[i] = new QVariant(data[i]);
    return result;
}

::DosQObject *dos_qvariant_toQObject(const DosQVariant *vptr)
{
    auto variant = static_cast<const QVariant *>(vptr);
    return variant->value<QObject *>();
}

void dos_qvariant_setInt(::DosQVariant *vptr, int value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setLongLong(::DosQVariant *vptr, long long value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setULongLong(::DosQVariant *vptr, unsigned long long value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setBool(::DosQVariant *vptr, bool value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setFloat(::DosQVariant *vptr, float value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setDouble(::DosQVariant *vptr, double value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setString(::DosQVariant *vptr, const char *value)
{
    auto variant = static_cast<QVariant *>(vptr);
    *variant = value;
}

void dos_qvariant_setQObject(::DosQVariant *vptr, ::DosQObject *value)
{
    auto variant = static_cast<QVariant *>(vptr);
    auto qobject = static_cast<QObject *>(value);
    variant->setValue<QObject *>(qobject);
}

void dos_qvariant_setArray(::DosQVariant *vptr, int size, ::DosQVariant **array)
{
    auto variant = static_cast<QVariant *>(vptr);
    QVariantList data;
    data.reserve(size);
    for (int i = 0; i < size; ++i)
        data << *(static_cast<QVariant *>(array[i]));
    variant->setValue(data);
}

::DosQMetaObject *dos_qobject_qmetaobject()
{
    return new DOS::DosIQMetaObjectHolder(std::make_shared<DOS::DosQObjectMetaObject>());
}

::DosQObject *dos_qobject_create(void *dObjectPointer, ::DosQMetaObject *metaObject, ::DObjectCallback dObjectCallback)
{
    auto metaObjectHolder = static_cast<DOS::DosIQMetaObjectHolder *>(metaObject);
    auto dosQObject = new DOS::DosQObject(dObjectPointer, metaObjectHolder->data(), dObjectCallback);
    QQmlEngine::setObjectOwnership(dosQObject, QQmlEngine::CppOwnership);
    return static_cast<QObject *>(dosQObject);
}

void dos_qobject_delete(::DosQObject *vptr)
{
    auto qobject = static_cast<QObject *>(vptr);
    delete qobject;
}

void dos_qobject_deleteLater(::DosQObject *vptr)
{
    auto qobject = static_cast<QObject *>(vptr);
    qobject->deleteLater();
}

void dos_qobject_signal_emit(::DosQObject *vptr, const char *name, int parametersCount, void **parameters)
{
    auto qobject = static_cast<QObject *>(vptr);
    auto dynamicQObject = dynamic_cast<DOS::DosIQObjectImpl *>(qobject);

    auto transformation = [](void *vptr)->QVariant{return *(static_cast<QVariant *>(vptr));};
    const std::vector<QVariant> variants = DOS::toVector(parameters, parametersCount, transformation);
    dynamicQObject->emitSignal(qobject, QString::fromStdString(name), variants);
}

bool dos_qobject_signal_connect(::DosQObject *senderVPtr,
                                const char *signal,
                                ::DosQObject *receiverVPtr,
                                const char *method,
                                int type)
{
    auto sender = static_cast<QObject *>(senderVPtr);
    auto receiver = static_cast<QObject *>(receiverVPtr);
    return QObject::connect(sender, signal, receiver, method, static_cast<Qt::ConnectionType>(type));
}

bool dos_qobject_signal_disconnect(::DosQObject *senderVPtr,
                                   const char *signal,
                                   ::DosQObject *receiverVPtr,
                                   const char *method)
{
    auto sender = static_cast<QObject *>(senderVPtr);
    auto receiver = static_cast<QObject *>(receiverVPtr);
    return QObject::disconnect(sender, signal, receiver, method);
}

char *dos_qobject_objectName(const ::DosQObject *vptr)
{
    auto object = static_cast<const QObject *>(vptr);
    return convert_to_cstring(object->objectName());
}

void dos_qobject_setObjectName(::DosQObject *vptr, const char *name)
{
    auto object = static_cast<QObject *>(vptr);
    object->setObjectName(QString::fromUtf8(name));
}

::DosQVariant *dos_qobject_property(DosQObject *vptr, const char *propertyName) {
    auto object = static_cast<const QObject *>(vptr);
    auto result = new QVariant(object->property(propertyName));
    return static_cast<QVariant *>(result);
}

bool dos_qobject_setProperty(::DosQObject *vptr, const char *propertyName, ::DosQVariant *dosValue){
    auto object = static_cast<QObject *>(vptr);
    auto value = static_cast<QVariant *>(dosValue);
    return object->setProperty(propertyName, *value);
}

::DosQModelIndex *dos_qmodelindex_create()
{
    return new QModelIndex();
}

::DosQModelIndex *dos_qmodelindex_create_qmodelindex(::DosQModelIndex *other_vptr)
{
    auto other = static_cast<QModelIndex *>(other_vptr);
    return new QModelIndex(*other);
}

void dos_qmodelindex_delete(::DosQModelIndex *vptr)
{
    auto index = static_cast<QModelIndex *>(vptr);
    delete index;
}

int dos_qmodelindex_row(const ::DosQModelIndex *vptr)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    return index->row();
}

int dos_qmodelindex_column(const ::DosQModelIndex *vptr)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    return index->column();
}

bool dos_qmodelindex_isValid(const ::DosQModelIndex *vptr)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    return index->isValid();
}

::DosQVariant *dos_qmodelindex_data(const ::DosQModelIndex *vptr, int role)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    auto result = new QVariant(index->data(role));
    return static_cast<QVariant *>(result);
}

::DosQModelIndex *dos_qmodelindex_parent(const ::DosQModelIndex *vptr)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    auto result = new QModelIndex(index->parent());
    return static_cast<QModelIndex *>(result);
}

::DosQModelIndex *dos_qmodelindex_child(const ::DosQModelIndex *vptr, int row, int column)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    auto result = new QModelIndex(index->child(row, column));
    return static_cast<QModelIndex *>(result);
}

::DosQModelIndex *dos_qmodelindex_sibling(const ::DosQModelIndex *vptr, int row, int column)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    auto result = new QModelIndex(index->sibling(row, column));
    return static_cast<QModelIndex *>(result);
}

void dos_qmodelindex_assign(::DosQModelIndex *l, const ::DosQModelIndex *r)
{
    auto li = static_cast<QModelIndex *>(l);
    auto ri = static_cast<const QModelIndex *>(r);
    *li = *ri;
}

void *dos_qmodelindex_internalPointer(DosQModelIndex *vptr)
{
    auto index = static_cast<const QModelIndex *>(vptr);
    return index->internalPointer();
}

::DosQHashIntQByteArray *dos_qhash_int_qbytearray_create()
{
    return new QHash<int, QByteArray>();
}

void dos_qhash_int_qbytearray_delete(::DosQHashIntQByteArray *vptr)
{
    auto qHash = static_cast<QHash<int, QByteArray>*>(vptr);
    delete qHash;
}

void dos_qhash_int_qbytearray_insert(::DosQHashIntQByteArray *vptr, int key, const char *value)
{
    auto qHash = static_cast<QHash<int, QByteArray>*>(vptr);
    qHash->insert(key, QByteArray(value));
}

char *dos_qhash_int_qbytearray_value(const ::DosQHashIntQByteArray *vptr, int key)
{
    auto qHash = static_cast<const QHash<int, QByteArray>*>(vptr);
    return convert_to_cstring(qHash->value(key));
}

void dos_qresource_register(const char *filename)
{
    QResource::registerResource(QString::fromUtf8(filename));
}

::DosQUrl *dos_qurl_create(const char *url, int parsingMode)
{
    return new QUrl(QString::fromUtf8(url), static_cast<QUrl::ParsingMode>(parsingMode));
}

void dos_qurl_delete(::DosQUrl *vptr)
{
    auto url = static_cast<QUrl *>(vptr);
    delete url;
}

char *dos_qurl_to_string(const ::DosQUrl *vptr)
{
    auto url = static_cast<const QUrl *>(vptr);
    return convert_to_cstring(url->toString());
}

bool dos_qurl_isValid(const ::DosQUrl *vptr)
{
    auto url = static_cast<const QUrl *>(vptr);
    return url->isValid();
}

::DosQMetaObject *dos_qmetaobject_create(::DosQMetaObject *superClassVPtr,
                                         const char *className,
                                         const ::SignalDefinitions *signalDefinitions,
                                         const ::SlotDefinitions *slotDefinitions,
                                         const ::PropertyDefinitions *propertyDefinitions)
{
    Q_ASSERT(superClassVPtr);
    auto superClassHolder = static_cast<DOS::DosIQMetaObjectHolder *>(superClassVPtr);
    Q_ASSERT(superClassHolder);
    auto data = superClassHolder->data();
    Q_ASSERT(data);

    auto metaObject = std::make_shared<DOS::DosQMetaObject>(data,
                                                            QString::fromUtf8(className),
                                                            DOS::toVector(*signalDefinitions),
                                                            DOS::toVector(*slotDefinitions),
                                                            DOS::toVector(*propertyDefinitions));
    return new DOS::DosIQMetaObjectHolder(std::move(metaObject));
}

void dos_signal(::DosQObject *vptr, const char *signal, const char *slot) //
{
    auto qobject = static_cast<QObject *>(vptr);
    std::string signal_copy = signal;
    std::string slot_copy = slot;
    QMetaObject::invokeMethod(qobject, slot_copy.c_str(), Qt::QueuedConnection, Q_ARG(QString, signal_copy.c_str()));
}

void dos_qmetaobject_delete(::DosQMetaObject *vptr)
{
    auto factory = static_cast<DOS::DosIQMetaObjectHolder *>(vptr);
    delete factory;
}

::DosQMetaObject *dos_qabstracttablemodel_qmetaobject()
{
    return new DOS::DosIQMetaObjectHolder(std::make_shared<DOS::DosQAbstractTableModelMetaObject>());
}

::DosQAbstractListModel *dos_qabstracttablemodel_create(void *dObjectPointer,
                                                        ::DosQMetaObject *metaObjectPointer,
                                                        ::DObjectCallback dObjectCallback,
                                                        ::DosQAbstractItemModelCallbacks *callbacks)
{
    auto metaObjectHolder = static_cast<DOS::DosIQMetaObjectHolder *>(metaObjectPointer);
    auto model = new DOS::DosQAbstractTableModel(dObjectPointer,
                                                 metaObjectHolder->data(),
                                                 dObjectCallback,
                                                 *callbacks);
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);
    return static_cast<QObject *>(model);
}

DosQModelIndex *dos_qabstracttablemodel_index(DosQAbstractTableModel *vptr, int row, int column, DosQModelIndex *dosParent)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosQAbstractTableModel *>(object);
    auto parent = static_cast<QModelIndex *>(dosParent);
    auto result = new QModelIndex(model->defaultIndex(row, column, *parent));
    return static_cast<DosQModelIndex *>(result);
}

DosQModelIndex *dos_qabstracttablemodel_parent(DosQAbstractTableModel *vptr, DosQModelIndex *dosChild)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosQAbstractTableModel *>(object);
    auto child = static_cast<QModelIndex *>(dosChild);
    auto result = new QModelIndex(model->defaultParent(*child));
    return static_cast<DosQModelIndex *>(result);
}

::DosQMetaObject *dos_qabstractlistmodel_qmetaobject()
{
    return new DOS::DosIQMetaObjectHolder(std::make_shared<DOS::DosQAbstractListModelMetaObject>());
}

::DosQAbstractListModel *dos_qabstractlistmodel_create(void *dObjectPointer,
                                                       ::DosQMetaObject *metaObjectPointer,
                                                       ::DObjectCallback dObjectCallback,
                                                       ::DosQAbstractItemModelCallbacks *callbacks)
{
    auto metaObjectHolder = static_cast<DOS::DosIQMetaObjectHolder *>(metaObjectPointer);
    auto model = new DOS::DosQAbstractListModel(dObjectPointer,
                                                metaObjectHolder->data(),
                                                dObjectCallback,
                                                *callbacks);
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);
    return static_cast<QObject *>(model);
}

DosQModelIndex *dos_qabstractlistmodel_index(DosQAbstractListModel *vptr, int row, int column, DosQModelIndex *dosParent)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosQAbstractListModel *>(object);
    auto parent = static_cast<QModelIndex *>(dosParent);
    auto result = new QModelIndex(model->defaultIndex(row, column, *parent));
    return static_cast<DosQModelIndex *>(result);
}

DosQModelIndex *dos_qabstractlistmodel_parent(DosQAbstractListModel *vptr, DosQModelIndex *dosChild)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosQAbstractListModel *>(object);
    auto child = static_cast<QModelIndex *>(dosChild);
    auto result = new QModelIndex(model->defaultParent(*child));
    return static_cast<DosQModelIndex *>(result);
}

int dos_qabstractlistmodel_columnCount(DosQAbstractListModel *vptr, DosQModelIndex *dosParent)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosQAbstractListModel *>(object);
    auto parent = static_cast<QModelIndex *>(dosParent);
    return model->defaultColumnCount(*parent);
}

::DosQMetaObject *dos_qabstractitemmodel_qmetaobject()
{
    return new DOS::DosIQMetaObjectHolder(std::make_shared<DOS::DosQAbstractItemModelMetaObject>());
}

::DosQAbstractItemModel *dos_qabstractitemmodel_create(void *dObjectPointer,
                                                       ::DosQMetaObject *metaObjectPointer,
                                                       ::DObjectCallback dObjectCallback,
                                                       ::DosQAbstractItemModelCallbacks *callbacks)
{
    auto metaObjectHolder = static_cast<DOS::DosIQMetaObjectHolder *>(metaObjectPointer);
    auto model = new DOS::DosQAbstractItemModel(dObjectPointer,
                                                metaObjectHolder->data(),
                                                dObjectCallback,
                                                *callbacks);
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);
    return static_cast<QObject *>(model);
}

void dos_qabstractitemmodel_beginInsertRows(::DosQAbstractItemModel *vptr, ::DosQModelIndex *parentIndex, int first, int last)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(parentIndex);
    model->publicBeginInsertRows(*index, first, last);
}

void dos_qabstractitemmodel_endInsertRows(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndInsertRows();
}

void dos_qabstractitemmodel_beginRemoveRows(::DosQAbstractItemModel *vptr, ::DosQModelIndex *parentIndex, int first, int last)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(parentIndex);
    model->publicBeginRemoveRows(*index, first, last);
}

void dos_qabstractitemmodel_endRemoveRows(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndRemoveRows();
}

void dos_qabstractitemmodel_beginMoveRows(DosQAbstractItemModel* vptr, ::DosQModelIndex* sourceParent, int sourceFirst, int sourceLast,
                                          DosQModelIndex* destinationParent, int destinationChild)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto sourceIndex = static_cast<QModelIndex *>(sourceParent);
    auto destIndex = static_cast<QModelIndex *>(destinationParent);
    model->publicBeginMoveRows(*sourceIndex, sourceFirst, sourceLast, *destIndex, destinationChild);
}

void dos_qabstractitemmodel_endMoveRows(DosQAbstractItemModel* vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndMoveRows();
}

void dos_qabstractitemmodel_beginInsertColumns(::DosQAbstractItemModel *vptr, ::DosQModelIndex *parentIndex, int first, int last)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(parentIndex);
    model->publicBeginInsertColumns(*index, first, last);
}

void dos_qabstractitemmodel_endInsertColumns(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndInsertColumns();
}

void dos_qabstractitemmodel_beginRemoveColumns(::DosQAbstractItemModel *vptr, ::DosQModelIndex *parentIndex, int first, int last)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(parentIndex);
    model->publicBeginRemoveColumns(*index, first, last);
}

void dos_qabstractitemmodel_endRemoveColumns(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndRemoveColumns();
}

void dos_qabstractitemmodel_beginResetModel(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicBeginResetModel();
}

void dos_qabstractitemmodel_endResetModel(::DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    model->publicEndResetModel();
}

void dos_qabstractitemmodel_dataChanged(::DosQAbstractItemModel *vptr,
                                        const ::DosQModelIndex *topLeftIndex,
                                        const ::DosQModelIndex *bottomRightIndex,
                                        int *rolesArrayPtr,
                                        int rolesArrayLength)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto topLeft = static_cast<const QModelIndex *>(topLeftIndex);
    auto bottomRight = static_cast<const QModelIndex *>(bottomRightIndex);
    if (rolesArrayPtr && rolesArrayLength > 0) {
        model->publicDataChanged(*topLeft, *bottomRight, {rolesArrayPtr, rolesArrayPtr + rolesArrayLength});
    } else {
        model->publicDataChanged(*topLeft, *bottomRight);
    }
}

DosQModelIndex *dos_qabstractitemmodel_createIndex(::DosQAbstractItemModel *vptr,
                                                   int row, int column, void *data)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    return new QModelIndex(model->publicCreateIndex(row, column, data));
}

bool dos_qabstractitemmodel_setData(DosQAbstractItemModel *vptr,
                                    DosQModelIndex *dosIndex, DosQVariant *dosValue, int role)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(dosIndex);
    auto value = static_cast<QVariant *>(dosValue);
    return model->defaultSetData(*index, *value, role);
}

DosQHashIntQByteArray *dos_qabstractitemmodel_roleNames(DosQAbstractItemModel *vptr)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto result = new QHash<int, QByteArray>(model->defaultRoleNames());
    return static_cast<DosQHashIntQByteArray *>(result);
}

int dos_qabstractitemmodel_flags(DosQAbstractItemModel *vptr, DosQModelIndex *dosIndex)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(dosIndex);
    return static_cast<int>(model->defaultFlags(*index));
}

DosQVariant *dos_qabstractitemmodel_headerData(DosQAbstractItemModel *vptr, int section, int orientation, int role)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto result = new QVariant(model->defaultHeaderData(section, static_cast<Qt::Orientation>(orientation), role));
    return static_cast<DosQVariant *>(result);
}

bool dos_qabstractitemmodel_hasChildren(DosQAbstractItemModel *vptr, DosQModelIndex *dosParentIndex)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto parentIndex = static_cast<QModelIndex *>(dosParentIndex);
    return model->defaultHasChildren(*parentIndex);
}

bool dos_qabstractitemmodel_hasIndex(DosQAbstractItemModel *vptr, int row, int column, DosQModelIndex *dosParentIndex)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto index = static_cast<QModelIndex *>(dosParentIndex);
    return model->hasIndex(row, column, *index);
}

bool dos_qabstractitemmodel_canFetchMore(DosQAbstractItemModel *vptr, DosQModelIndex *dosParentIndex)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto parentIndex = static_cast<QModelIndex *>(dosParentIndex);
    return model->defaultCanFetchMore(*parentIndex);
}

void dos_qabstractitemmodel_fetchMore(DosQAbstractItemModel *vptr, DosQModelIndex *dosParentIndex)
{
    auto object = static_cast<QObject *>(vptr);
    auto model = dynamic_cast<DOS::DosIQAbstractItemModelImpl *>(object);
    auto parentIndex = static_cast<QModelIndex *>(dosParentIndex);
    model->defaultFetchMore(*parentIndex);
}

int dos_qdeclarative_qmlregistertype(const ::QmlRegisterType *cArgs)
{
    auto holder = static_cast<DOS::DosIQMetaObjectHolder *>(cArgs->staticMetaObject);

    DOS::QmlRegisterType args;
    args.major = cArgs->major;
    args.minor = cArgs->minor;
    args.uri = cArgs->uri;
    args.qml = cArgs->qml;
    args.staticMetaObject = holder->data();
    args.createDObject = cArgs->createDObject;
    args.deleteDObject = cArgs->deleteDObject;

    return DOS::dosQmlRegisterType(std::move(args));
}

int dos_qdeclarative_qmlregistersingletontype(const ::QmlRegisterType *cArgs)
{
    auto holder = static_cast<DOS::DosIQMetaObjectHolder *>(cArgs->staticMetaObject);

    DOS::QmlRegisterType args;
    args.major = cArgs->major;
    args.minor = cArgs->minor;
    args.uri = cArgs->uri;
    args.qml = cArgs->qml;
    args.staticMetaObject = holder->data();
    args.createDObject = cArgs->createDObject;
    args.deleteDObject = cArgs->deleteDObject;

    return DOS::dosQmlRegisterSingletonType(std::move(args));
}

void dos_qquickstyle_set_style(const char *style)
{
#ifdef QT_QUICKCONTROLS2_LIB
    QQuickStyle::setStyle(QString::fromUtf8(style));
#else
    std::cerr << "Library has not QtQuickControls2 support" << std::endl;
#endif
}

void dos_qquickstyle_set_fallback_style(const char *style)
{
#ifdef QT_QUICKCONTROLS2_LIB
    QQuickStyle::setFallbackStyle(QString::fromUtf8(style));
#else
    std::cerr << "Library has no QtQuickControls2 support" << std::endl;
#endif
}

void dos_qguiapplication_process_events(DosQEventLoopProcessEventFlag flags)
{
    qGuiApp->processEvents(static_cast<QEventLoop::ProcessEventsFlag>(flags));
}

void dos_qguiapplication_process_events_timed(DosQEventLoopProcessEventFlag flags, int ms)
{
    qGuiApp->processEvents(static_cast<QEventLoop::ProcessEventsFlag>(flags), ms);
}

::DosQNetworkConfigurationManager *dos_qncm_create()
{
    auto *ncm = new QNetworkConfigurationManager();

    auto netcfgList = ncm->allConfigurations(QNetworkConfiguration::Active);
    for (auto& x : netcfgList) {
      qDebug() << "Connection type: " << x.bearerType() << " - name: " << x.name() << " -purpose: " << x.purpose();
    }

    return ncm;

}

void dos_qncm_delete(::DosQNetworkConfigurationManager *vptr)
{
    auto ncm = static_cast<QNetworkConfigurationManager *>(vptr);
    delete ncm;
}

char *dos_plain_text(char* htmlString)
{
    return convert_to_cstring(QTextDocumentFragment::fromHtml( htmlString ).toPlainText().toUtf8());
}

char *dos_escape_html(char* input)
{
   return convert_to_cstring(QString(input).toHtmlEscaped().toUtf8());
}

char *dos_image_resizer(const char* imagePathOrData, int maxSize, const char* tmpDirPath)
{
    const auto base64JPGPrefix = "data:image/jpeg;base64,";
    QImage img;
    bool loadResult = false;

    // load the contents
    if (qstrncmp(base64JPGPrefix, imagePathOrData, qstrlen(base64JPGPrefix)) == 0)  { // binary BLOB
      loadResult = img.loadFromData(QByteArray::fromBase64(QByteArray(imagePathOrData).mid(qstrlen(base64JPGPrefix))));  // strip the prefix, decode from b64
    } else { // local file or URL
      const auto localFileOrUrl = QUrl::fromUserInput(imagePathOrData); // accept both "file:/foo/bar" and "/foo/bar"
      if (localFileOrUrl.isLocalFile()) {
        loadResult = img.load(localFileOrUrl.toLocalFile());
      } else {
        QEventLoop loop;
        QNetworkAccessManager mgr;
        QObject::connect(&mgr, &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);
        auto reply = mgr.get(QNetworkRequest(localFileOrUrl));
        loop.exec();
        loadResult = img.loadFromData(reply->readAll());
        reply->deleteLater();
      }
    }

    if (!loadResult) {
      qWarning() << "dos_image_resizer: failed to (down)load image";
      return nullptr;
    }

    // scale it
    img = img.scaled(img.size().boundedTo(QSize(maxSize, maxSize)), Qt::KeepAspectRatio, Qt::SmoothTransformation);
    const auto newFilePath = tmpDirPath + QUuid::createUuid().toString(QUuid::WithoutBraces) + ".jpg";
    img.save(newFilePath, "JPG");
    return convert_to_cstring(newFilePath.toUtf8());
}

char *dos_qurl_fromUserInput(char* input)
{
    return convert_to_cstring(QUrl::fromUserInput(QString(input)).toString());
}

char *dos_qurl_host(char* url)
{
    return convert_to_cstring(QUrl(QString(url)).host());
}

char *dos_qurl_replaceHostAndAddPath(char* url, char* newScheme, char* newHost, char* pathPrefix)
{
    auto newQurl = QUrl(QString(url));

    newQurl.setHost(newHost);

    if(QString(newScheme).compare("") != 0){
        newQurl.setScheme(newScheme);
    }

    if (QString(pathPrefix).compare("") != 0){
        newQurl.setPath(QString(pathPrefix) + newQurl.path());
    }

    return convert_to_cstring(newQurl.toString());
}

DosSingleInstance *dos_singleinstance_create(const char *uniqueName, const char *eventStr)
{
    return new SingleInstance(QString::fromUtf8(uniqueName), QString::fromUtf8(eventStr));
}

void dos_singleinstance_delete(DosSingleInstance *vptr)
{
    auto dsi = static_cast<SingleInstance *>(vptr);
    delete dsi;
}

bool dos_singleinstance_isfirst(DosSingleInstance *vptr)
{
    auto dsi = static_cast<SingleInstance *>(vptr);
    if (dsi) {
        return dsi->isFirstInstance();
    }
    return false;
}

#pragma region Events

::DosEvent* dos_event_create_osThemeEvent(::DosQQmlApplicationEngine* vptr)
{
    auto engine = static_cast<QQmlApplicationEngine*>(vptr);
    return new Status::OSThemeEvent(engine);
}

::DosEvent* dos_event_create_urlSchemeEvent()
{
    return new Status::UrlSchemeEvent();
}

void dos_event_delete(DosEvent* vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    qobject->deleteLater();
}
#pragma endregion

#pragma region OSNotification

::DosOSNotification* dos_osnotification_create()
{
    return new Status::OSNotification();
}

void dos_osnotification_show_notification(DosOSNotification* vptr, 
    const char* title, const char* message, const char* identifier)
{
    auto notificationObj = static_cast<Status::OSNotification*>(vptr);
    if(notificationObj)
        notificationObj->showNotification(title, message, identifier);
}

void dos_osnotification_show_badge_notification(DosOSNotification* vptr, int notificationsCount)
{
    auto notificationObj = static_cast<Status::OSNotification*>(vptr);
    if(notificationObj)
        notificationObj->showIconBadgeNotification(notificationsCount);
}

void dos_osnotification_delete(DosOSNotification* vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    if(qobject)
        qobject->deleteLater();
}

#pragma endregion

#pragma region QSettings

DosQSettings* dos_qsettings_create(const char* fileName, int format)
{
    QSettings::Format fileFormat = QSettings::NativeFormat;
    if(format == 1)
        fileFormat = QSettings::IniFormat;

    return new QSettings(QString(fileName), fileFormat);
}

DosQVariant* dos_qsettings_value(DosQSettings* vptr, const char* key, 
    DosQVariant* defaultValue)
{
    auto defaultValuePtr = static_cast<QVariant*>(defaultValue);
    auto settings = static_cast<QSettings*>(vptr);
    if(settings)
    {
        if(defaultValuePtr)
        {
            auto result = new QVariant(settings->value(QString(key), *defaultValuePtr));
            return static_cast<DosQVariant*>(result);
        }
    }

    return defaultValue;
}

void dos_qsettings_set_value(DosQSettings* vptr, const char* key, 
    DosQVariant* value)
{
    auto settings = static_cast<QSettings*>(vptr);
    if(settings)
    {
        auto valuePtr = static_cast<QVariant*>(value);
        if(valuePtr)
        {
            return settings->setValue(QString(key), *valuePtr);
        }
    }
}

void dos_qsettings_remove(DosQSettings* vptr, const char* key)
{
    auto settings = static_cast<QSettings*>(vptr);
    if(settings)
    {
        return settings->remove(QString(key));
    }
}

void dos_qsettings_delete(DosQSettings* vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    if(qobject)
        qobject->deleteLater();
}

void dos_qsettings_begin_group(DosQSettings* vptr, const char* group)
{
    auto settings = static_cast<QSettings*>(vptr);
    if(settings)
    {
        return settings->beginGroup(QString(group));
    }
}

void dos_qsettings_end_group(DosQSettings* vptr)
{
    auto settings = static_cast<QSettings*>(vptr);
    if(settings)
    {
        return settings->endGroup();
    }
}

#pragma endregion

#pragma region QTimer

DosQTimer *dos_qtimer_create()
{
    return new QTimer();
}

void dos_qtimer_delete(DosQTimer *vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    if(qobject)
        qobject->deleteLater();
}

void dos_qtimer_set_interval(DosQTimer *vptr, int interval)
{
    auto timer = static_cast<QTimer*>(vptr);
    if (timer) {
        timer->setInterval(interval);
    }
}

int dos_qtimer_interval(DosQTimer *vptr)
{
    auto timer = static_cast<QTimer*>(vptr);
    return timer ? timer->interval() : -1;
}

void dos_qtimer_start(DosQTimer *vptr)
{
    auto timer = static_cast<QTimer*>(vptr);
    if (timer) {
        timer->start();
    }
}

void dos_qtimer_stop(DosQTimer *vptr)
{
    auto timer = static_cast<QTimer*>(vptr);
    if (timer) {
        timer->stop();
    }
}

void dos_qtimer_set_single_shot(DosQTimer *vptr, bool singleShot)
{
    auto timer = static_cast<QTimer*>(vptr);
    if (timer) {
        timer->setSingleShot(singleShot);
    }
}

bool dos_qtimer_is_single_shot(DosQTimer *vptr)
{
    auto timer = static_cast<QTimer*>(vptr);
    return timer ? timer->isSingleShot() : false;
}

bool dos_qtimer_is_active(DosQTimer *vptr)
{
    auto timer = static_cast<QTimer*>(vptr);
    return timer ? timer->isActive() : false;
}

#pragma endregion

#pragma region KeychainManager
DosKeychainManager* dos_keychainmanager_create(const char* service, 
    const char* authenticationReason)
{
    return new Status::KeychainManager(QString(service), QString(authenticationReason));
}

char* dos_keychainmanager_read_data_sync(DosKeychainManager* vptr, 
    const char* key)
{
    auto obj = static_cast<Status::KeychainManager*>(vptr);
    if(obj)
    {
        return convert_to_cstring(obj->readDataSync(QString(key)));
    }

    return convert_to_cstring(QString());
}

void dos_keychainmanager_read_data_async(DosKeychainManager* vptr, 
    const char* key)
{
    auto obj = static_cast<Status::KeychainManager*>(vptr);
    if(obj)
        obj->readDataAsync(QString(key));
}

void dos_keychainmanager_store_data_async(DosKeychainManager* vptr, 
    const char* key, const char* data)
{
    auto obj = static_cast<Status::KeychainManager*>(vptr);
    if(obj)
    {
        obj->storeDataAsync(QString(key), QString(data));
    }
}

void dos_keychainmanager_delete_data_async(DosKeychainManager* vptr, 
    const char* key)
{
    auto obj = static_cast<Status::KeychainManager*>(vptr);
    if(obj)
        obj->deleteDataAsync(QString(key));
}

void dos_keychainmanager_delete(DosKeychainManager* vptr)
{
    auto qobject = static_cast<QObject*>(vptr);
    if(qobject)
        qobject->deleteLater();

}
#pragma endregion

#pragma region SoundManager

void dos_soundmanager_play_sound(const char* soundUrl)
{
    auto sound = QUrl(QString::fromUtf8(soundUrl));
    Status::SoundManager::instance().playSound(sound);
}

void dos_soundmanager_set_player_volume(int volume)
{
    Status::SoundManager::instance().setPlayerVolume(volume);
}

void dos_soundmanager_stop_player()
{
    Status::SoundManager::instance().stopPlayer();
}

#pragma endregion


char* dos_to_local_file(const char* fileUrl)
{
    return convert_to_cstring(QUrl(QString::fromUtf8(fileUrl)).toLocalFile());
}

char* dos_from_local_file(const char* filePath)
{
    return convert_to_cstring(QUrl::fromLocalFile(QString::fromUtf8(filePath)).toString());
}

bool dos_app_is_active(::DosQQmlApplicationEngine* vptr)
{
    auto engine = static_cast<QQmlApplicationEngine*>(vptr);
    if(!engine)
        return false;

    QObject* topLevelObj = engine->rootObjects().value(0);
    if(topLevelObj && topLevelObj->objectName() == "mainWindow")
    {
        QQuickWindow* window = qobject_cast<QQuickWindow *>(topLevelObj);
        if(window)
        {
            return window->isActive();
        }
    }

    return false;
}

void dos_app_make_it_active(::DosQQmlApplicationEngine* vptr) 
{
    auto engine = static_cast<QQmlApplicationEngine*>(vptr);
    if(!engine)
        return;

    QObject* topLevelObj = engine->rootObjects().value(0);
    if(topLevelObj && topLevelObj->objectName() == "mainWindow")
    {
        QQuickWindow* window = qobject_cast<QQuickWindow *>(topLevelObj);
        if(window)
        {
            window->show();
            window->raise();
            window->requestActivate();
        }
    }
}
