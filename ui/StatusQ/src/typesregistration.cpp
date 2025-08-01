#include "StatusQ/audioutils.h"
#include "StatusQ/clipboardutils.h"
#include "StatusQ/constantrole.h"
#include "StatusQ/fastexpressionfilter.h"
#include "StatusQ/fastexpressionrole.h"
#include "StatusQ/fastexpressionsorter.h"
#include "StatusQ/formatteddoubleproperty.h"
#include "StatusQ/genericvalidator.h"
#include "StatusQ/keychain.h"
#include "StatusQ/networkchecker.h"
#include "StatusQ/permissionutilsinternal.h"
#include "StatusQ/rxvalidator.h"
#include "StatusQ/statusemojimodel.h"
#include "StatusQ/statussyntaxhighlighter.h"
#include "StatusQ/statuswindow.h"
#include "StatusQ/stringutilsinternal.h"
#include "StatusQ/systemutilsinternal.h"
#include "StatusQ/undefinedfilter.h"
#include "StatusQ/urlutils.h"

#include <qtmodelstoolkit/registerqmltypes.h>
#include <qqmlsortfilterproxymodeltypes.h>

#include "wallet/managetokenscontroller.h"
#include "wallet/managetokensmodel.h"
#include "onboarding/enums.h"

#include <QZXing.h>

#include <QQmlEngine>

void registerStatusQTypes() {
    qmlRegisterType<StatusWindow>("StatusQ", 0, 1, "StatusWindow");
    qmlRegisterType<StatusSyntaxHighlighter>("StatusQ", 0, 1, "StatusSyntaxHighlighter");
    qmlRegisterType<RXValidator>("StatusQ", 0, 1, "RXValidator");

    qmlRegisterUncreatableType<QValidator>(
                "StatusQ", 0, 1,
                "Validator", QStringLiteral("This is abstract type, cannot be created directly."));
    qmlRegisterType<GenericValidator>("StatusQ", 0, 1, "GenericValidator");

    qmlRegisterType<ManageTokensController>("StatusQ.Models", 0, 1, "ManageTokensController");
    qmlRegisterType<ManageTokensModel>("StatusQ.Models", 0, 1, "ManageTokensModel");

    qmlRegisterType<NetworkChecker>("StatusQ", 0, 1, "NetworkChecker");

    qmlRegisterType<FastExpressionFilter>("StatusQ", 0, 1, "FastExpressionFilter");
    qmlRegisterType<FastExpressionRole>("StatusQ", 0, 1, "FastExpressionRole");
    qmlRegisterType<FastExpressionSorter>("StatusQ", 0, 1, "FastExpressionSorter");
    qmlRegisterType<UndefinedFilter>("StatusQ", 0, 1, "UndefinedFilter");
    qmlRegisterType<ConstantRole>("StatusQ", 0, 1, "ConstantRole");

    qmlRegisterType<StatusEmojiModel>("StatusQ", 0, 1, "StatusEmojiModel");
    qmlRegisterType<FormattedDoubleProperty>("StatusQ", 0, 1, "FormattedDoubleProperty");

    qmlRegisterSingletonType<ClipboardUtils>("StatusQ", 0, 1, "ClipboardUtils", &ClipboardUtils::qmlInstance);
    qmlRegisterSingletonType<UrlUtils>("StatusQ", 0, 1, "UrlUtils", [](QQmlEngine* engine, QJSEngine*) {
        return new UrlUtils(engine);
    });
    qmlRegisterSingletonType<AudioUtils>("StatusQ", 0, 1, "AudioUtils", [](QQmlEngine* engine, QJSEngine*) {
        return new AudioUtils(engine);
    });

    qmlRegisterType<Keychain>("StatusQ", 0, 1, "Keychain");
    qRegisterMetaType<Keychain::Status>();

    // Workaround for https://bugreports.qt.io/browse/QTBUG-86428
    qmlRegisterAnonymousType<QAbstractItemModel>("StatusQ", 1);

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

#ifdef BUNDLE_QML_RESOURCES
    Q_INIT_RESOURCE(statusq);
    Q_INIT_RESOURCE(fonts);
    Q_INIT_RESOURCE(img);
    Q_INIT_RESOURCE(png);
    Q_INIT_RESOURCE(twemoji);
    Q_INIT_RESOURCE(twemoji_big);
    Q_INIT_RESOURCE(twemoji_svg);
#endif

    qtmt::registerQmlTypes();
    QZXing::registerQMLTypes();
    qqsfpm::registerTypes();
}
