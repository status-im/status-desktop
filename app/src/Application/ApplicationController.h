#pragma once


#include <QObject>
#include <QtQml/qqmlregistration.h>

/**
 * @brief Responsible for providing general information and utility components
 */
class ApplicationController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit ApplicationController(QObject *parent = nullptr);

signals:

};
