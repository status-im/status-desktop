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
 * \file DOtherSideTypes.h
 * \brief The DOtherSide types
 *
 * This file contains all the type definitions for structs and callbacks
 * used by the DOtherSide library
 */

#ifndef DOTHERSIDETYPES_H
#define DOTHERSIDETYPES_H


#ifdef WIN32
#define DOS_CALL __cdecl
#else
#define DOS_CALL
#endif

#ifndef __cplusplus
#include <stdbool.h>
#endif

#ifdef __cplusplus
extern "C"
{
#endif

/// A pointer to a QVariant
typedef void DosQVariant;

/// A pointer to a QModelIndex
typedef void DosQModelIndex;

/// A pointer to a QAbstractItemModel
typedef void DosQAbstractItemModel;

/// A pointer to a QAbstractListModel
typedef void DosQAbstractListModel;

/// A pointer to a QAbstractTableModel
typedef void DosQAbstractTableModel;

/// A pointer to a QQmlApplicationEngine
typedef void DosQQmlApplicationEngine;

/// A pointer to a QQuickView
typedef void DosQQuickView;

/// A pointer to a QQmlContext
typedef void DosQQmlContext;

/// A pointer to a QHash<int,QByteArray>
typedef void DosQHashIntQByteArray;

/// A pointer to a QUrl
typedef void DosQUrl;

/// A pointer to a QMetaObject
typedef void DosQMetaObject;

/// A pointer to a QObject
typedef void DosQObject;

/// A pointer to a QQuickImageProvider
typedef void DosQQuickImageProvider;

/// A pointer to a QPixmap
typedef void DosPixmap;

/// A pixmap callback to be supplied to an image provider
/// \param id Image source id
/// \param width pointer to the width of the image
/// \param height pointer to the height of the image
/// \param requestedHeight sourceSize.height attribute
/// \param requestedWidth sourcesSize.width attribute
/// \param[out] result The result QPixmap. This should be assigned from the binded language
/// \note \p id is the trailing part of an image source url for example "image://<provider_id>/<id>
/// \note The \p result arg is an out parameter so it \b shouldn't be deleted. See the dos_qpixmap_assign
typedef void (DOS_CALL *RequestPixmapCallback)(const char *id, int *width, int *height, int requestedWidth, int requestedHeight, DosPixmap* result);

/// Called when a property is readed/written or a slot should be executed
/// \param self The pointer of QObject in the binded language
/// \param slotName The slotName as DosQVariant
/// \param argc The number of arguments
/// \param argv An array of DosQVariant pointers
/// \note The first argument of \p argv is always the return value of the called slot.
/// In other words the length of argv is always 1 + number of arguments of \p slotName.
/// The return value should be assigned and modified by calling the dos_qvariant_assign()
/// or other dos_qvariant_set... setters.
/// \note The \p slotName is owned by the library thus it \b shouldn't be deleted
/// \note The \p argv array is owned by the library thus it \b shouldn't be deleted
typedef void (DOS_CALL *DObjectCallback)(void *self, DosQVariant *slotName, int argc, DosQVariant **argv);

/// Called when the QAbstractItemModel::rowCount method must be executed
/// \param self The pointer of the QAbstractItemModel in the binded language
/// \param index The parent DosQModelIndex
/// \param[out] result The rowCount result. This must be deferenced and filled from the binded language
/// \note The \p parent QModelIndex is owned by the DOtherSide library thus it \b shouldn't be deleted
/// \note The \p result arg is an out parameter so it \b shouldn't be deleted
typedef void (DOS_CALL *RowCountCallback)(void *self, const DosQModelIndex *parent, int *result);

/// Called when the QAbstractItemModel::columnCount method must be executed
/// \param self The pointer to the QAbstractItemModel in the binded language
/// \param index The parent DosQModelIndex
/// \param[out] result The rowCount result. This must be deferenced and filled from the binded language
/// \note The \p parent QModelIndex is owned by the DOtherSide library thus it \b shouldn't be deleted
/// \note The \p result arg is an out parameter so it \b shouldn't be deleted
typedef void (DOS_CALL *ColumnCountCallback)(void *self, const DosQModelIndex *parent, int *result);

/// Called when the QAbstractItemModel::data method must be executed
/// \param self The pointer to the QAbstractItemModel in the binded language
/// \param index The DosQModelIndex to which we request the data
/// \param[out] result The DosQVariant result. This must be deferenced and filled from the binded language.
/// \note The \p index QModelIndex is owned by the DOtherSide library thus it \b shouldn't be deleted
/// \note The \p result arg is an out parameter so it \b shouldn't be deleted
typedef void (DOS_CALL *DataCallback)(void *self, const DosQModelIndex *index, int role, DosQVariant *result);

/// Called when the QAbstractItemModel::setData method must be executed
typedef void (DOS_CALL *SetDataCallback)(void *self, const DosQModelIndex *index, const DosQVariant *value, int role, bool *result);

/// Called when the QAbstractItemModel::roleNames method must be executed
typedef void (DOS_CALL *RoleNamesCallback)(void *self, DosQHashIntQByteArray *result);

/// Called when the QAbstractItemModel::flags method must be called
typedef void (DOS_CALL *FlagsCallback)(void *self, const DosQModelIndex *index, int *result);

/// Called when the QAbstractItemModel::headerData method must be called
typedef void (DOS_CALL *HeaderDataCallback)(void *self, int section, int orientation, int role, DosQVariant *result);

/// Called when the QAbstractItemModel::index method must be called
typedef void (DOS_CALL *IndexCallback)(void *self, int row, int column, const DosQModelIndex *parent, DosQModelIndex *result);

/// Called when the QAbstractItemModel::parent method must be called
typedef void (DOS_CALL *ParentCallback)(void *self, const DosQModelIndex *child, DosQModelIndex *result);

/// Called when the QAbstractItemModel::hasChildren method must be called
typedef void (DOS_CALL *HasChildrenCallback)(void *self, const DosQModelIndex *parent, bool *result);

/// Called when the QAbstractItemModel::canFetchMore method must be called
typedef void (DOS_CALL *CanFetchMoreCallback)(void *self, const DosQModelIndex *parent, bool *result);

/// Called when the QAbstractItemModel::fetchMore method must be called
typedef void (DOS_CALL *FetchMoreCallback)(void *self, const DosQModelIndex *parent);

/// Callback called from QML for creating a registered type
/**
 * When a type is created through the QML engine a new QObject \p "Wrapper" is created. This becomes a proxy
 * between the "default" QObject created through dos_qobject_create() and the QML engine. This imply that implementation
 * for this callback should swap the DosQObject* stored in the binded language with the wrapper. At the end the wrapper
 * becomes the owner of the original "default" DosQObject. Furthermore if the binding language is garbage collected you
 * should disable (pin/ref) the original object and unref in the DeleteDObject() callback. Since the wrapper has been created
 * from QML is QML that expect to free the memory for it thus it shouldn't be destroyed by the QObject in the binded language.
 *
 * An example of implementation in pseudocode is: \n
 * \code{.nim}
proc createCallback(.....) =
  # Call the constructor for the given type and create a QObject in Nim
  let nimQObject = constructorMap[id]()

  # Disable GC
  GC.ref(nimQObject)

  # Retrieve the DosQObject created dos_qobject_create() inside the nimQObject
  *dosQObject = nimQObject.vptr

  # Store the pointer to the nimQObject
  *bindedQObject = cast[ptr](&nimQObject)

  # Swap the vptr inside the nimQObject with the wrapper
  nimQObject.vptr = wrapper

  # The QObject in the Nim language should not destroy its inner DosQObject
  nimQObject.owner = false

\endcode

 * \param id This is the id for which we are requesting the creation.
 * This is the same value that was returned during registration through the calls
 * to dos_qdeclarative_qmlregistertype() or dos_qdeclarative_qmlregistersingletontype()
 * \param wrapper This is the QObject wrapper that should be stored by the binded language and to which forward the
 * DOtherSide calls
 * \param bindedQObject This should be deferenced and assigned with the pointer of the QObject modeled in the binded language
 * \param dosQObject This should be deferenced and assigned with the DosQObject pointer you gained from calling the dos_qobject_create() function
 */
typedef void (DOS_CALL *CreateDObject)(int id, void *wrapper, void **bindedQObject, void **dosQObject);

/// Callback invoked from QML for deleting a registered type
/**
 * This is called when the wrapper gets deleted from QML. The implementation should unref/unpin
 * the \p bindedQObject or delete it in the case of languages without GC
 * \param id This is the type id for which we are requesting the deletion
 * \param bindedQObject This is the pointer you given in the CreateDObject callback and you can use it
 * for obtaining the QObject in your binded language. This allows you to unpin/unref it or delete it.
 */
typedef void (DOS_CALL *DeleteDObject)(int id, void *bindedQObject);

/// \brief Store an array of QVariant
/// \note This struct should be freed by calling dos_qvariantarray_delete(DosQVariantArray *ptr). This in turn
/// cleans up the internal array
struct DosQVariantArray {
    /// The number of elements
    int size;
    /// The array
    DosQVariant **data;
};

#ifndef __cplusplus
typedef struct DosQVariantArray DosQVariantArray;
#endif

/// The data needed for registering a custom type in the QML environment
/**
 * This is used from dos_qdeclarative_qmlregistertype() and dos_qdeclarative_qmlregistersingletontype() calls.
 * \see dos_qdeclarative_qmlregistertype()
 * \see dos_qdeclarative_qmlregistersingletontype()
 * \note All string and objects are considered to be owned by the caller thus they'll
 * not be freed
*/
struct QmlRegisterType {
    /// The Module major version
    int major;
    /// The Module minor version
    int minor;
    /// The Module uri
    const char *uri;
    /// The type name to be used in QML files
    const char *qml;
    /// The type QMetaObject
    DosQMetaObject *staticMetaObject;
    /// The callback invoked from QML when this type should be created
    CreateDObject createDObject;
    /// The callback invoked from QML when this type should be deleted
    DeleteDObject deleteDObject;
};

#ifndef __cplusplus
typedef struct QmlRegisterType QmlRegisterType;
#endif

/// Represents a parameter definition
struct ParameterDefinition {
    /// The parameter name
    const char *name;
    /// The parameter metatype
    int metaType;
};

#ifndef __cplusplus
typedef struct ParameterDefinition ParameterDefinition;
#endif

/// Represents a single signal definition
struct SignalDefinition {
    /// The signal name
    const char *name;
    /// The parameters count
    int parametersCount;
    /// The parameters
    ParameterDefinition *parameters;
};

#ifndef __cplusplus
typedef struct SignalDefinition SignalDefinition;
#endif

/// Represents a set of signal definitions
struct SignalDefinitions {
    /// The total number of signals
    int count;
    /// The signals
    SignalDefinition *definitions;
};

#ifndef __cplusplus
typedef struct SignalDefinitions SignalDefinitions;
#endif

/// Represents a single slot definition
struct SlotDefinition {
    /// The slot name
    const char *name;
    /// The slot return type
    int returnMetaType;
    /// The parameters count
    int parametersCount;
    /// The parameters
    ParameterDefinition *parameters;
};

#ifndef __cplusplus
typedef struct SlotDefinition SlotDefinition;
#endif

/// Represents a set of slot definitions
struct SlotDefinitions {
    /// The total number of slots
    int count;
    /// The slot definitions array
    SlotDefinition *definitions;
};

#ifndef __cplusplus
typedef struct SlotDefinitions SlotDefinitions;
#endif

/// Represents a single property definition
struct PropertyDefinition {
    /// The property name
    const char *name;
    /// The property metatype
    int propertyMetaType;
    /// The name of the property read slot
    const char *readSlot;
    /// \brief The name of the property write slot
    /// \note Setting this to null means a readonly proeperty
    const char *writeSlot;
    /// \brief The name of the property notify signals
    /// \note Setting this to null means a constant property
    const char *notifySignal;
};

#ifndef __cplusplus
typedef struct PropertyDefinition PropertyDefinition;
#endif

/// Represents a set of property definitions
struct PropertyDefinitions {
    /// The total number of properties
    int count;
    /// The property definitions array
    PropertyDefinition *definitions;
};

#ifndef __cplusplus
typedef struct PropertyDefinitions PropertyDefinitions;
#endif

/// Incapsulate all the QAbstractItemModel callbacks
struct DosQAbstractItemModelCallbacks {
    RowCountCallback rowCount;
    ColumnCountCallback columnCount;
    DataCallback data;
    SetDataCallback setData;
    RoleNamesCallback roleNames;
    FlagsCallback flags;
    HeaderDataCallback headerData;
    IndexCallback index;
    ParentCallback parent;
    HasChildrenCallback hasChildren;
    CanFetchMoreCallback canFetchMore;
    FetchMoreCallback fetchMore;
};

#ifndef __cplusplus
typedef struct DosQAbstractItemModelCallbacks DosQAbstractItemModelCallbacks;
#endif

enum DosQEventLoopProcessEventFlag {
    DosQEventLoopProcessEventFlagProcessAllEvents = 0x00,
    DosQEventLoopProcessEventFlagExcludeUserInputEvents = 0x01,
    DosQEventLoopProcessEventFlagProcessExcludeSocketNotifiers = 0x02,
    DosQEventLoopProcessEventFlagProcessAllEventsWaitForMoreEvents = 0x03
};

#ifdef __cplusplus
}
#endif

#endif
