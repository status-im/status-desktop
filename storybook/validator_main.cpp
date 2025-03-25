#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <StatusQ/typesregistration.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName(QStringLiteral("Status"));
    QGuiApplication::setOrganizationDomain(QStringLiteral("status.im"));

    const QString pagesPath = QML_IMPORT_ROOT + QStringLiteral("/pages");
    QDir pagesDir(pagesPath);
    const QFileInfoList files = pagesDir.entryInfoList({QStringLiteral("*Page.qml")},
                                                       QDir::Files,
                                                       QDir::Name);

    const QStringList additionalImportPaths{STATUSQ_MODULE_IMPORT_PATH,
                                            QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
                                            QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
                                            QML_IMPORT_ROOT + QStringLiteral("/src"),
                                            QML_IMPORT_ROOT + QStringLiteral("/stubs")};

    int errorCount = 0;
    QStringList warnings;
    QStringList failedPages;
    
    for (const auto &fileInfo : files) {
        warnings.clear();
        QQmlApplicationEngine engine;
        engine.setOutputWarningsToStandardError(false);
        engine.setBaseUrl(QUrl::fromLocalFile(pagesPath + QDir::separator()));

        for (const auto &path : additionalImportPaths)
            engine.addImportPath(path);

        QObject::connect(&engine, &QQmlApplicationEngine::warnings, &app, [&warnings](const QList<QQmlError> &qmlWarnings) {
            for (const auto &qmlWarning: qmlWarnings)
                warnings.append(qmlWarning.toString());
        });

        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                        &app, [&errorCount, &warnings, &failedPages](QObject *obj, const QUrl &objUrl) {
            if (!obj) {
                errorCount++;
                failedPages << objUrl.toLocalFile();

                for (const auto &warning: std::as_const(warnings))
                    qWarning() << "    " << warning;
            }
        });

        auto fileName = fileInfo.filePath();
        qInfo() << ">>> Checking StoryBook page:" << fileName;

        registerStatusQTypes();
        engine.load(fileName);
    }

    if (errorCount) {
        qWarning() << ">>> StoryBook page verification failed with" << errorCount << "errors.";
        qWarning() << ">>> StoryBook pages with errors:" << failedPages;

        return EXIT_FAILURE;
    }

    qInfo() << ">>> StoryBook page verification completed successfully.";
    return EXIT_SUCCESS;
}
