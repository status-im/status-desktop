#include <QGuiApplication>
#include <QDebug>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlEngine>

#include <StatusQ/typesregistration.h>

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

    registerStatusQTypes();

    bool errorsFound = false;

    for (QDirIterator it(iterationPath, QDirIterator::Subdirectories); it.hasNext(); it.next()) {

        const QFileInfo info = it.fileInfo();

        if (info.suffix() != QStringLiteral("qml"))
            continue;

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        if (info.path().contains("+qt6"))
            continue;
#endif

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
