#include <QZXing.h>
#include <qqmlsortfilterproxymodeltypes.h>

#include "StatusQ/audioutils.h"
#include "StatusQ/clipboardutils.h"
#include "StatusQ/concatmodel.h"
#include "StatusQ/constantrole.h"
#include "StatusQ/fastexpressionfilter.h"
#include "StatusQ/fastexpressionrole.h"
#include "StatusQ/fastexpressionsorter.h"
#include "StatusQ/formatteddoubleproperty.h"
#include "StatusQ/functionaggregator.h"
#include "StatusQ/genericvalidator.h"
#include "StatusQ/groupingmodel.h"
#include "StatusQ/keychain.h"
#include "StatusQ/leftjoinmodel.h"
#include "StatusQ/modelcount.h"
#include "StatusQ/modelentry.h"
#include "StatusQ/modelutilsinternal.h"
#include "StatusQ/movablemodel.h"
#include "StatusQ/networkchecker.h"
#include "StatusQ/objectproxymodel.h"
#include "StatusQ/permissionutilsinternal.h"
#include "StatusQ/rolesrenamingmodel.h"
#include "StatusQ/rxvalidator.h"
#include "StatusQ/snapshotobject.h"
#include "StatusQ/statusemojimodel.h"
#include "StatusQ/statussyntaxhighlighter.h"
#include "StatusQ/statuswindow.h"
#include "StatusQ/stringutilsinternal.h"
#include "StatusQ/sumaggregator.h"
#include "StatusQ/systemutilsinternal.h"
#include "StatusQ/undefinedfilter.h"
#include "StatusQ/urlutils.h"
#include "StatusQ/writableproxymodel.h"

#include "wallet/managetokenscontroller.h"
#include "wallet/managetokensmodel.h"

#include "onboarding/enums.h"

