import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
/*!
     \qmltype StatusSectionLayout
     \inherits SplitView
     \inqmlmodule StatusQ.Layout
     \since StatusQ.Layout 0.1
     \brief Displays a three column layout with a header in the central panel.
     Inherits \l{https://doc.qt.io/qt-6/qml-qtquick-controls2-splitview.html}{SplitView}.

     The \c StatusSectionLayout displays a three column layout with a header in the central panel to be used as the base layout of all application
     sections.
     For example:

     \qml
    StatusSectionLayout {
        id: root

        notificationCount: 1
        onNotificationButtonClicked: { showActivityCenter(); }

        headerContent: RowLayout {
            ...
        }

        leftPanel: Item {
            ...
        }

        centerPanel: Item {
            ...
        }

        rightPanel: Item {
            ...
        }
     }
     \endqml

     For a list of components available see StatusQ.
*/

SplitView {
    id: root
    implicitWidth: 822
    implicitHeight: 600

    handle: Item { }

    /*!
        \qmlproperty Item StatusAppLayout::leftPanel
        This property holds the left panel of the component.
    */
    property Item leftPanel
    /*!
        \qmlproperty Item StatusAppLayout::centerPanel
        This property holds the center panel of the component.
    */
    property Item centerPanel
    /*!
        \qmlproperty Component StatusAppLayout::rightPanel
        This property holds the right panel of the component.
    */
    property Component rightPanel

    /*!
        \qmlproperty bool StatusAppLayout::showRightPanel
        This property sets the right panel component's visibility to true/false.
        Default value is false.
    */
    property bool showRightPanel: false
    /*!
        \qmlproperty bool StatusAppLayout::showHeader
        This property sets the header component's visibility to true/false.
        Default value is true.
    */
    property bool showHeader: true

    /*!
        \qmlproperty int StatusAppLayout::notificationCount
        This property holds the number of notifications to be displayed in the notifications
        button of the header component.
    */
    property alias notificationCount: statusToolBar.notificationCount
    /*!
        \qmlproperty alias StatusAppLayout::headerContent
        This property holds a reference to the custom header content of
        the header component.
    */
    property alias headerContent: statusToolBar.headerContent
    /*!
        \qmlproperty alias StatusAppLayout::notificationButton
        This property holds a reference to the notification button of the header
        component.
    */
    property alias notificationButton: statusToolBar.notificationButton

    /*!
        \qmlsignal
        This signal is emitted when the notification button of the header component
        is pressed.
    */
    signal notificationButtonClicked()

    onCenterPanelChanged: {
        if (!!centerPanel) {
            centerPanel.parent = centerPanelSlot;
        }
    }

    Control {
        SplitView.minimumWidth: (!!leftPanel) ? 300 : 0
        SplitView.preferredWidth: (!!leftPanel) ? 300 : 0
        SplitView.fillHeight: (!!leftPanel)
        background: Rectangle {
            color: Theme.palette.baseColor4
        }
        contentItem: (!!leftPanel) ? leftPanel : null
    }

    Control {
        SplitView.minimumWidth: (!!centerPanel) ? 300 : 0
        SplitView.fillWidth: (!!centerPanel)
        SplitView.fillHeight: (!!centerPanel)
        background: Rectangle {
            color: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        }
        contentItem: Item {
            StatusToolBar {
                id: statusToolBar
                width: visible ? parent.width : 0
                visible: root.showHeader
                onNotificationButtonClicked: {
                    root.notificationButtonClicked();
                }
            }
            Item {
                id: centerPanelSlot
                width: parent.width
                anchors.top: statusToolBar.bottom
                anchors.bottom: parent.bottom
            }
        }
    }

    Control {
        SplitView.preferredWidth: root.showRightPanel ? 250 : 0
        SplitView.minimumWidth: root.showRightPanel ? 58 : 0
        opacity: root.showRightPanel ? 1.0 : 0.0
        visible: (opacity > 0.1)
        background: Rectangle {
            color: Theme.palette.baseColor4
        }
        contentItem: Loader {
            sourceComponent: (!!rightPanel) ? rightPanel : null
        }
    }
}
