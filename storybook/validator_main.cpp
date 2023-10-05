#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QDir>
#include <QQmlComponent>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    const QStringList additionalImportPaths {
        STATUSQ_MODULE_IMPORT_PATH,
        QML_IMPORT_ROOT + QStringLiteral("/../ui/app"),
        QML_IMPORT_ROOT + QStringLiteral("/../ui/imports"),
        QML_IMPORT_ROOT + QStringLiteral("/src"),
        QML_IMPORT_ROOT + QStringLiteral("/stubs")
    };

    for (const auto& path : additionalImportPaths)
        engine.addImportPath(path);

    QString pagesPath = QML_IMPORT_ROOT + QStringLiteral("/pages");
    QDir pagesDir(pagesPath);

    const QFileInfoList files = pagesDir.entryInfoList(
                { QStringLiteral("*Page.qml") }, QDir::Files, QDir::Name);

    engine.setBaseUrl(QUrl::fromLocalFile(pagesPath + QDir::separator()));

    bool errorsFound = false;

    for (const auto& fileInfo : files) {
        auto fileName = fileInfo.fileName();
        qDebug() << fileName;

        QQmlComponent component(&engine, fileName);

        if (component.isError()) {
            qWarning() << component.errors();
            errorsFound = true;
        }
    }

    if (errorsFound)
        return EXIT_FAILURE;

    qDebug() << "Verification completed successfully.";
    return EXIT_SUCCESS;
}
