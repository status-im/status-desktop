#include <QCoreApplication>
#include <QDebug>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlEngine>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QQmlEngine engine;

    engine.addImportPath(QStringLiteral(":/"));

    QDirIterator it(":", QDirIterator::Subdirectories);
    bool errorsFound = false;

    while (it.hasNext()) {
        QFileInfo info = it.fileInfo();

        if (info.suffix() == QStringLiteral("qml")) {
            QFile file(it.filePath());
            file.open(QIODevice::ReadOnly);

            QTextStream in(&file);
            QString line = in.readLine();

            if (line != QStringLiteral("pragma Singleton")) {
                engine.setBaseUrl(QStringLiteral("qrc") + info.dir().path()
                                  + QDir::separator());

                QQmlComponent component(&engine, it.fileName());

                if (component.isError()) {
                    qWarning() << component.errors();
                    errorsFound = true;
                }
            }
        }

        it.next();
    }

    if (errorsFound)
        return EXIT_FAILURE;

    qDebug() << "Verification completed successfully.";
    return EXIT_SUCCESS;
}
