import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusTabBar
   \inherits TabBar
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief StatusTabBar provides a tab-based navigation model

   It's customized from Qt's \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-tabbar.html}{TabBar},
   adding a transparent background.
*/

TabBar {
    spacing: Theme.bigPadding
    background: null
}
