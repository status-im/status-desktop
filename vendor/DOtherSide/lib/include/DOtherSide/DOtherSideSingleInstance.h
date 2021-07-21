#ifndef SINGLEINSTANCE_H
#define SINGLEINSTANCE_H

#include <QObject>

class QLocalServer;

class SingleInstance : public QObject
{
    Q_OBJECT

public:
    explicit SingleInstance(const QString &uniqueName, QObject *parent = nullptr);
    ~SingleInstance() override;

    bool isFirstInstance() const;

signals:
    void secondInstanceDetected();

private:
    QLocalServer *m_localServer;
};


#endif // SINGLEINSTANCE_H
