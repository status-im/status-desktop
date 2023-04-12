#include <QGuiApplication>
#include <QDebug>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlEngine>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlEngine engine;

#ifdef STATUSQ_SHADOW_BUILD
    const QString componentBaseUrlPrefix{"qrc"};
#else
    const QString componentBaseUrlPrefix{"file://"};
#endif

    const QString iterationPath{QStringLiteral(STATUSQ_MODULE_IMPORT_PATH)};
    engine.addImportPath(iterationPath);

    // Create a dummy component with StatusQ import.
    // NOTE: https://github.com/status-im/status-desktop/issues/10218

    QQmlComponent mainComponent(&engine);
    mainComponent.setData("import QtQuick 2.15\nimport StatusQ 0.1\nItem { }", {});

    if (mainComponent.isError()) {
        qWarning() << "Failed to import StatusQ 0.1:" << mainComponent.errors();
        return EXIT_FAILURE;
    }

    // Start iterating over directory

    bool errorsFound = false;

    for (QDirIterator it(iterationPath, QDirIterator::Subdirectories); it.hasNext(); it.next()) {

        const QFileInfo info = it.fileInfo();

        if (info.suffix() != QStringLiteral("qml"))
            continue;

        QFile file(it.filePath());
        file.open(QIODevice::ReadOnly);

        QTextStream in(&file);
        QString line = in.readLine();

        if (line == QStringLiteral("pragma Singleton"))
            continue;

        QUrl baseFileUrl(componentBaseUrlPrefix + info.dir().path() + QDir::separator());

        engine.setBaseUrl(baseFileUrl);

        QQmlComponent component(&engine, it.fileName());

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
