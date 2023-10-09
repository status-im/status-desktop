#include <QSignalSpy>
#include <QTest>

#include <QTemporaryDir>
#include <directoryfileswatcher.h>


class TestDirectoryFilesWatcher: public QObject
{
    Q_OBJECT

private slots:
    void emptyDirTest()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        DirectoryFilesWatcher watcher(dir.path(), "*");
        QVERIFY(watcher.files().empty());
    }

    void nonEmptyDirTest()
    {
        QTemporaryDir dir;

        QString filename = dir.path() + "/Data.txt";
        {
            QFile file(filename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        QVERIFY(dir.isValid());

        DirectoryFilesWatcher watcher(dir.path(), "*");
        QCOMPARE(watcher.files().size(), 1);
        QCOMPARE(watcher.files().at(0), filename);
    }

    void notifyAddTest()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        DirectoryFilesWatcher watcher(dir.path(), "*");

        QSignalSpy changeSpy(&watcher, &DirectoryFilesWatcher::filesChanged);


        QString filename = dir.path() + "/Data.txt";
        {
            QFile file(filename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        changeSpy.wait();
        QCOMPARE(changeSpy.count(), 1);
        QCOMPARE(changeSpy.at(0).at(0).toStringList(), { filename });
        QCOMPARE(changeSpy.at(0).at(1).toStringList(), { });
        QCOMPARE(changeSpy.at(0).at(2).toStringList(), { });
    }

    void notifyMultipleAddTest()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        DirectoryFilesWatcher watcher(dir.path(), "*");

        QSignalSpy changeSpy(&watcher, &DirectoryFilesWatcher::filesChanged);


        QString filename = dir.path() + "/Data.txt";
        {
            QFile file(filename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        QString filename2 = dir.path() + "/Data2.txt";
        {
            QFile file(filename2);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        changeSpy.wait();
        QCOMPARE(changeSpy.count(), 1);
        QCOMPARE(changeSpy.at(0).at(0).toStringList(),
                 QStringList({ filename, filename2 }));
        QCOMPARE(changeSpy.at(0).at(1).toStringList(), { });
        QCOMPARE(changeSpy.at(0).at(2).toStringList(), { });
    }

    void notifyRemoveTest()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        QString filename = dir.path() + "/Data.txt";
        {
            QFile file(filename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        QString filename2 = dir.path() + "/Data2.txt";
        {
            QFile file(filename2);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        DirectoryFilesWatcher watcher(dir.path(), "*");

        QSignalSpy changeSpy(&watcher, &DirectoryFilesWatcher::filesChanged);

        QVERIFY(QFile::remove(filename));


        changeSpy.wait();
        QCOMPARE(changeSpy.count(), 1);
        QCOMPARE(changeSpy.at(0).at(0).toStringList(), { });
        QCOMPARE(changeSpy.at(0).at(1).toStringList(), { filename });
        QCOMPARE(changeSpy.at(0).at(2).toStringList(), { });
    }

    void notifyChangeTest()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        QString filename = dir.path() + "/Data.txt";
        {
            QFile file(filename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        QString filename2 = dir.path() + "/Data2.txt";
        {
            QFile file(filename2);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something";
            }
        }

        DirectoryFilesWatcher watcher(dir.path(), "*");

        QSignalSpy changeSpy(&watcher, &DirectoryFilesWatcher::filesChanged);

        // wait a bit to have a different timestamp for tmp file
        QTest::qSleep(5);

        QString tempraryFilename = dir.path() + "/Tmp.txt";
        {
            QFile file(tempraryFilename);
            if (file.open(QIODevice::ReadWrite)) {
                QTextStream stream(&file);
                stream << "something else";
            }
        }

        QFile::remove(filename);
        QFile::rename(tempraryFilename, filename);

        changeSpy.wait();
        QCOMPARE(changeSpy.count(), 1);
        QCOMPARE(changeSpy.at(0).at(0).toStringList(), { });
        QCOMPARE(changeSpy.at(0).at(1).toStringList(), { });
        QCOMPARE(changeSpy.at(0).at(2).toStringList(), { filename });
    }
};

QTEST_MAIN(TestDirectoryFilesWatcher)
#include "tst_DirectoryFilesWatcher.moc"
