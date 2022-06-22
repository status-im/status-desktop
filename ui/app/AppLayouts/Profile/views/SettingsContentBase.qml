import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string sectionTitle
    property int contentWidth

    property string backButtonName: ""

    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    default property Item content

    property bool dirty: false
    property bool saveChangesButtonEnabled: false

    signal backButtonClicked()
    signal baseAreaClicked()
    signal saveChangesClicked()
    signal resetChangesClicked()

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty();
    }

    QtObject {
        id: d

        readonly property int topHeaderHeight: 56
        readonly property int titleRowHeight: 56
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { root.baseAreaClicked() }
    }

    Component.onCompleted: {
        content.parent = contentWrapper

        if (headerComponents.length) {
            for (let i in headerComponents) {
                headerComponents[i].parent = titleRow
            }
        }
    }

    Item {
        id: topHeader
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: -Style.current.padding
        width: root.contentWidth + Style.current.padding
        height: d.topHeaderHeight

        StatusFlatButton {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Style.current.halfPadding
            visible: root.backButtonName != ""
            icon.name: "arrow-left"
            icon.width: 20
            icon.height: 20
            text: root.backButtonName
            size: StatusBaseButton.Size.Large
            onClicked: root.backButtonClicked()
        }
    }

    RowLayout {
        id: titleRow
        anchors.left: parent.left
        anchors.top: topHeader.bottom
        anchors.leftMargin: Style.current.padding
        width: root.contentWidth - 2 * Style.current.padding
        height: d.titleRowHeight
        visible: root.sectionTitle !== ""

        StatusBaseText {
            Layout.fillWidth: true
            text: root.sectionTitle
            font.weight: Font.Bold
            font.pixelSize: Constants.settingsSection.mainHeaderFontSize
            color: Theme.palette.directColor1
        }

        Loader {
            id: loader
        }
    }

    ScrollView {
        id: scrollView
        anchors.top: titleRow.visible ? titleRow.bottom : topHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: Style.current.bigPadding
        width: root.contentWidth
        clip: true

        Flickable {
            id: contentFliackable
            contentWidth: Math.max(contentLayout.implicitWidth, scrollView.width)
            contentHeight: Math.max(contentLayout.implicitHeight, scrollView.height) + scrollView.anchors.topMargin

            Column {
                id: contentLayout
                anchors.fill: parent.contentItem

                MouseArea {
                    onClicked: root.baseAreaClicked()
                    width: contentWrapper.implicitWidth
                    height: contentWrapper.implicitHeight

                    Column {
                        id: contentWrapper
                    }
                }

                Item {
                    // This is a settingsDirtyToastMessage placeholder
                    width: settingsDirtyToastMessage.implicitWidth
                    height: settingsDirtyToastMessage.active ? settingsDirtyToastMessage.implicitHeight : 0

                    Behavior on implicitHeight {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }

    SettingsDirtyToastMessage {
        id: settingsDirtyToastMessage
        anchors.bottom: scrollView.bottom
        anchors.horizontalCenter: scrollView.horizontalCenter
        active: root.dirty
        flickable: contentFliackable
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
    }
}
