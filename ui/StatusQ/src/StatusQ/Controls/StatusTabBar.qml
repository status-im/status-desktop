import QtQuick 2.0
import QtQuick.Controls 2.13

/*!
   \qmltype StatusTabButton
   \inherits TabButton
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief StatusTabBar provides a tab-based navigation model

   It's customized from Qt's \l{https://doc.qt.io/qt-6/qml-qtquick-controls2-tabbar.html}{TabBar},
   adding a transparent background.
*/


TabBar {
    background: Item { }
}
