#include <QQmlExtensionPlugin>

#include <QZXing.h>
#include <qqmlsortfilterproxymodeltypes.h>

#include "StatusQ/QClipboardProxy.h"
#include "StatusQ/concatmodel.h"
#include "StatusQ/fastexpressionrole.h"
#include "StatusQ/leftjoinmodel.h"
#include "StatusQ/modelutilsinternal.h"
#include "StatusQ/permissionutilsinternal.h"
#include "StatusQ/rolesrenamingmodel.h"
#include "StatusQ/rxvalidator.h"
#include "StatusQ/statussyntaxhighlighter.h"
#include "StatusQ/statuswindow.h"
#include "StatusQ/stringutilsinternal.h"
#include "StatusQ/submodelproxymodel.h"
#include "StatusQ/sumaggregator.h"

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

        qmlRegisterType<ManageTokensController>("StatusQ.Models", 0, 1, "ManageTokensController");
        qmlRegisterType<ManageTokensModel>("StatusQ.Models", 0, 1, "ManageTokensModel");

        qmlRegisterType<SourceModel>("StatusQ", 0, 1, "SourceModel");
        qmlRegisterType<ConcatModel>("StatusQ", 0, 1, "ConcatModel");

        qmlRegisterType<FastExpressionRole>("StatusQ", 0, 1, "FastExpressionRole");

        qmlRegisterType<LeftJoinModel>("StatusQ", 0, 1, "LeftJoinModel");
        qmlRegisterType<SubmodelProxyModel>("StatusQ", 0, 1, "SubmodelProxyModel");
        qmlRegisterType<RoleRename>("StatusQ", 0, 1, "RoleRename");
        qmlRegisterType<RolesRenamingModel>("StatusQ", 0, 1, "RolesRenamingModel");
        qmlRegisterType<SumAggregator>("StatusQ", 0, 1, "SumAggregator");

        qmlRegisterSingletonType<QClipboardProxy>("StatusQ", 0, 1, "QClipboardProxy", &QClipboardProxy::qmlInstance);

        qmlRegisterSingletonType<ModelUtilsInternal>(
            "StatusQ.Internal", 0, 1, "ModelUtils", &ModelUtilsInternal::qmlInstance);

        qmlRegisterSingletonType<StringUtilsInternal>(
            "StatusQ.Internal", 0, 1, "StringUtils", [](QQmlEngine* engine, QJSEngine*) {
                return new StringUtilsInternal(engine);
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
