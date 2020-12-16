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

#include <QtCore/QDir>
#include <QtCore/QDebug>
#include <QtCore/QModelIndex>
#include <QtCore/QHash>
#include <QtCore/QResource>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkDiskCache>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlNetworkAccessManagerFactory>
#include <QtCore>
#include <QClipboard>
#include <QtGui/QPixmap>
#include <QtGui/QImage>
#include <QtGui/QColorSpace>
#include <QtGui/QTextDocumentFragment>
#include <QtCore/QFile>
#include <QtCore/QUuid>
#include <QtQml/QQmlApplicationEngine>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickImageProvider>
#include <QTranslator>
#ifdef QT_QUICKCONTROLS2_LIB
#include <QtQuickControls2/QQuickStyle>
#endif
#include <QtWidgets/QApplication>

#include "DOtherSide/DOtherSideTypesCpp.h"
#include "DOtherSide/DosQMetaObject.h"
#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQObjectImpl.h"
#include "DOtherSide/DosQAbstractItemModel.h"
#include "DOtherSide/DosQDeclarative.h"
#include "DOtherSide/DosQQuickImageProvider.h"

namespace {

void register_meta_types()
{
    qRegisterMetaType<QVector<int>>();
}

}

// jrainville: I'm not sure where to put this, but it works like so
QTranslator *m_translator = new QTranslator();

class QMLNetworkAccessFactory : public QQmlNetworkAccessManagerFactory
{
    public:
        static QString tmpPath;

        QMLNetworkAccessFactory()
        : QQmlNetworkAccessManagerFactory()
        {
           
        }

        QNetworkAccessManager* create(QObject* parent);

        void setTmpPath(const char* path);
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


char *convert_to_cstring(const QByteArray &array)
{
    return qstrdup(array.data());
}

char *convert_to_cstring(const QString &source)
{
    return convert_to_cstring(source.toUtf8());
}

char *dos_qcoreapplication_application_dir_path()
{
    return convert_to_cstring(QCoreApplication::applicationDirPath());
}

void dos_qapplication_enable_hdpi()
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
}

void dos_qapplication_initialize_opengl()
{
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
}

void dos_qguiapplication_create()
{
    static int argc = 1;
    static char empty[1] = {0};
    static char *argv[] = {empty};

    register_meta_types();

    new QGuiApplication(argc, argv);
}

void dos_qapplication_clipboard_setText(const char* text)
{
    QApplication::clipboard()->setText(text);
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
    qGuiApp->quit();
}

void dos_qapplication_create(char *appName)
{
    static int argc = 1;
    static char *argv[] = {appName};

    register_meta_types();

    new QApplication(argc, argv);
}

void dos_qapplication_delete()
{
    delete qApp;
}

void dos_qapplication_exec()
{
    qApp->exec();
}

void dos_qapplication_icon(const char *filename)
{
    qApp->setWindowIcon(QIcon(filename));
}

void dos_qapplication_quit()
{
    qApp->quit();
}

::DosQQmlApplicationEngine *dos_qqmlapplicationengine_create()
{
    return new QQmlApplicationEngine();
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
    engine->load(QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + QDir::separator() + QString(filename)));
}

void dos_qqmlapplicationengine_load_url(::DosQQmlApplicationEngine *vptr, ::DosQUrl *url)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    auto qurl = static_cast<QUrl *>(url);
    engine->load(*qurl);
}

void dos_qqmlapplicationengine_load_data(::DosQQmlApplicationEngine *vptr, const char *data)
{
    auto engine = static_cast<QQmlApplicationEngine *>(vptr);
    engine->loadData(data);
}

void dos_qapplication_load_translation(::DosQQmlApplicationEngine *vptr, const char* translationPackage)
{
    if (!m_translator->isEmpty()) {
        QCoreApplication::removeTranslator(m_translator);
    }
    if (m_translator->load(translationPackage)) {
        bool success = QCoreApplication::installTranslator(m_translator);
        auto engine = static_cast<QQmlApplicationEngine *>(vptr);
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
    view->setSource(QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + QDir::separator() + QString(filename)));
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
}

::DosQVariant *dos_qvariant_create()
{
    return new QVariant();
}

::DosQVariant *dos_qvariant_create_int(int value)
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
    qobject->disconnect();
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
    std::string copy = signal; // signal comes from nim, and might be GC. Creating a copy (QT will handle the freeing)
    QMetaObject::invokeMethod(qobject, slot, Qt::QueuedConnection, Q_ARG(QString, copy.c_str()));
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
    auto roles = QVector<int>::fromStdVector(std::vector<int>(rolesArrayPtr, rolesArrayPtr + rolesArrayLength));
    model->publicDataChanged(*topLeft, *bottomRight, roles);
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

void dos_qcoreapplication_process_events(DosQEventLoopProcessEventFlag flags)
{
    qApp->processEvents(static_cast<QEventLoop::ProcessEventsFlag>(flags));
}

void dos_qcoreapplication_process_events_timed(DosQEventLoopProcessEventFlag flags, int ms)
{
    qApp->processEvents(static_cast<QEventLoop::ProcessEventsFlag>(flags), ms);
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

char *dos_image_resizer(char* imagePath, int maxSize, char* tmpDirPath)
{
    QImage img(imagePath);
    img.setColorSpace(QColorSpace::SRgb);
    int w = img.width();
    int h = img.height();

    QPixmap pixmap;
    pixmap = pixmap.fromImage(img.scaled(maxSize < w ? maxSize : w, maxSize < h ? maxSize : h, Qt::KeepAspectRatio, Qt::SmoothTransformation));

    auto newFilePath = tmpDirPath + QUuid::createUuid().toString(QUuid::WithoutBraces) + ".jpg";

    QFile file(newFilePath);
    file.open(QIODevice::WriteOnly);
    pixmap.save(&file, "jpeg", 75);
    file.close();

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
