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
        \qmlproperty Item StatusSectionLayout::leftPanel
        This property holds the left panel of the component.
    */
    property Item leftPanel
    /*!
        \qmlproperty Item StatusSectionLayout::centerPanel
        This property holds the center panel of the component.
    */
    property Item centerPanel
    /*!
        \qmlproperty Component StatusSectionLayout::rightPanel
        This property holds the right panel of the component.
    */
    property Component rightPanel
    /*!
        \qmlproperty Item StatusSectionLayout::footer
        This property holds the footer of the component.
    */
    property Item footer
    /*!
        \qmlproperty Component StatusAppLayout::headerBackground
        This property holds the headerBackground of the component.
    */
    property Item headerBackground
    /*!
        \qmlproperty bool StatusSectionLayout::showRightPanel
        This property sets the right panel component's visibility to true/false.
        Default value is false.
    */
    property bool showRightPanel: false

    /*!
        \qmlproperty int StatusSectionLayout::rightPanelWidth
        This property sets the right panel component's width.
        Default value is 250.
    */
    property int rightPanelWidth: 250
    /*!
        \qmlproperty bool StatusSectionLayout::showHeader
        This property sets the header component's visibility to true/false.
        Default value is true.
    */
    property bool showHeader: true

    /*!
        \qmlproperty alias StatusSectionLayout::notificationCount
        This property holds a reference to the notificationCount property of the
        header component.
    */
    property alias notificationCount: statusToolBar.notificationCount

    /*!
        \qmlproperty alias StatusSectionLayout::hasUnseenNotifications
        This property holds a reference to the hasUnseenNotifications property of the
        header component.
    */
    property alias hasUnseenNotifications: statusToolBar.hasUnseenNotifications

    /*!
        \qmlproperty alias StatusSectionLayout::backButtonName
        This property holds a reference to the backButtonName property of the
        header component.
    */
    property alias backButtonName: statusToolBar.backButtonName

    /*!
        \qmlproperty alias StatusSectionLayout::headerContent
        This property holds a reference to the custom header content of
        the header component.
    */
    property alias headerContent: statusToolBar.headerContent
    /*!
        \qmlproperty alias StatusSectionLayout::notificationButton
        This property holds a reference to the notification button of the header
        component.
    */
    property alias notificationButton: statusToolBar.notificationButton

    /*!
        \qmlsignal
        This signal is emitted when the back button of the header component
        is pressed.
    */
    signal backButtonClicked()

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

    onFooterChanged: {
        if (!!footer) {
            footer.parent = footerSlot
        }
    }

    onHeaderBackgroundChanged:  {
        if (!!headerBackground) {
            headerBackground.parent = headerBackgroundSlot
        }
    }

    Control {
        SplitView.minimumWidth: (!!leftPanel) ? 304 : 0
        SplitView.preferredWidth: (!!leftPanel) ? 304 : 0
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
            Item {
                id: headerBackgroundSlot
                anchors.top: parent.top
                // Needed cause I see a gap otherwise
                anchors.topMargin: -3
                width: visible ? parent.width : 0
                height: visible ? childrenRect.height : 0
                visible: (!!headerBackground)
            }
            StatusToolBar {
                id: statusToolBar
                anchors.top: parent.top
                width: visible ? parent.width : 0
                visible: root.showHeader
                onBackButtonClicked: {
                    root.backButtonClicked();
                }
                onNotificationButtonClicked: {
                    root.notificationButtonClicked();
                }
            }
            Item {
                id: centerPanelSlot
                width: parent.width
                anchors.top: statusToolBar.bottom
                anchors.bottom: footerSlot.top
                anchors.bottomMargin: footerSlot.visible ? 8 : 0
            }
            Item {
                id: footerSlot
                width: parent.width
                height: visible ? childrenRect.height : 0
                anchors.bottom: parent.bottom
                visible: (!!footer)
            }
        }
    }

    Control {
        SplitView.preferredWidth: root.showRightPanel ? root.rightPanelWidth : 0
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
