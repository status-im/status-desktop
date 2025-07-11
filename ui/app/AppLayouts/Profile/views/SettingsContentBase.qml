import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared.popups

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

FocusScope {
    id: root

    property string sectionTitle
    property int contentWidth
    readonly property int contentHeight: root.height - titleRow.height - Theme.padding

    property alias titleRowLeftComponentLoader: leftLoader
    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    property alias bottomHeaderComponents: secondHeaderRow.contentItem
    default property alias content: contentWrapper.data
    property alias titleLayout: titleLayout

    property bool stickTitleRowComponentLoader: false

    property bool dirty: false

    // Used to configure the dirty behaviour of the settings page as a must blocker notification when
    // user wants to leave the current page or just, ignore the changes done. Default: blocker
    property bool ignoreDirty: false

    property bool saveChangesButtonEnabled: false
    readonly property alias toast: settingsDirtyToastMessage

    // Used to configure the dirty toast behaviour (by default overlay on top of content)
    property bool autoscrollWhenDirty: false

    readonly property real availableHeight:
        scrollView.availableHeight - settingsDirtyToastMessagePlaceholder.height
        - Theme.bigPadding

    signal baseAreaClicked()
    signal saveChangesClicked()
    signal saveForLaterClicked()
    signal resetChangesClicked()

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty();
    }

    QtObject {
        id: d

        readonly property int titleRowHeight: 56
        readonly property int bottomDirtyToastMargin: 36
    }

    StatusMouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: { root.baseAreaClicked() }
    }

    Component.onCompleted: {
        if (headerComponents.length) {
            for (let i in headerComponents) {
                headerComponents[i].parent = titleRow
            }
        }
    }

    ColumnLayout {
        id: titleRow
        width: root.contentWidth
        spacing: 0

        RowLayout {
            id: titleLayout
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? d.titleRowHeight : 0
            visible: (root.sectionTitle !== "")

            Loader {
                id: leftLoader
            }

            StatusBaseText {
                Layout.fillWidth: !root.stickTitleRowComponentLoader
                text: root.sectionTitle
                font.weight: Font.Bold
                font.pixelSize: Constants.settingsSection.mainHeaderFontSize
                color: Theme.palette.directColor1
            }

            Loader {
                id: loader
                Layout.leftMargin: root.stickTitleRowComponentLoader ? 8 : 0
            }
        }
        Control {
            id: secondHeaderRow
            Layout.fillWidth: true
            visible: !!contentItem
        }
    }

    StatusScrollView {
        id: scrollView
        objectName: "settingsContentBaseScrollView"
        anchors.top: titleRow.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: titleLayout.visible ? Theme.padding: 0
        padding: 0
        width: root.width
        contentWidth: root.contentWidth
        contentHeight: contentLayout.implicitHeight + Theme.bigPadding

        Column {
            id: contentLayout
            width: scrollView.availableWidth

            StatusMouseArea {
                onClicked: root.baseAreaClicked()
                width: contentWrapper.implicitWidth
                height: contentWrapper.implicitHeight
                hoverEnabled: true
                propagateComposedEvents: true

                Column {
                    id: contentWrapper
                    onVisibleChanged: if (visible) forceActiveFocus()
                }
            }

            // Used only when dirty toast visible and in case of autoscrolling configuration
            Item {
                id: settingsDirtyToastMessagePlaceholder

                width: settingsDirtyToastMessage.implicitWidth
                height: settingsDirtyToastMessage.active && root.autoscrollWhenDirty ?
                            (settingsDirtyToastMessage.implicitHeight + d.bottomDirtyToastMargin) : 0 /*Overlay on top of content*/

                Behavior on implicitHeight {
                    enabled: root.autoscrollWhenDirty
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SettingsDirtyToastMessage {
        id: settingsDirtyToastMessage
        anchors.bottom: scrollView.bottom
        anchors.bottomMargin: d.bottomDirtyToastMargin

        // Left anchors and margin added bc of the implementation of the `SettingsContentBase` parent margin and to avoid
        // this toast to be wrongly centered
        // Constants.settingsSection.leftMargin is the margin set up to the parent when using `SettingsContentBase` inside central
        // panel property of `StatusSectionLayout` and needs to be taken into account to counteract it
        // when trying to align horizontally the save toast component
        anchors.left: root.left
        anchors.leftMargin: -Constants.settingsSection.leftMargin / 2 + (root.width / 2 - width / 2)

        active: root.dirty
        flickable: root.autoscrollWhenDirty ? scrollView.flickable : null
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
        onSaveForLaterClicked: root.saveForLaterClicked()
    }
}
