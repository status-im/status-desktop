#include <QQmlExtensionPlugin>

#include <QZXing.h>
#include <qqmlsortfilterproxymodeltypes.h>

#include "StatusQ/QClipboardProxy.h"
#include "StatusQ/modelutilsinternal.h"
#include "StatusQ/permissionutilsinternal.h"
#include "StatusQ/rolesrenamingmodel.h"
#include "StatusQ/rxvalidator.h"
#include "StatusQ/statussyntaxhighlighter.h"
#include "StatusQ/statuswindow.h"
#include "StatusQ/stringutilsinternal.h"

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

        qmlRegisterType<RolesRenamingModel>("StatusQ", 0, 1, "RolesRenamingModel");
        qmlRegisterType<RoleRename>("StatusQ", 0, 1, "RoleRename");

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
