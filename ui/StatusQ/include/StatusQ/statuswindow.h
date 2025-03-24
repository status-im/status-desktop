#pragma once

#include <QQuickWindow>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

public:
    explicit StatusWindow(QWindow *parent = nullptr);

    Q_INVOKABLE void toggleFullScreen();
    Q_INVOKABLE void toggleMinimize();
    Q_INVOKABLE void restoreWindowState();

signals:
    void urlActivated(const QString& url);

protected:
    bool eventFilter(QObject* obj, QEvent* event) override;

private:
    void removeTitleBar();
    void showTitleBar();
};
