#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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
    for (const auto &fileInfo : files) {
        QQmlApplicationEngine engine;
        engine.setOutputWarningsToStandardError(false);
        engine.setBaseUrl(QUrl::fromLocalFile(pagesPath + QDir::separator()));

        for (const auto &path : additionalImportPaths)
            engine.addImportPath(path);

        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                         &app, [&errorCount](QObject *obj, const QUrl &objUrl) {
            if (!obj) {
                errorCount++;
                qWarning() << ">>> Error loading StoryBook page:" << objUrl;
            }
        });

        auto fileName = fileInfo.filePath();
        qInfo() << ">>> Checking StoryBook page:" << fileName;

        engine.load(fileName);
    }

    if (errorCount) {
        qWarning() << ">>> StoryBook page verification failed with" << errorCount << "errors.";
        return EXIT_FAILURE;
    }

    qInfo() << ">>> StoryBook page verification completed successfully.";
    return EXIT_SUCCESS;
}
