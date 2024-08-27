#include <QQmlExtensionPlugin>

#include <QZXing.h>
#include <qqmlsortfilterproxymodeltypes.h>

#include "StatusQ/clipboardutils.h"
#include "StatusQ/concatmodel.h"
#include "StatusQ/fastexpressionfilter.h"
#include "StatusQ/fastexpressionrole.h"
#include "StatusQ/fastexpressionsorter.h"
#include "StatusQ/formatteddoubleproperty.h"
#include "StatusQ/functionaggregator.h"
#include "StatusQ/genericvalidator.h"
#include "StatusQ/groupingmodel.h"
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
#include "StatusQ/statussyntaxhighlighter.h"
#include "StatusQ/statuswindow.h"
#include "StatusQ/stringutilsinternal.h"
#include "StatusQ/submodelproxymodel.h"
#include "StatusQ/sumaggregator.h"
#include "StatusQ/systemutilsinternal.h"
#include "StatusQ/undefinedfilter.h"
#include "StatusQ/urlutils.h"
#include "StatusQ/writableproxymodel.h"

#include "wallet/managetokenscontroller.h"
#include "wallet/managetokensmodel.h"

class StatusQPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char* uri) override
    {
        Q_ASSERT(uri == QLatin1String("StatusQ"));

        qmlRegisterType<StatusWindow>("StatusQ", 0, 1, "StatusWindow");
        qmlRegisterType<StatusSyntaxHighlighter>("StatusQ", 0, 1, "StatusSyntaxHighlighter");
        qmlRegisterType<RXValidator>("StatusQ", 0, 1, "RXValidator");

        qmlRegisterUncreatableType<QValidator>(
                    "StatusQ", 0, 1,
                    "Validator", "This is abstract type, cannot be created directly.");
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

        qmlRegisterType<ObjectProxyModel>("StatusQ", 0, 1, "ObjectProxyModel");
        qmlRegisterType<LeftJoinModel>("StatusQ", 0, 1, "LeftJoinModel");
        qmlRegisterType<SubmodelProxyModel>("StatusQ", 0, 1, "SubmodelProxyModel");
        qmlRegisterType<RoleRename>("StatusQ", 0, 1, "RoleRename");
        qmlRegisterType<RolesRenamingModel>("StatusQ", 0, 1, "RolesRenamingModel");
        qmlRegisterType<SumAggregator>("StatusQ", 0, 1, "SumAggregator");
        qmlRegisterType<FunctionAggregator>("StatusQ", 0, 1, "FunctionAggregator");
        qmlRegisterType<WritableProxyModel>("StatusQ", 0, 1, "WritableProxyModel");
        qmlRegisterType<FormattedDoubleProperty>("StatusQ", 0, 1, "FormattedDoubleProperty");

        qmlRegisterSingletonType<ClipboardUtils>("StatusQ", 0, 1, "QClipboardProxy", &ClipboardUtils::qmlInstance);
        qmlRegisterSingletonType<UrlUtils>("StatusQ", 0, 1, "UrlUtils", &UrlUtils::qmlInstance);

        qmlRegisterType<ModelEntry>("StatusQ", 0, 1, "ModelEntry");
        qmlRegisterType<SnapshotObject>("StatusQ", 0, 1, "SnapshotObject");

        qmlRegisterUncreatableType<ModelCount>("StatusQ", 0, 1,
                                               "ModelCount", "This is attached type, cannot be created directly.");

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

        QZXing::registerQMLTypes();
        qqsfpm::registerTypes();
    }
};

#include "plugin.moc"