void registerStatusQTypes() {
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    QByteArrayList selectors = qgetenv("QT_FILE_SELECTORS").split(',');
    selectors << QByteArrayLiteral("qt6");
    qputenv("QT_FILE_SELECTORS", selectors.join(","));
#endif

    qmlRegisterType<StatusWindow>("StatusQ", 0, 1, "StatusWindow");
    qmlRegisterType<StatusSyntaxHighlighter>("StatusQ", 0, 1, "StatusSyntaxHighlighter");
    qmlRegisterType<RXValidator>("StatusQ", 0, 1, "RXValidator");

    qmlRegisterUncreatableType<QValidator>(
                "StatusQ", 0, 1,
                "Validator", QStringLiteral("This is abstract type, cannot be created directly."));
    qmlRegisterType<GenericValidator>("StatusQ", 0, 1, "GenericValidator");

    qmlRegisterType<ManageTokensController>("StatusQ.Models", 0, 1, "ManageTokensController");
    qmlRegisterType<ManageTokensModel>("StatusQ.Models", 0, 1, "ManageTokensModel");

    qmlRegisterType<GroupingModel>("StatusQ", 0, 1, "GroupingModel");
    qmlRegisterType<SourceModel>("StatusQ", 0, 1, "SourceModel");
    qmlRegisterType<ConcatModel>("StatusQ", 0, 1, "ConcatModel");
    qmlRegisterType<MovableModel>("StatusQ", 0, 1, "MovableModel");
    qmlRegisterType<NetworkChecker>("StatusQ", 0, 1, "NetworkChecker");

    qmlRegisterType<FastExpressionFilter>("StatusQ", 0, 1, "FastExpressionFilter");
    qmlRegisterType<FastExpressionRole>("StatusQ", 0, 1, "FastExpressionRole");
    qmlRegisterType<FastExpressionSorter>("StatusQ", 0, 1, "FastExpressionSorter");
    qmlRegisterType<UndefinedFilter>("StatusQ", 0, 1, "UndefinedFilter");
    qmlRegisterType<ConstantRole>("StatusQ", 0, 1, "ConstantRole");

    qmlRegisterType<ObjectProxyModel>("StatusQ", 0, 1, "ObjectProxyModel");
    qmlRegisterType<LeftJoinModel>("StatusQ", 0, 1, "LeftJoinModel");
    qmlRegisterType<RoleRename>("StatusQ", 0, 1, "RoleRename");
    qmlRegisterType<RolesRenamingModel>("StatusQ", 0, 1, "RolesRenamingModel");
    qmlRegisterType<StatusEmojiModel>("StatusQ", 0, 1, "StatusEmojiModel");
    qmlRegisterType<SumAggregator>("StatusQ", 0, 1, "SumAggregator");
    qmlRegisterType<FunctionAggregator>("StatusQ", 0, 1, "FunctionAggregator");
    qmlRegisterType<WritableProxyModel>("StatusQ", 0, 1, "WritableProxyModel");
    qmlRegisterType<FormattedDoubleProperty>("StatusQ", 0, 1, "FormattedDoubleProperty");

    qmlRegisterSingletonType<ClipboardUtils>("StatusQ", 0, 1, "ClipboardUtils", &ClipboardUtils::qmlInstance);
    qmlRegisterSingletonType<UrlUtils>("StatusQ", 0, 1, "UrlUtils", [](QQmlEngine* engine, QJSEngine*) {
        return new UrlUtils(engine);
    });
    qmlRegisterSingletonType<AudioUtils>("StatusQ", 0, 1, "AudioUtils", [](QQmlEngine* engine, QJSEngine*) {
        return new AudioUtils(engine);
    });

    qmlRegisterType<ModelEntry>("StatusQ", 0, 1, "ModelEntry");
    qmlRegisterType<SnapshotObject>("StatusQ", 0, 1, "SnapshotObject");
    qmlRegisterType<Keychain>("StatusQ", 0, 1, "Keychain");
    qRegisterMetaType<Keychain::Status>();

    qmlRegisterUncreatableType<ModelCount>("StatusQ", 0, 1,
                                           "ModelCount", QStringLiteral("This is attached type, cannot be created directly."));

    // Workaround for https://bugreports.qt.io/browse/QTBUG-86428
    qmlRegisterAnonymousType<QAbstractItemModel>("StatusQ", 1);

    qmlRegisterSingletonType<ModelUtilsInternal>(
        "StatusQ.Internal", 0, 1, "ModelUtils", &ModelUtilsInternal::qmlInstance);

    qmlRegisterSingletonType<StringUtilsInternal>(
        "StatusQ.Internal", 0, 1, "StringUtils", [](QQmlEngine* engine, QJSEngine*) {
            return new StringUtilsInternal(engine);
        });

    qmlRegisterSingletonType<SystemUtilsInternal>(
        "StatusQ.Core", 0, 1, "SystemUtils", [](QQmlEngine*, QJSEngine*) {
            return new SystemUtilsInternal;
        });

    qmlRegisterSingletonType<PermissionUtilsInternal>(
        "StatusQ.Internal", 0, 1, "PermissionUtils", [](QQmlEngine*, QJSEngine*) {
            return new PermissionUtilsInternal;
        });

    // onboarding
    qmlRegisterSingletonType<OnboardingEnums>("AppLayouts.Onboarding.enums", 1, 0,
                                              "Onboarding", [](QQmlEngine*, QJSEngine*) {
                                                  return new OnboardingEnums;
                                              });

// create import alias from QtGraphicalEffects 1.15 to Qt5Compat.GraphicalEffects
// in order to satisfy both Qt 5/6, relying the same version of qml code
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    qmlRegisterModule("QtGraphicalEffects", 1, 15);
    qmlRegisterModuleImport("QtGraphicalEffects", QQmlModuleImportModuleAny,
                            "Qt5Compat.GraphicalEffects", QQmlModuleImportLatest);

    qmlRegisterModule("Qt.labs.calendar", 1, 0);
    qmlRegisterModuleImport("Qt.labs.calendar", QQmlModuleImportModuleAny,
                            "QtQuick.Controls", QQmlModuleImportLatest);
#endif
        
#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
    qmlRegisterModuleImport("Qt.labs.qmlmodels", QQmlModuleImportModuleAny,
                            "QtQml.Models", QQmlModuleImportLatest);
#endif

#ifdef BUNDLE_QML_RESOURCES
    Q_INIT_RESOURCE(statusq);
    Q_INIT_RESOURCE(fonts);
    Q_INIT_RESOURCE(img);
    Q_INIT_RESOURCE(png);
    Q_INIT_RESOURCE(twemoji);
    Q_INIT_RESOURCE(twemoji_big);
    Q_INIT_RESOURCE(twemoji_svg);
#endif

    QZXing::registerQMLTypes();
    qqsfpm::registerTypes();
}
