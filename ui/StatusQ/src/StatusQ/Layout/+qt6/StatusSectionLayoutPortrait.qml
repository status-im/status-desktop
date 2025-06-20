import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
/*!
     \qmltype StatusSectionLayoutPortrait
     \inherits SwipeView
     \inqmlmodule StatusQ.Layout
     \since StatusQ.Layout 0.1
     \brief Displays a three views swipe layout with a header in the central panel.
     Inherits \l{https://doc.qt.io/qt-6/qml-qtquick-controls2-splitview.html}{SplitView}.

     The \c StatusSectionLayoutPortrait displays a three views swipe layout with a header in the central panel to be used as the base layout of all application
     sections.
     For example:

     \qml
    StatusSectionLayoutPortrait {
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

SwipeView {
    id: root
    implicitWidth: 822
    implicitHeight: 600

    // handle: Item { }
    property Item navBar: null
    /*!
        \qmlproperty Item StatusSectionLayout::leftPanel
        This property holds the left panel of the component.
    */
    property alias leftPanel: leftPanelProxy.target
    /*!
        \qmlproperty Item StatusSectionLayout::centerPanel
        This property holds the center panel of the component.
    */
    property alias centerPanel: centerPanelProxy.target
    /*!
        \qmlproperty Component StatusSectionLayout::rightPanel
        This property holds the right panel of the component.
    */
    property alias rightPanel: rightPanelProxy.target
    /*!
        \qmlproperty Item StatusSectionLayout::footer
        This property holds the footer of the component.
    */
    property alias footer: footerProxy.target
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
    property Item headerContent
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

    QtObject {
        id: d
        // Cache wrapper items removed from the swipe view
        property list<Item> items: []
    }

    component BaseProxyPanel : Control {
        id: baseProxyPanel
        readonly property int index: SwipeView.index !== undefined ? SwipeView.index : -1

        property color backgroundColor
        property Item target: null
        property int implicitIndex
        property bool inView: true

        background: Rectangle {
            color: backgroundColor || Theme.palette.statusAppLayout.rightPanelBackgroundColor
        }
        onInViewChanged: {
            // If the panel is not in view, we need to remove it from the swipe view
            // and add it to the cache wrapper items so that we can restore it later if needed.
            if (!inView && !!parent) {
                d.items.push(root.takeItem(baseProxyPanel.implicitIndex));
            } else if (inView && !parent) {
                root.insertItem(implicitIndex, baseProxyPanel)
                d.items.splice(d.items.indexOf(this), 1);
            }
        }
        contentItem: RowLayout {
            spacing: 0
            LayoutItemProxy {
                Layout.fillHeight: true
                target: root.navBar
                visible: baseProxyPanel.index === 0
            }
            LayoutItemProxy {
                Layout.fillWidth: true
                Layout.fillHeight: true
                target: baseProxyPanel.target
            }
        }
    }

    BaseProxyPanel {
        id: leftPanelProxy
        backgroundColor: Theme.palette.baseColor4
        implicitIndex: 0
        inView: !!root.leftPanel
    }

    BaseProxyPanel {
        id: centerPanelBase
        backgroundColor: Theme.palette.statusAppLayout.rightPanelBackgroundColor
        implicitIndex: 1
        inView: !!root.centerPanel
        target: ColumnLayout {
            objectName: "centerPanelLayout"
            anchors.fill: parent
            spacing: 0
            Item {
                Layout.fillWidth: true
                implicitHeight: headerBackgroundProxy.implicitHeight
                LayoutItemProxy {
                    id: headerBackgroundProxy
                    anchors.fill: parent
                    target: root.headerBackground
                }
                BaseToolBar {
                    id: statusToolBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    headerContent: LayoutItemProxy {
                        id: headerContentProxy
                        target: root.headerContent
                    }
                }
            }
            LayoutItemProxy {
                id: centerPanelProxy
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: statusToolBar.height - headerBackgroundProxy.height
                implicitHeight: centerPanel ? centerPanel.implicitHeight : 0
                implicitWidth: centerPanel ? centerPanel.implicitWidth : 0
            }
            LayoutItemProxy {
                id: footerProxy
                Layout.fillWidth: true
                Layout.preferredHeight: footer ? footer.implicitHeight : 0
                Layout.alignment: Qt.AlignBottom
            }
        }
    }

    BaseProxyPanel {
        backgroundColor: Theme.palette.baseColor4
        implicitIndex: 2
        inView: !!root.rightPanel && root.showRightPanel
        target: ColumnLayout {
            objectName: "rightPanelLayout"
            anchors.fill: parent
            spacing: 0
            BaseToolBar {
                Layout.fillWidth: true
            }
            LayoutItemProxy {
                id: rightPanelProxy
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    component BaseToolBar: StatusToolBar {
        visible: root.showHeader
        backButtonVisible: root.currentIndex !== 0
        onBackButtonClicked: {
            if (!root.backButtonName) {
                root.currentIndex = root.currentIndex - 1
                return
            }
            root.backButtonClicked();
        }
        onNotificationButtonClicked: {
            root.notificationButtonClicked();
        }
    }
}
