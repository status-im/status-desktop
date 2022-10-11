#include "DOtherSide/Status/OSNotification.h"

#ifdef Q_OS_WIN
#include <shellapi.h>
#include <stdlib.h>
#include <string.h>
#include <winuser.h>
#include <comdef.h>

using namespace Status;

static const UINT NOTIFYICONID = 0;

static std::pair<HWND, OSNotification *> HWND_INSTANCE_PAIR;
#endif

#ifdef Q_OS_LINUX
#include <QProcess>
#include <QStandardPaths>
#include <QDebug>
#endif

using namespace Status;

OSNotification::OSNotification(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN
    m_hwnd = nullptr;
    initNotificationWin();
#elif defined Q_OS_MACOS
    m_notificationHelper = nullptr;
    initNotificationMacOs();
#endif
}

OSNotification::~OSNotification()
{
#ifdef Q_OS_MACOS
    if(m_notificationHelper)
    {
        delete m_notificationHelper;
    }
#endif
}

#ifdef Q_OS_WIN
LRESULT CALLBACK StatusWndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    const int msgInfo = LOWORD(lParam);

    if (hwnd == HWND_INSTANCE_PAIR.first 
        && HWND_INSTANCE_PAIR.second 
        && HWND_INSTANCE_PAIR.second->m_identifiers.contains(uMsg) 
        && msgInfo == NIN_BALLOONUSERCLICK)
    {
        HWND_INSTANCE_PAIR.second->notificationClicked(
            HWND_INSTANCE_PAIR.second->m_identifiers[uMsg]);
        return 0;
    }

    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

void OSNotification::stringToLimitedWCharArray(QString in, wchar_t* target, 
    int maxLength)
{
    const int length = qMin(maxLength - 1, in.size());
    if (length < in.size())
        in.truncate(length);
    in.toWCharArray(target);
    target[length] = wchar_t(0);
}

bool OSNotification::initNotificationWin()
{
    // m_hwnd should be init only once, but that would be a case if we create system 
    // tray window from here. But since we already have system tray added in the
    // app we're just refering to that already added window and listen for events
    // on it. HWND of that window may be changed during the runtime and we don't
    // have an option to be notified about that, that's why we're searching for 
    // appropriate HWND each time we need it, and that's why the following two
    // lines are commented out.
    //
    // if (m_hwnd)
    //     return true;

    const QString cName = "QTrayIconMessageWindowClass";
    LPCSTR className = cName.toStdString().c_str();
    const QString wName = "QTrayIconMessageWindow";
    LPCSTR windowName = wName.toStdString().c_str();

    const auto appInstance = static_cast<HINSTANCE>(GetModuleHandle(nullptr));

    WNDCLASSEX wc;
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = StatusWndProc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = appInstance;
    wc.hCursor = nullptr;
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW);
    wc.hIcon = nullptr;
    wc.hIconSm = nullptr;
    wc.lpszMenuName = nullptr;
    wc.lpszClassName = className;

    ATOM atom = RegisterClassEx(&wc);
    if (!atom)
        printf("Status::OsNotification registering window class failed.\n");

    m_hwnd = FindWindowExA(0, 0, className, windowName);
    if(m_hwnd)
    {
        HWND_INSTANCE_PAIR = std::make_pair(m_hwnd, this);
        return true;
    }

    return false;
}
#endif

void OSNotification::showNotification(const QString& title, 
    const QString& message, const QString& identifier)
{
#ifdef Q_OS_WIN
    if (!initNotificationWin())
    {
        return;
    }

    NOTIFYICONDATA tnd;
    memset(&tnd, 0, sizeof(NOTIFYICONDATA));
    tnd.cbSize = sizeof(NOTIFYICONDATA);
    tnd.uVersion = NOTIFYICON_VERSION_4;

    QString t = title;
    wchar_t wcTitle[64];    
    stringToLimitedWCharArray(t, wcTitle, 64);
    _bstr_t bT(wcTitle);
    const char* cTitle = bT;

    QString m = message;
    wchar_t wcMessage[256];
    stringToLimitedWCharArray(m, wcMessage, 256);
    _bstr_t bM(wcMessage);
    const char* cMessage = bM;

    strncpy_s(tnd.szInfoTitle, sizeof(tnd.szInfoTitle), cTitle, strlen(cTitle));
    strncpy_s(tnd.szInfo, sizeof(tnd.szInfo), cMessage, strlen(cMessage));

    tnd.uID = NOTIFYICONID;
    tnd.hWnd = m_hwnd;
    tnd.dwInfoFlags = NIIF_INFO;
    tnd.uTimeout = UINT(10000);
    tnd.uFlags = NIF_MESSAGE | NIF_INFO | NIF_SHOWTIP;

    uint id = WM_APP + 2 + m_identifiers.size();
    m_identifiers.insert(id, identifier);
    tnd.uCallbackMessage = id;

    Shell_NotifyIcon(NIM_MODIFY, &tnd);

#elif defined Q_OS_MACOS
    showNotificationMacOs(title, message, identifier);
#elif defined Q_OS_LINUX
    static QString notifyExe = QStandardPaths::findExecutable(QStringLiteral("notify-send"));
    if (notifyExe.isEmpty()) {
        qWarning() << "'notify-send' not found; OS notifications will not work";
        return;
    }

    QStringList args; // spec https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html
    args << QStringLiteral("-a") << QStringLiteral("nim-status"); // appname; w/o .desktop extension
    args << QStringLiteral("-c") << QStringLiteral("im"); // category; generic "im" category
    args << title; // summary
    args << message; // body

    QProcess::execute(notifyExe, args);
#endif
}

void OSNotification::showIconBadgeNotification(int notificationsCount)
{
#ifdef Q_OS_WIN
    // TODO
#elif defined Q_OS_MACOS
    showIconBadgeNotificationMacOs(notificationsCount);
#endif
}
