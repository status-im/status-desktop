import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

/*!
     \qmltype StatusMainLayout
     \inherits SplitView
     \inqmlmodule StatusQ.Layout
     \since StatusQ.Layout 0.1
     \brief Displays a two column layout.
     Inherits \l{https://doc.qt.io/qt-6/qml-qtquick-controls2-splitview.html}{SplitView}.

     The \c StatusMainLayout displays a two column to be used as the base layout of the entire application.
     For example:

     \qml
    StatusMainLayout {

        leftPanel: StatusAppNavBar {
            ...
        }

        rightPanel: StatusAppChatView {
            ...
        }
     }
     \endqml

     For a list of components available see StatusQ.
*/

SplitView {
    id: statusAppLayout

    implicitWidth: 900
    implicitHeight: 600

    /*!
        \qmlproperty Item StatusMainLayout::leftPanel
        This property holds the left panel of the component.
    */
    property Item leftPanel
    /*!
        \qmlproperty Item StatusMainLayout::rightPanel
        This property holds the right panel of the component.
    */
    property Item rightPanel

    handle: Item { }
    background: Rectangle {
        color: Theme.palette.statusAppLayout.backgroundColor
    }

    Control {
        SplitView.preferredWidth: !!leftPanel && leftPanel.visible ? leftPanel.width : 0
        SplitView.fillHeight: true
        background: null
        visible: (!!leftPanel)
        contentItem: (!!leftPanel) ? leftPanel : null
    }

    Control {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        background: null
        contentItem: (!!rightPanel) ? rightPanel : null
    }
}
