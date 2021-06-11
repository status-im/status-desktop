import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: statusAppNavBar

    property StatusNavBarTabButton navBarChatButton
    property list<StatusNavBarTabButton> navBarTabButtons
    property alias navBarCommunityTabButtons: navBarCommunityTabButtons

    property int navBarContentHeight: 0
    property int navBarContentHeightWithoutCommunityButtons: 0

    width: 78
    implicitHeight: 600
    color: Theme.palette.statusAppNavBar.backgroundColor

    Component.onCompleted: {
        navBarContentHeightWithoutCommunityButtons = (navBarChatButtonSlot.anchors.topMargin + navBarChatButtonSlot.height) + 
                                  (separator.anchors.topMargin + separator.height) +
                                  (navBarTabButtonsSlot.height + navBarTabButtonsSlot.anchors.topMargin + navBarTabButtonsSlot.anchors.bottomMargin)
        navBarContentHeight = navBarContentHeightWithoutCommunityButtons +
                              (navBarCommunityTabButtonsSlot.height + navBarScrollSection.anchors.topMargin)
    }

    onNavBarChatButtonChanged: {
        if (!!navBarChatButton) {
            navBarChatButton.parent = navBarChatButtonSlot
        }
    }

    onNavBarTabButtonsChanged: {
        if (navBarTabButtons.length) {
            for (let idx in navBarTabButtons) {
                navBarTabButtons[idx].parent = navBarTabButtonsSlot
            }
        }
    }

    Item {
        id: navBarChatButtonSlot
        anchors.top: parent.top
        anchors.topMargin: 48
        anchors.horizontalCenter: parent.horizontalCenter
        height: visible ? statusAppNavBar.navBarChatButton.height : 0
        width: visible ? statusAppNavBar.navBarChatButton.width : 0
        visible: !!statusAppNavBar.navBarChatButton
    }

    Rectangle {
        id: separatorTop
        height: 1
        width: 30
        color: Theme.palette.directColor7
        anchors.top: navBarChatButtonSlot.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        visible: separator.anchors.topMargin === 0
    }

    ScrollView {
        id: navBarScrollSection
        anchors.top: separatorTop.visible ? separatorTop.bottom : navBarChatButtonSlot.bottom
        anchors.topMargin: separatorTop.visible ? 0 : 12
        anchors.horizontalCenter: statusAppNavBar.horizontalCenter
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        Component.onCompleted: {
            if (navBarContentHeight > statusAppNavBar.height) {
                height = statusAppNavBar.height - 
                         statusAppNavBar.navBarContentHeightWithoutCommunityButtons -
                         (!!navBarTabButtonsSlot.anchors.bottom ? navBarTabButtonsSlot.anchors.bottomMargin : navBarTabButtonsSlot.anchors.topMargin)
                bottomPadding = 16
                topPadding = 16
            } else {
                height = navBarCommunityTabButtons.count > 0 ? navBarCommunityTabButtonsSlot.implicitHeight : 0
            }
        }

        Column {
            id: navBarCommunityTabButtonsSlot
            width: navBarScrollSection.width
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            onImplicitHeightChanged: {
                statusAppNavBar.Component.onCompleted()
                navBarTabButtonsSlot.Component.onCompleted()
                navBarScrollSection.Component.onCompleted()
            }

            Repeater {
                id: navBarCommunityTabButtons
            }
        }
    }

    Rectangle {
        id: separator
        height: 1
        width: 30
        color: Theme.palette.directColor7
        anchors.top: !!navBarCommunityTabButtons.model && navBarCommunityTabButtons.count > 0 ? navBarScrollSection.bottom : navBarChatButtonSlot.bottom
        anchors.topMargin: navBarScrollSection.height < navBarCommunityTabButtonsSlot.implicitHeight ? 0 : 16
        anchors.horizontalCenter: parent.horizontalCenter
        visible: navBarChatButton !== null && navBarTabButtons.length > 0
    }

    Column {
        id: navBarTabButtonsSlot
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Component.onCompleted: {
            if (navBarContentHeight > statusAppNavBar.height) {
                anchors.top = undefined
                anchors.topMargin = 0
                anchors.bottom = statusAppNavBar.bottom
                anchors.bottomMargin = 32
            } else {
                anchors.bottom = undefined
                anchors.bottomMargin = 0
                anchors.top = separator.visible ? separator.bottom : parent.top
                anchors.topMargin = separator.visible ? 16 : navBarChatButtonSlot.anchors.topMargin
            }
        }
    }
}

