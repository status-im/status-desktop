type
  QObject* = ref object of RootObj ## \
    ## A QObject
    vptr: DosQObject
    owner: bool

  QAbstractItemModel* = ref object of QObject ## \
    ## A QAbstractItemModel

  QAbstractListModel* = ref object of QAbstractItemModel ## \
    ## A QAbstractListModel

  QAbstractTableModel* = ref object of QAbstractItemModel ## \
    ## A QAbstractTableModel

  QVariant* = ref object of RootObj ## \
    ## A QVariant
    vptr: DosQVariant

  QQmlApplicationEngine* = ref object of RootObj ## \
    ## A QQmlApplicationEngine
    vptr: DosQQmlApplicationEngine

  QCoreApplication* = ref object of RootObj ## \
    ## A QCoreApplication
    deleted: bool

  QGuiApplication* = ref object of QCoreApplication ## \

  QApplication* = ref object of QGuiApplication ## \

  QQuickView* = ref object of RootObj ## \
    # A QQuickView
    vptr: DosQQuickView

  QHashIntByteArray* = ref object of RootObj ## \
    # A QHash<int, QByteArray>
    vptr: DosQHashIntByteArray

  QModelIndex* = ref object of RootObj ## \
    # A QModelIndex
    vptr: DosQModelIndex

  QResource* = ref object of RootObj ## \
    # A QResource

  QtItemFlag*{.pure, size: sizeof(cint).} = enum ## \
    ## Item flags
    ##
    ## This enum mimic the Qt::itemFlag C++ enum
    None = 0.cint,
    IsSelectable = 1.cint,
    IsEditable = 2.cint,
    IsDragEnabled = 4.cint,
    IsDropEnabled = 8.cint,
    IsUserCheckable = 16.cint,
    IsEnabled = 32.cint,
    IsTristate = 64.cint,
    NeverHasChildren = 128.cint

  QtOrientation*{.pure, size: sizeof(cint).} = enum ## \
    ## Define orientation
    ##
    ## This enum mimic the Qt::Orientation C++ enum
    Horizontal = 1.cint,
    Vertical = 2.cint

  QMetaType*{.pure, size: sizeof(cint).} = enum ## \
    ## Qt metatypes values used for specifing the
    ## signals and slots argument and return types.
    ##
    ## This enum mimic the QMetaType::Type C++ enum
    UnknownType = 0.cint,
    Bool = 1.cint,
    Int = 2.cint,
    QString = 10.cint,
    VoidStar = 31.cint,
    Float = 38.cint,
    QObjectStar = 39.cint,
    QVariant = 41.cint,
    Void = 43.cint

  ParameterDefinition* = object
    name*: string
    metaType*: QMetaType

  SignalDefinition* = object
    name*: string
    parameters*: seq[ParameterDefinition]

  SlotDefinition* = object
    name*: string
    returnMetaType*: QMetaType
    parameters*: seq[ParameterDefinition]

  PropertyDefinition* = object
    name*: string
    propertyMetaType*: QMetaType
    readSlot*: string
    writeSlot*: string
    notifySignal*: string

  QMetaObject* = ref object of RootObj
    vptr: DosQMetaObject
    signals: seq[SignalDefinition]
    slots: seq[SlotDefinition]
    properties: seq[PropertyDefinition]

  QUrl* = ref object of RootObj
    vptr: DosQUrl

  QNetworkConfigurationManager* = ref object of QObject
  
  QNetworkAccessManagerFactory* = ref object of RootObj ## \
    vptr: DosQQNetworkAccessManagerFactory

  QNetworkAccessManager* = ref object of QObject ## \

  NetworkAccessibility*{.pure, size: sizeof(cint).} = enum ## \
    UnknownAccessibility = -1.cint,
    NotAccessible = 0.cint,
    Accessible = 1.cint

  QUrlParsingMode*{.pure, size: sizeof(cint).} = enum
    Tolerant = 0.cint
    Strict = 1.cint

  Ownership {.pure.} = enum ## \
    ## Specify the ownership of a pointer
    Take,                   # The ownership is passed to the wrapper
    Clone                   # The node should be cloned

const
  UserRole* = 0x100
