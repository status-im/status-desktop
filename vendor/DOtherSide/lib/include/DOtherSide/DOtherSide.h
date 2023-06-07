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

/**
 * \file DOtherSide.h
 * \brief The DOtherSide API file
 * \author Filippo Cucchetto
 *
 * This file contains all the functions from creating or manipulating the QML
 * environement
 */

#ifndef DOTHERSIDE_H
#define DOTHERSIDE_H

#ifdef WIN32
#define DOS_API   __declspec( dllexport )
#define DOS_CALL __cdecl
#else
#define DOS_API
#define DOS_CALL
#endif

#include <DOtherSide/DOtherSideTypes.h>

#ifdef __cplusplus
extern "C"
{
#endif

/// \brief Return the QCore::applicationDirPath
/// \return The QCore::applicationDirPath as a UTF-8 string
/// \note The returned string should be deleted by the calling code by using
/// the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qguiapplication_application_dir_path(void);

/// \brief Force the event loop to spin and process the given events
DOS_API void DOS_CALL dos_qguiapplication_process_events(DosQEventLoopProcessEventFlag flags = DosQEventLoopProcessEventFlag::DosQEventLoopProcessEventFlagProcessAllEvents);

/// \brief Force the event loop to spin and process the given events until no more available or timed out
DOS_API void DOS_CALL dos_qguiapplication_process_events_timed(DosQEventLoopProcessEventFlag flags, int ms);

DOS_API void DOS_CALL dos_qguiapplication_enable_hdpi(const char *uiScaleFilePath);

DOS_API void DOS_CALL dos_qguiapplication_initialize_opengl(void);

DOS_API void DOS_CALL dos_qguiapplication_try_enable_threaded_renderer();

/// \brief Create a QGuiApplication
/// \note The created QGuiApplication should be freed by calling dos_qguiapplication_delete()
DOS_API void DOS_CALL dos_qguiapplication_create();

/// \brief Calls the QGuiApplication::exec() function of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_exec(void);

/// \brief Calls the QGuiApplication::quit() function of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_quit(void);

/// \brief Free the memory of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_delete(void);

DOS_API void DOS_CALL dos_qguiapplication_icon(const char *filename);

DOS_API void dos_qguiapplication_installEventFilter(DosEvent *vptr);

DOS_API void dos_qguiapplication_clipboard_setText(const char* text);

DOS_API char* dos_qguiapplication_clipboard_getText();

DOS_API void dos_qguiapplication_clipboard_setImage(const char *text);

DOS_API void dos_qguiapplication_clipboard_setImageByUrl(const char *url);

DOS_API void dos_qguiapplication_download_image(const char *imageSource, const char* filePath);

DOS_API void dos_qguiapplication_download_imageByUrl(const char *url, const char* filePath);

/// \brief Calls the QGuiApplication::exec() function of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_exec(void);

/// \brief Invokes a QObject's slot by passing a string containing a signal
/// \note This method was created because status-go has a non-QT event loop
DOS_API void DOS_CALL dos_signal(DosQObject *vptr, const char *signal, const char *slot);

DOS_API DosQNetworkConfigurationManager *DOS_CALL dos_qncm_create();

DOS_API char * DOS_CALL dos_plain_text(char* htmlString);

DOS_API char * DOS_CALL dos_escape_html(char* input);

DOS_API void DOS_CALL dos_qncm_delete(DosQNetworkConfigurationManager *vptr);

DOS_API char * DOS_CALL dos_image_resizer(const char* imagePathOrData, int maxSize, const char* tmpDirPath);

DOS_API char * DOS_CALL dos_qurl_fromUserInput(char* input);

DOS_API char * DOS_CALL dos_qurl_host(char* host);

DOS_API char * DOS_CALL dos_qurl_replaceHostAndAddPath(char* url, char* newScheme, char* newHost, char* pathPrefix);

/// \brief Sets the application icon
DOS_API void DOS_CALL dos_qguiapplication_icon(const char *filename);

/// \brief Calls the QGuiApplication::quit() function of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_quit(void);

/// \brief Free the memory of the current QGuiApplication
/// \note A QGuiApplication should have been already created through dos_qguiapplication_create()
DOS_API void DOS_CALL dos_qguiapplication_delete(void);

/// @}

/// \defgroup QQmlApplicationEngine QQmlApplicationEngine
/// \brief Functions related to the QQmlApplicationEngine class
/// @{

/// \brief Create a new QQmlApplicationEngine
/// \return A new QQmlApplicationEngine
/// \note The returned QQmlApplicationEngine should be freed by using dos_qqmlapplicationengine_delete(DosQQmlApplicationEngine*)
DOS_API DosQQmlApplicationEngine *DOS_CALL dos_qqmlapplicationengine_create(void);

DOS_API DosQQmlNetworkAccessManagerFactory *DOS_CALL dos_qqmlnetworkaccessmanagerfactory_create(const char* tmpPath);
DOS_API void DOS_CALL dos_qqmlnetworkaccessmanager_clearconnectioncache(DosQQmlNetworkAccessManager *vptr);
DOS_API void DOS_CALL dos_qqmlnetworkaccessmanager_setnetworkaccessible(DosQQmlNetworkAccessManager *vptr, int accessibility);

DOS_API void DOS_CALL dos_add_self_signed_certificate(const char* pemCertificateContent);

/// \brief Calls the QQmlApplicationEngine::load function
/// \param vptr The QQmlApplicationEngine
/// \param filename The file to load. The file is relative to the directory that contains the application executable
DOS_API void DOS_CALL dos_qqmlapplicationengine_load(DosQQmlApplicationEngine *vptr, const char *filename);

/// \brief Calls the QQmlApplicationEngine::networkAccessManager function
/// \param vptr The QQmlApplicationEngine
/// \return A pointer to a QQmlNetworkAccessManager.
DOS_API DosQQmlNetworkAccessManager DOS_CALL dos_qqmlapplicationengine_getNetworkAccessManager(DosQQmlApplicationEngine *vptr);
DOS_API void DOS_CALL dos_qqmlapplicationengine_setNetworkAccessManagerFactory(DosQQmlApplicationEngine *vptr, DosQQmlNetworkAccessManagerFactory *factory);

/// \brief Calls the QQmlApplicationEngine::load function
/// \param vptr The QQmlApplicationEngine
/// \param url The QUrl of the file to load
DOS_API void DOS_CALL dos_qqmlapplicationengine_load_url(DosQQmlApplicationEngine *vptr, DosQUrl *url);

/// \brief Calls the QQmlApplicationEngine::loadData function
/// \param vptr The QQmlApplicationEngine
/// \param data The UTF-8 string of the QML to load
DOS_API void DOS_CALL dos_qqmlapplicationengine_load_data(DosQQmlApplicationEngine *vptr, const char *data);

/// \brief Calls the load and install function for translations and calls retranslate on QQmlApplicationEngine
/// \param vptr The QQmlApplicationEngine
/// \param data The UTF-8 string of the path to the translation file (.qm)
/// \param shouldRetranslate Should retranslate() be called after loading a translation
DOS_API void DOS_CALL dos_qguiapplication_load_translation(DosQQmlApplicationEngine *vptr, const char* translationPackage, bool shouldRetranslate);

/// \brief Calls the QQmlApplicationEngine::addImportPath function
/// \param vptr The QQmlApplicationEngine
/// \param path The path to be added to the list of import paths
DOS_API void DOS_CALL dos_qqmlapplicationengine_add_import_path(DosQQmlApplicationEngine *vptr, const char *path);

/// \brief Calls the QQmlApplicationEngine::context
/// \param vptr The QQmlApplicationEngine
/// \return A pointer to a QQmlContext. This should not be stored nor made available to the binded language if
/// you can't guarantee that this QQmlContext should not live more that its Engine. This context is owned by
/// the engine and so it should die with the engine.
DOS_API DosQQmlContext *DOS_CALL dos_qqmlapplicationengine_context(DosQQmlApplicationEngine *vptr);

/// \brief Calls the QQMLApplicationengine::addImageProvider
/// \param vptr The QQmlApplicationEngine
/// \param vptr_i A QQuickImageProvider, the QQmlApplicationEngine takes ownership of this pointer
DOS_API void DOS_CALL dos_qqmlapplicationengine_addImageProvider(DosQQmlApplicationEngine *vptr, const char* name, DosQQuickImageProvider *vptr_i);

/// \brief Free the memory allocated for the given QQmlApplicationEngine
/// \param vptr The QQmlApplicationEngine
DOS_API void DOS_CALL dos_qqmlapplicationengine_delete(DosQQmlApplicationEngine *vptr);

/// @}

/// \defgroup QQuickImageProvider QQuickImageProvider
/// \brief Functions related to the QQuickImageProvider class
/// @{

/// \brief Create a new QQuickImageProvider
/// \return A new QQuickImageProvider
/// \note The returned QQuickImageProvider should be freed by using dos_qquickimageprovider_delete(DosQQuickImageProvider*) unless the QQuickImageProvider has been bound to a QQmlApplicationEngine
DOS_API DosQQuickImageProvider *DOS_CALL dos_qquickimageprovider_create(RequestPixmapCallback callback);
/// \breif Frees a QQuickImageProvider
DOS_API void DOS_CALL dos_qquickimageprovider_delete(DosQQuickImageProvider *vptr);
/// @}

/// \defgroup QPixmap QPixmap
/// \brief Functions related to the QPixmap class
/// @{

/// \brief Creates a null QPixmap
DOS_API DosPixmap *DOS_CALL dos_qpixmap_create();
/// \brief Creates a QPixmap copied from another
DOS_API DosPixmap *DOS_CALL dos_qpixmap_create_qpixmap(const DosPixmap* other);
/// \brief Create a new QPixmap
DOS_API DosPixmap *DOS_CALL dos_qpixmap_create_width_and_height(int width, int height);
/// \brief Frees a QPixmap
DOS_API void DOS_CALL dos_qpixmap_delete(DosPixmap *vptr);
/// \brief Load image data into a QPixmap from an image file
DOS_API void DOS_CALL dos_qpixmap_load(DosPixmap *vptr, const char* filepath, const char* format);
/// \brief Load image data into a QPixmap from a buffer
DOS_API void DOS_CALL dos_qpixmap_loadFromData(DosPixmap *vptr, const unsigned char* data, unsigned int len);
/// \brief Fill a QPixmap with a single color
DOS_API void DOS_CALL dos_qpixmap_fill(DosPixmap *vptr, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
/// \brief Calls the QPixmap::operator=(const QPixmap&) function
/// \param vptr The left hand side QPixmap
/// \param other The right hand side QPixmap
DOS_API void DOS_CALL dos_qpixmap_assign(DosPixmap *vptr, const DosPixmap* other);
/// \brief Calls the QPixmap::isNull
/// \return True if the QPixmap is null, false otherwise
DOS_API bool DOS_CALL dos_qpixmap_isNull(DosPixmap *vptr);
/// @}


/// \defgroup QQuickStyle QQuickStyle
/// \brief Functions related to the QQuickStyle class
/// @{

/// \brief Set the QtQuickControls2 style
DOS_API void DOS_CALL dos_qquickstyle_set_style(const char *style);

/// \brief Set the QtQuickControls2 fallback style
DOS_API void DOS_CALL dos_qquickstyle_set_fallback_style(const char *style);

/// @}



/// \defgroup QQuickView QQuickView
/// \brief Functions related to the QQuickView class
/// @{

/// \brief Create a new QQuickView
/// \return A new QQuickView
/// \note The returned QQuickView should be freed by using dos_qquickview_delete(DosQQuickview*)
DOS_API DosQQuickView *DOS_CALL dos_qquickview_create(void);

/// \brief Calls the QQuickView::show() function
/// \param vptr The QQuickView
DOS_API void  DOS_CALL dos_qquickview_show(DosQQuickView *vptr);

/// \brief Calls the QQuickView::source() function
/// \param vptr The QQuickView
/// \return The QQuickView source as an UTF-8 string
/// \note The returned string should be freed by using the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qquickview_source(const DosQQuickView *vptr);

/// \brief Calls the QQuickView::setSource() function
/// \param vptr The QQuickView
/// \param url The source QUrl
DOS_API void DOS_CALL dos_qquickview_set_source_url(DosQQuickView *vptr, DosQUrl *url);

/// \brief Calls the QQuickView::setSource() function
/// \param vptr The QQuickView
/// \param filename The source path as an UTF-8 string. The path is relative to the directory
///  that contains the application executable
DOS_API void DOS_CALL dos_qquickview_set_source(DosQQuickView *vptr, const char *filename);

/// \brief Calls the QQuickView::setResizeMode() function
/// \param vptr The QQuickView
/// \param resizeMode The resize mode
DOS_API void DOS_CALL dos_qquickview_set_resize_mode(DosQQuickView *vptr, int resizeMode);

/// \brief Free the memory allocated for the given QQuickView
/// \param vptr The QQuickView
DOS_API void DOS_CALL dos_qquickview_delete(DosQQuickView *vptr);

/// \brief Return the QQuickView::rootContext() as a QQuickContext
/// \param vptr The QQuickView
DOS_API DosQQmlContext *DOS_CALL dos_qquickview_rootContext(DosQQuickView *vptr);

/// @}

/// \defgroup QQmlContext QQmlContext
/// \brief Functions related to the QQmlContext class
/// @{

/// \brief Calls the QQmlContext::baseUrl function
/// \return The QQmlContext url as an UTF-8 string
/// \note The returned string should be freed using with the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qqmlcontext_baseUrl(const DosQQmlContext *vptr);

/// \brief Sets a property inside the context
/// \param vptr The DosQQmlContext
/// \param name The property name. The string is owned by the caller thus it will not be deleted by the library
/// \param value The property value. The DosQVariant is owned by the caller thus it will not be deleted by the library
DOS_API void DOS_CALL dos_qqmlcontext_setcontextproperty(DosQQmlContext *vptr, const char *name, DosQVariant *value);

/// @}

/// \defgroup String String
/// \brief Functions related to strings
/// @{

/// \brief Free the memory allocated for the given UTF-8 string
/// \param ptr The UTF-8 string to be freed
DOS_API void DOS_CALL dos_chararray_delete(char *ptr);

/// @}


/// \defgroup QVariant QVariant
/// \brief Functions related to the QVariant class
/// @{

/// Delete a DosQVariantArray
DOS_API void DOS_CALL dos_qvariantarray_delete(DosQVariantArray *ptr);

/// \brief Create a new QVariant (null)
/// \return The a new QVariant
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create(void);

/// \brief Create a new QVariant holding an int value
/// \return The a new QVariant
/// \param value The int value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_int(int value);

/// \brief Create a new QVariant holding a long long value
/// \return The a new QVariant
/// \param value The value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_longlong(long long value);

/// \brief Create a new QVariant holding an usigned long long value
/// \return The a new QVariant
/// \param value The value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_ulonglong(unsigned long long value);

/// \brief Create a new QVariant holding a bool value
/// \return The a new QVariant
/// \param value The bool value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_bool(bool value);

/// \brief Create a new QVariant holding a string value
/// \return The a new QVariant
/// \param value The string value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
/// \note The given string is copied inside the QVariant and will not be deleted
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_string(const char *value);

/// \brief Create a new QVariant holding a QObject value
/// \return The a new QVariant
/// \param value The QObject value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_qobject(DosQObject *value);

/// \brief Create a new QVariant with the same value of the one given as argument
/// \return The a new QVariant
/// \param value The QVariant to which copy its value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_qvariant(const DosQVariant *value);

/// \brief Create a new QVariant holding a float value
/// \return The a new QVariant
/// \param value The float value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_float(float value);

/// \brief Create a new QVariant holding a double value
/// \return The a new QVariant
/// \param value The double value
/// \note The returned QVariant should be freed using dos_qvariant_delete()
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_double(double value);

/// \brief Create a new QVariant holding a QVariantList
/// \return A new QVariant
/// \param size The size of the QVariant array
/// \param array The array of QVariant that will be inserted in the inner QVariantList
/// \note The \p array is owned by the caller thus it will not be deleted
DOS_API DosQVariant *DOS_CALL dos_qvariant_create_array(int size, DosQVariant **array);

/// \brief Calls the QVariant::setValue<int>() function
/// \param vptr The QVariant
/// \param value The int value
DOS_API void DOS_CALL dos_qvariant_setInt(DosQVariant *vptr, int value);

/// \brief Calls the QVariant::setValue<long long>() function
/// \param vptr The QVariant
/// \param value The long long value
DOS_API void DOS_CALL dos_qvariant_setLongLong(DosQVariant *vptr, long long value);

/// \brief Calls the QVariant::setValue<unsigned long long>() function
/// \param vptr The QVariant
/// \param value The unsigned long long value
DOS_API void DOS_CALL dos_qvariant_setULongLong(DosQVariant *vptr, unsigned long long value);

/// \brief Calls the QVariant::setValue<bool>() function
/// \param vptr The QVariant
/// \param value The bool value
DOS_API void DOS_CALL dos_qvariant_setBool(DosQVariant *vptr, bool value);

/// \brief Calls the QVariant::setValue<float>() function
/// \param vptr The QVariant
/// \param value The float value
DOS_API void DOS_CALL dos_qvariant_setFloat(DosQVariant *vptr, float value);

/// \brief Calls the QVariant::setValue<double>() function
/// \param vptr The QVariant
/// \param value The double value
DOS_API void DOS_CALL dos_qvariant_setDouble(DosQVariant *vptr, double value);

/// \brief Calls the QVariant::setValue<QString>() function
/// \param vptr The QVariant
/// \param value The string value
/// \note The string argument is copied inside the QVariant and it will not be deleted
DOS_API void DOS_CALL dos_qvariant_setString(DosQVariant *vptr, const char *value);

/// \brief Calls the QVariant::setValue<QObject*>() function
/// \param vptr The QVariant
/// \param value The string value
/// \note The string argument is copied inside the QVariant and it will not be deleted
DOS_API void DOS_CALL dos_qvariant_setQObject(DosQVariant *vptr, DosQObject *value);

/// \brief Calls the QVariant::setValue<QVariantList>() function
/// \param vptr The QVariant
/// \param size The size of the \p array
/// \param array The array of QVariant use for setting the inner QVariantList
DOS_API void DOS_CALL dos_qvariant_setArray(DosQVariant *vptr, int size, DosQVariant **array);

/// \brief Calls the QVariant::isNull function
/// \return True if the QVariant is null, false otherwise
/// \param vptr The QVariant
DOS_API bool DOS_CALL dos_qvariant_isnull(const DosQVariant *vptr);

/// \brief Free the memory allocated for the given QVariant
/// \param vptr The QVariant
DOS_API void DOS_CALL dos_qvariant_delete(DosQVariant *vptr);

/// \brief Calls the QVariant::operator=(const QVariant&) function
/// \param vptr The QVariant (left side)
/// \param other The QVariant (right side)
DOS_API void DOS_CALL dos_qvariant_assign(DosQVariant *vptr, const DosQVariant *other);

/// \brief Calls the QVariant::value<int>() function
/// \param vptr The QVariant
/// \return The int value
DOS_API int DOS_CALL dos_qvariant_toInt(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<long long>() function
/// \param vptr The QVariant
/// \return The int value
DOS_API long long DOS_CALL dos_qvariant_toLongLong(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<unsigned long long>() function
/// \param vptr The QVariant
/// \return The int value
DOS_API unsigned long long DOS_CALL dos_qvariant_toULongLong(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<bool>() function
/// \param vptr The QVariant
/// \return The bool value
DOS_API bool DOS_CALL dos_qvariant_toBool(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<QString>() function
/// \param vptr The QVariant
/// \return The string value
/// \note The returned string should be freed by using dos_chararray_delete()
DOS_API char *DOS_CALL dos_qvariant_toString(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<float>() function
/// \param vptr The QVariant
/// \return The float value
DOS_API float DOS_CALL dos_qvariant_toFloat (const DosQVariant *vptr);

/// \brief Calls the QVariant::value<double>() function
/// \param vptr The QVariant
/// \return The double value
DOS_API double DOS_CALL dos_qvariant_toDouble(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<QVariantList>() function
/// \param vptr The QVariant
/// \return The QVariantList value as an array
DOS_API DosQVariantArray *DOS_CALL dos_qvariant_toArray(const DosQVariant *vptr);

/// \brief Calls the QVariant::value<QObject*>() function
/// \param vptr The QVariant
/// \return The QObject* value
/// \note Storing the returned QObject* is higly dengerous and depends on how you managed the memory
/// of QObjects in the binded language
DOS_API DosQObject *DOS_CALL dos_qvariant_toQObject(const DosQVariant *vptr);

/// @}


/// \defgroup QMetaObject QMetaObject
/// \brief Functions related to the QMetaObject class
/// @{

/// \brief Create a new QMetaObject
/// \param superClassMetaObject The superclass metaobject
/// \param className The class name
/// \param signalDefinitions The SignalDefinitions
/// \param slotDefinitions The SlotDefinitions struct
/// \param propertyDefinitions The PropertyDefinitions struct
/// \note The returned QMetaObject should be freed using dos_qmetaobject_delete().
/// \attention The QMetaObject should live more than the QObject it refears to.
/// Depending on the implementation usually the QMetaObject should be modeled as static variable
/// So with a lifetime equals to the entire application
DOS_API DosQMetaObject *DOS_CALL dos_qmetaobject_create(DosQMetaObject *superClassMetaObject,
                                                        const char *className,
                                                        const SignalDefinitions *signalDefinitions,
                                                        const SlotDefinitions *slotDefinitions,
                                                        const PropertyDefinitions *propertyDefinitions);

/// \brief Free the memory allocated for the given QMetaObject
/// \param vptr The QMetaObject
DOS_API void DOS_CALL dos_qmetaobject_delete(DosQMetaObject *vptr);

/// @}

/// \defgroup QAbstractListModel QAbstractItemModel
/// \brief Functions related to the QAbstractListModel class
/// @{

/// \brief Return QMetaObject associated to the QAbstractListModel class
/// \return The QMetaObject of the QAbstractListModel class
/// \note The returned QMetaObject should be freed using dos_qmetaobject_delete().
DOS_API DosQMetaObject *DOS_CALL dos_qabstractlistmodel_qmetaobject(void);

/// \brief Create a new QAbstractListModel
/// \param callbackObject The pointer of QAbstractListModel in the binded language
/// \param metaObject The QMetaObject for this QAbstractListModel
/// \param dObjectCallback The callback for handling the properties read/write and slots execution
/// \param callbacks The QAbstractItemModel callbacks
DOS_API DosQAbstractListModel *DOS_CALL dos_qabstractlistmodel_create(void *callbackObject,
                                                                      DosQMetaObject *metaObject,
                                                                      DObjectCallback dObjectCallback,
                                                                      DosQAbstractItemModelCallbacks *callbacks);

/// \brief Calls the default QAbstractListModel::index() function
DOS_API DosQModelIndex *DOS_CALL dos_qabstractlistmodel_index(DosQAbstractListModel *vptr,
                                                              int row, int column, DosQModelIndex *parent);

/// \brief Calls the default QAbstractListModel::parent() function
DOS_API DosQModelIndex *DOS_CALL dos_qabstractlistmodel_parent(DosQAbstractListModel *vptr,
                                                               DosQModelIndex *child);

/// \brief Calls the default QAbstractListModel::columnCount() function
DOS_API int DOS_CALL dos_qabstractlistmodel_columnCount(DosQAbstractListModel *vptr,
                                                        DosQModelIndex *parent);

/// @}

/// \defgroup QAbstractTableModel QAbstractTableModel
/// \brief Functions related to the QAbstractTableModel class
/// @{

/// \brief Return QMetaObject associated to the QAbstractTableModel class
/// \return The QMetaObject of the QAbstractTableModel class
/// \note The returned QMetaObject should be freed using dos_qmetaobject_delete().
DOS_API DosQMetaObject *DOS_CALL dos_qabstracttablemodel_qmetaobject(void);

/// \brief Create a new QAbstractTableModel
/// \param callbackObject The pointer of QAbstractTableModel in the binded language
/// \param metaObject The QMetaObject for this QAbstractTableModel
/// \param dObjectCallback The callback for handling the properties read/write and slots execution
/// \param callbacks The QAbstractItemModel callbacks
DOS_API DosQAbstractTableModel *DOS_CALL dos_qabstracttablemodel_create(void *callbackObject,
                                                                        DosQMetaObject *metaObject,
                                                                        DObjectCallback dObjectCallback,
                                                                        DosQAbstractItemModelCallbacks *callbacks);

/// \brief Calls the default QAbstractTableModel::index() function
DOS_API DosQModelIndex *DOS_CALL dos_qabstracttablemodel_index(DosQAbstractTableModel *vptr,
                                                               int row, int column, DosQModelIndex *parent);

/// \brief Calls the default QAbstractTableModel::parent() function
DOS_API DosQModelIndex *DOS_CALL dos_qabstracttablemodel_parent(DosQAbstractTableModel *vptr,
                                                                DosQModelIndex *child);

/// @}

/// \defgroup QAbstractItemModel QAbstractItemModel
/// \brief Functions related to the QAbstractItemModel class
/// @{

/// \brief Return QMetaObject associated to the QAbstractItemModel class
/// \return The QMetaObject of the QAbstractItemModel class
/// \note The returned QMetaObject should be freed using dos_qmetaobject_delete().
DOS_API DosQMetaObject *DOS_CALL dos_qabstractitemmodel_qmetaobject(void);

/// \brief Create a new QAbstractItemModel
/// \param callbackObject The pointer of QAbstractItemModel in the binded language
/// \param metaObject The QMetaObject for this QAbstractItemModel
/// \param dObjectCallback The callback for handling the properties read/write and slots execution
/// \param callbacks The QAbstractItemModel callbacks
/// \note The callbacks struct is copied so you can freely delete after calling this function
DOS_API DosQAbstractItemModel *DOS_CALL dos_qabstractitemmodel_create(void *callbackObject,
                                                                      DosQMetaObject *metaObject,
                                                                      DObjectCallback dObjectCallback,
                                                                      DosQAbstractItemModelCallbacks *callbacks);

/// \brief Calls the QAbstractItemModel::setData function
DOS_API bool DOS_CALL dos_qabstractitemmodel_setData(DosQAbstractItemModel *vptr, DosQModelIndex *index, DosQVariant *data, int role);

/// \brief Calls the QAbstractItemModel::roleNames function
DOS_API DosQHashIntQByteArray *DOS_CALL dos_qabstractitemmodel_roleNames(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::flags function
DOS_API int DOS_CALL dos_qabstractitemmodel_flags(DosQAbstractItemModel *vptr, DosQModelIndex *index);

/// \brief Calls the QAbstractItemModel::headerData function
DOS_API DosQVariant *DOS_CALL dos_qabstractitemmodel_headerData(DosQAbstractItemModel *vptr, int section, int orientation, int role);

/// \brief Calls the QAbstractItemModel::hasChildren function
DOS_API bool DOS_CALL dos_qabstractitemmodel_hasChildren(DosQAbstractItemModel *vptr, DosQModelIndex *parentIndex);

/// \brief Calls the QAbstractItemModel::hasIndex function
DOS_API bool DOS_CALL dos_qabstractitemmodel_hasIndex(DosQAbstractItemModel *vptr, int row, int column, DosQModelIndex *dosParentIndex);

/// \brief Calls the QAbstractItemModel::canFetchMore function
DOS_API bool DOS_CALL dos_qabstractitemmodel_canFetchMore(DosQAbstractItemModel *vptr, DosQModelIndex *parentIndex);

/// \brief Calls the QAbstractItemModel::fetchMore function
DOS_API void DOS_CALL dos_qabstractitemmodel_fetchMore(DosQAbstractItemModel *vptr, DosQModelIndex *parentIndex);

/// \brief Calls the QAbstractItemModel::beginInsertRows() function
/// \param vptr The QAbstractItemModel
/// \param parent The parent QModelIndex
/// \param first The first row in the range
/// \param last The last row in the range
/// \note The \p parent QModelIndex is owned by the caller thus it will not be deleted
DOS_API void DOS_CALL dos_qabstractitemmodel_beginInsertRows(DosQAbstractItemModel *vptr, DosQModelIndex *parent, int first, int last);

/// \brief Calls the QAbstractItemModel::endInsertRows() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_endInsertRows(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::beginRemovetRows() function
/// \param vptr The QAbstractItemModel
/// \param parent The parent QModelIndex
/// \param first The first column in the range
/// \param last The last column in the range
/// \note The \p parent QModelIndex is owned by the caller thus it will not be deleted
DOS_API void DOS_CALL dos_qabstractitemmodel_beginRemoveRows(DosQAbstractItemModel *vptr, DosQModelIndex *parent, int first, int last);

/// \brief Calls the QAbstractItemModel::endRemoveRows() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_endRemoveRows(DosQAbstractItemModel *vptr);

DOS_API void DOS_CALL dos_qabstractitemmodel_beginMoveRows(DosQAbstractItemModel *vptr, DosQModelIndex *sourceParent, int sourceFirst, int sourceLast,
                                                           DosQModelIndex *destinationParent, int destinationChild);
DOS_API void DOS_CALL dos_qabstractitemmodel_endMoveRows(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::beginInsertColumns() function
/// \param vptr The QAbstractItemModel
/// \param parent The parent QModelIndex
/// \param first The first column in the range
/// \param last The last column in the range
/// \note The \p parent QModelIndex is owned by the caller thus it will not be deleted
DOS_API void DOS_CALL dos_qabstractitemmodel_beginInsertColumns(DosQAbstractItemModel *vptr, DosQModelIndex *parent, int first, int last);

/// \brief Calls the QAbstractItemModel::endInsertColumns() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_endInsertColumns(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::beginRemovetColumns() function
/// \param vptr The QAbstractItemModel
/// \param parent The parent QModelIndex
/// \param first The first column in the range
/// \param last The last column in the range
/// \note The \p parent QModelIndex is owned by the caller thus it will not be deleted
DOS_API void DOS_CALL dos_qabstractitemmodel_beginRemoveColumns(DosQAbstractItemModel *vptr, DosQModelIndex *parent, int first, int last);

/// \brief Calls the QAbstractItemModel::endRemoveColumns() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_endRemoveColumns(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::beginResetModel() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_beginResetModel(DosQAbstractItemModel *vptr);

/// \brief Calls the QAbstractItemModel::endResetModel() function
/// \param vptr The QAbstractItemModel
DOS_API void DOS_CALL dos_qabstractitemmodel_endResetModel(DosQAbstractItemModel *vptr);

/// \brief Emit the dataChanged signal
/// \param vptr The DosQAbstractItemModel pointer
/// \param topLeft The topLeft DosQModelIndex
/// \param bottomRight The bottomright DosQModelIndex
/// \param rolesPtr The roles array
/// \param rolesLength The roles array length
/// \note The \p topLeft, \p bottomRight and \p rolesPtr arguments are owned by the caller thus they will not be deleted
DOS_API void DOS_CALL dos_qabstractitemmodel_dataChanged(DosQAbstractItemModel *vptr,
                                                         const DosQModelIndex *topLeft,
                                                         const DosQModelIndex *bottomRight,
                                                         int *rolesPtr, int rolesLength);

/// \brief Calls the QAbstractItemModel::createIndex() function
DOS_API DosQModelIndex *DOS_CALL dos_qabstractitemmodel_createIndex(DosQAbstractItemModel *vptr,
                                                                    int row, int column, void *data);


/// \brief Calls the default QAbstractItemModel::setData() function
DOS_API bool DOS_CALL dos_qabstractitemmodel_setData(DosQAbstractItemModel *vptr,
                                                     DosQModelIndex *index, DosQVariant *value, int role);

/// \brief Calls the default QAbstractItemModel::roleNames() function
DOS_API DosQHashIntQByteArray *DOS_CALL dos_qabstractitemmodel_roleNames(DosQAbstractItemModel *vptr);

/// \brief Calls the default QAbstractItemModel::flags() function
DOS_API int DOS_CALL dos_qabstractitemmodel_flags(DosQAbstractItemModel *vptr,
                                                  DosQModelIndex *index);

/// \brief Calls the default QAbstractItemModel::headerData() function
DOS_API DosQVariant *DOS_CALL dos_qabstractitemmodel_headerData(DosQAbstractItemModel *vptr,
                                                                int section, int orientation, int role);

/// @}


/// \defgroup QObject QObject
/// \brief Functions related to the QObject class
/// @{

/// \brief Return QMetaObject associated to the QObject class
/// \return The QMetaObject of the QObject class
/// \note The returned QObject should be freed using dos_qmetaobject_delete().
DOS_API DosQMetaObject *DOS_CALL dos_qobject_qmetaobject(void);

/// \brief Create a new QObject
/// \param dObjectPointer The pointer of the QObject in the binded language
/// \param metaObject The QMetaObject associated to the given QObject
/// \param dObjectCallback The callback called from QML whenever a slot or property
/// should be in read, write or invoked
/// \return A new QObject
/// \note The returned QObject should be freed by calling dos_qobject_delete()
/// \note The \p dObjectPointer is usefull for forwarding a property read/slot to the correct
/// object in the binded language in the callback
DOS_API DosQObject *DOS_CALL dos_qobject_create(void *dObjectPointer,
                                                DosQMetaObject *metaObject,
                                                DObjectCallback dObjectCallback);

/// \brief Emit a signal definited in a QObject
/// \param vptr The QObject
/// \param name The signal name
/// \param parametersCount The number of parameters in the \p parameters array
/// \param parameters An array of DosQVariant with the values of signal arguments
DOS_API void DOS_CALL dos_qobject_signal_emit(DosQObject *vptr,
                                              const char *name,
                                              int parametersCount,
                                              void **parameters);

DOS_API bool DOS_CALL dos_qobject_signal_connect(DosQObject *senderVPtr,
                                                 const char *signal,
                                                 DosQObject *receiverVPtr,
                                                 const char *method,
                                                 int type);

DOS_API bool DOS_CALL dos_qobject_signal_disconnect(DosQObject *senderVPtr,
                                                    const char *signal,
                                                    DosQObject *receiverVPtr,
                                                    const char *method);

/// \brief Return the DosQObject objectName
/// \param vptr The DosQObject pointer
/// \return A string in UTF8 format
/// \note The returned string should be freed using the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qobject_objectName(const DosQObject *vptr);

/// \brief Calls the QObject::setObjectName() function
/// \param vptr The QObject
/// \param name A pointer to an UTF-8 string
/// \note The \p name string is owned by the caller thus it will not be deleted
DOS_API void DOS_CALL dos_qobject_setObjectName(DosQObject *vptr, const char *name);

/// \brief Free the memory allocated for the QObject
/// \param vptr The QObject
DOS_API void DOS_CALL dos_qobject_delete(DosQObject *vptr);

/// \brief Free the memory allocated for the QObject in the next event loop cycle
/// \param vptr The QObject
DOS_API void DOS_CALL dos_qobject_deleteLater(DosQObject *vptr);

/// \brief Read Value of a property by its name
/// \param vptr The QObject
/// \param propertyName the Name of the property to be read
/// \returns Value of the given property
/// \note returns an empty QVariant if the propertyName does not exist
DOS_API DosQVariant *DOS_CALL dos_qobject_property(DosQObject *vptr,
                                                   const char *propertyName);

/// \brief Write Value to a property by its name
/// \param vptr The QObject
/// \param propertyName The Name of the property to be written
/// \param value The value to be written
/// \return Result as bool
DOS_API bool DOS_CALL dos_qobject_setProperty(DosQObject *vptr,
                                               const char *propertyName,
                                               DosQVariant *value);
/// @}


/// \defgroup QModelIndex QModelIndex
/// \brief Functions related to the QModelIndex class
/// @{

/// \brief Create a new QModelIndex()
/// \note The returned QModelIndex should be freed by calling the dos_qmodelindex_delete() function
DOS_API DosQModelIndex *DOS_CALL dos_qmodelindex_create(void);

/// \brief Create a new QModelIndex() copy constructed with given index
/// \note The returned QModelIndex should be freed by calling the dos_qmodelindex_delete() function
DOS_API DosQModelIndex *DOS_CALL dos_qmodelindex_create_qmodelindex(DosQModelIndex *index);

/// \brief Free the memory allocated for the QModelIndex
/// \param vptr The QModelIndex
DOS_API void DOS_CALL dos_qmodelindex_delete (DosQModelIndex *vptr);

/// \brief Calls the QModelIndex::row() function
/// \param vptr The QModelIndex
/// \return The QModelIndex row
DOS_API int  DOS_CALL dos_qmodelindex_row    (const DosQModelIndex *vptr);

/// \brief Calls the QModelIndex::column() function
/// \param vptr The QModelIndex
/// \return The QModelIndex column
DOS_API int  DOS_CALL dos_qmodelindex_column (const DosQModelIndex *vptr);

/// \brief Calls the QModelIndex::isvalid() function
/// \param vptr The QModelIndex
/// \return True if the QModelIndex is valid, false otherwise
DOS_API bool DOS_CALL dos_qmodelindex_isValid(const DosQModelIndex *vptr);

/// \brief Calls the QModelIndex::data() function
/// \param vptr The QModelIndex
/// \param role The model role to which we want the data
/// \return The QVariant associated at the given role
/// \note The returned QVariant should be freed by calling the dos_qvariant_delete() function
DOS_API DosQVariant *DOS_CALL dos_qmodelindex_data (const DosQModelIndex *vptr, int role);

/// \brief Calls the QModelIndex::parent() function
/// \param vptr The QModelIndex
/// \return The model parent QModelIndex
/// \note The returned QModelIndex should be freed by calling the dos_qmodelindex_delete() function
DOS_API DosQModelIndex *DOS_CALL dos_qmodelindex_parent (const DosQModelIndex *vptr);

/// \brief Calls the QModelIndex::child() function
/// \param vptr The QModelIndex
/// \param row The child row
/// \param column The child column
/// \return The model child QModelIndex at the given \p row and \p column
/// \note The returned QModelIndex should be freed by calling the dos_qmodelindex_delete() function
DOS_API DosQModelIndex *DOS_CALL dos_qmodelindex_child  (const DosQModelIndex *vptr, int row, int column);

/// \brief Calls the QModelIndex::sibling() function
/// \param vptr The QModelIndex
/// \param row The sibling row
/// \param column The sibling column
/// \return The model sibling QModelIndex at the given \p row and \p column
/// \note The returned QModelIndex should be freed by calling the dos_qmodelindex_delete() function
DOS_API DosQModelIndex *DOS_CALL dos_qmodelindex_sibling(const DosQModelIndex *vptr, int row, int column);

/// \brief Calls the QModelIndex::operator=(const QModelIndex&) function
/// \param l The left side QModelIndex
/// \param r The right side QModelIndex
DOS_API void DOS_CALL dos_qmodelindex_assign(DosQModelIndex *l, const DosQModelIndex *r);

/// \brief Calls the QModelIndex::internalPointer function
/// \param vptr The QModelIndex
/// \return The internal pointer
DOS_API void* DOS_CALL dos_qmodelindex_internalPointer(DosQModelIndex *vptr);


/// @}

/// \defgroup QHash QHash
/// \brief Functions related to the QHash class
/// @{

/// \brief Create a new QHash<int, QByteArray>
/// \return A new QHash<int, QByteArray>
/// \note The retuned QHash<int, QByteArray> should be freed using
/// the dos_qhash_int_qbytearray_delete(DosQHashIntQByteArray *) function
DOS_API DosQHashIntQByteArray *DOS_CALL dos_qhash_int_qbytearray_create(void);

/// \brief Free the memory allocated for the QHash<int, QByteArray>
/// \param vptr The QHash<int, QByteArray>
DOS_API void  DOS_CALL dos_qhash_int_qbytearray_delete(DosQHashIntQByteArray *vptr);

/// \brief Calls the QHash<int, QByteArray>::insert() function
/// \param vptr The QHash<int, QByteArray>
/// \param key The key
/// \param value The UTF-8 string
/// \note The \p value string is owned by the caller thus it will not be freed
DOS_API void  DOS_CALL dos_qhash_int_qbytearray_insert(DosQHashIntQByteArray *vptr, int key, const char *value);

/// \brief Calls the QHash<int, QByteArray>::value() function
/// \param vptr The QHash<int, QByteArray>
/// \param key The key to which retrive the value
/// \return The UTF-8 string associated to the given value
/// \note The returned string should be freed by calling the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qhash_int_qbytearray_value(const DosQHashIntQByteArray *vptr, int key);

/// @}

/// \defgroup QResource QResource
/// \brief Functions related to the QResource class
/// @{

/// Register the given .rcc (compiled) file in the resource system
DOS_API void DOS_CALL dos_qresource_register(const char *filename);

/// @}

/// \defgroup QUrl QUrl
/// \brief Functions related to the QUrl class
/// @{

/// \brief Create a new QUrl
/// \param url The UTF-8 string that represents an url
/// \param parsingMode The parsing mode
/// \note The retuned QUrl should be freed using the dos_qurl_delete() function
DOS_API DosQUrl *DOS_CALL dos_qurl_create(const char *url, int parsingMode);

/// \brief Free the memory allocated for the QUrl
/// \param vptr The QUrl to be freed
DOS_API void DOS_CALL dos_qurl_delete(DosQUrl *vptr);

/// \brief Calls the QUrl::toString() function
/// \param vptr The QUrl
/// \return The url as an UTF-8 string
/// \note The returned string should be freed using the dos_chararray_delete() function
DOS_API char *DOS_CALL dos_qurl_to_string(const DosQUrl *vptr);

/// \brief Class the QUrl::isValid() function
/// \param vptr The QUrl
/// \return True if the QUrl is valid, false otherwise
DOS_API bool dos_qurl_isValid(const DosQUrl *vptr);

/// @}

/// \defgroup QDeclarative QDeclarative
/// \brief Functions related to the QDeclarative module
/// @{

/// \brief Register a type in order to be instantiable from QML
/// \return An integer value that represents the registration ID in the
/// qml environment
/// \note The \p qmlRegisterType is owned by the caller thus it will not be freed
DOS_API int DOS_CALL dos_qdeclarative_qmlregistertype(const QmlRegisterType *qmlRegisterType);

/// \brief Register a singleton type in order to be accessible from QML
/// \return An integer value that represents the registration ID in the
/// \note The \p qmlRegisterType is owned by the caller thus it will not be freed
DOS_API int DOS_CALL dos_qdeclarative_qmlregistersingletontype(const QmlRegisterType *qmlRegisterType);

/// @}

/// \defgroup SingleInstance SingleInstance
/// \brief Functions related to the SingleInstance cclass
/// @{

/// \brief Create a new SingleInstance class
/// \param uniqueName The UTF-8 string for QLocalServer name
/// \param eventStr A custom string to be passed to the already running instance if detected
/// \note The returned SingleInstance should be freed using the dos_singleinstance_delete() function
DOS_API DosSingleInstance *DOS_CALL dos_singleinstance_create(const char *uniqueName, const char *eventStr);

/// \brief Returns bool indicating whether this is the first instance or not
/// \returns true if this is the first instance
/// \param vptr The SingleInstance
DOS_API bool DOS_CALL dos_singleinstance_isfirst(DosSingleInstance *vptr);

/// \brief Free the memory allocated for the SingleInstance
/// \param vptr The SingleInstance to be freed
DOS_API void DOS_CALL dos_singleinstance_delete(DosSingleInstance *vptr);

/// @}

#pragma region Events exposed methods

DOS_API DosEvent* dos_event_create_showAppEvent(DosQQmlApplicationEngine* vptr);
DOS_API DosEvent* dos_event_create_osThemeEvent(DosQQmlApplicationEngine* vptr);
DOS_API DosEvent* dos_event_create_urlSchemeEvent();
DOS_API void dos_event_delete(DosEvent* vptr);

#pragma endregion

#pragma region OS notification exposed methods

DOS_API DosOSNotification* dos_osnotification_create();
DOS_API void dos_osnotification_show_notification(DosOSNotification* vptr, 
    const char* title, const char* message, const char* identifier);
DOS_API void dos_osnotification_show_badge_notification(DosOSNotification* vptr, int notificationsCount);
DOS_API void dos_osnotification_delete(DosOSNotification* vptr);

#pragma endregion

#pragma region QSettings

DOS_API DosQSettings* dos_qsettings_create(const char* fileName, int format);
DOS_API DosQVariant* dos_qsettings_value(DosQSettings* vptr, const char* key, 
    DosQVariant* defaultValue);
DOS_API void dos_qsettings_set_value(DosQSettings* vptr, const char* key, 
    DosQVariant* value);
DOS_API void dos_qsettings_remove(DosQSettings* vptr, const char* key);
DOS_API void dos_qsettings_delete(DosQSettings* vptr);
DOS_API void dos_qsettings_begin_group(DosQSettings* vptr, const char* group);
DOS_API void dos_qsettings_end_group(DosQSettings* vptr);

#pragma endregion

#pragma region QTimer

DOS_API DosQTimer *dos_qtimer_create();
DOS_API void dos_qtimer_delete(DosQTimer *vptr);
DOS_API void dos_qtimer_set_interval(DosQTimer *vptr, int interval);
DOS_API int dos_qtimer_interval(DosQTimer *vptr);
DOS_API void dos_qtimer_start(DosQTimer *vptr);
DOS_API void dos_qtimer_stop(DosQTimer *vptr);
DOS_API void dos_qtimer_set_single_shot(DosQTimer *vptr, bool singleShot);
DOS_API bool dos_qtimer_is_single_shot(DosQTimer *vptr);
DOS_API bool dos_qtimer_is_active(DosQTimer *vptr);

#pragma endregion

#pragma region KeychainManager exposed methods

DOS_API DosKeychainManager* dos_keychainmanager_create(const char* service, 
    const char* authenticationReason);
DOS_API char* dos_keychainmanager_read_data_sync(DosKeychainManager* vptr, 
    const char* key);
DOS_API void dos_keychainmanager_read_data_async(DosKeychainManager* vptr, 
    const char* key);
DOS_API void dos_keychainmanager_store_data_async(DosKeychainManager* vptr, 
    const char* key, const char* data);
DOS_API void dos_keychainmanager_delete_data_async(DosKeychainManager* vptr, 
    const char* key);
DOS_API void dos_keychainmanager_delete(DosKeychainManager* vptr);

#pragma endregion

#pragma region SoundManager exposed methods

DOS_API void dos_soundmanager_play_sound(const char* soundUrl);
DOS_API void dos_soundmanager_set_player_volume(int volume);
DOS_API void dos_soundmanager_stop_player();

#pragma endregion

DOS_API char *dos_to_local_file(const char* fileUrl);

DOS_API char *dos_from_local_file(const char* filePath);

DOS_API bool dos_app_is_active(DosQQmlApplicationEngine* vptr);
DOS_API void dos_app_make_it_active(DosQQmlApplicationEngine* vptr);

#ifdef __cplusplus
}
#endif

#endif // DOTHERSIDE_H
