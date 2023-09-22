import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

import utils 1.0

Rectangle {
    id: root

    color: Style.current.modalBackground
    radius: Style.current.radius
    border.color: Style.current.grey3
    border.width: 2

    signal close()

    QtObject {
        id: d

        property int btnWidth: 30
        property int btnHeight: 30
        property int margin: 8

        property bool minimized: false
        property int maxWidth
        property int maxHeight
        onMinimizedChanged: {
            if (minimized) {
                d.maxWidth = root.width
                d.maxHeight = root.height
                root.width = header.implicitWidth + 2 * d.margin
                root.height = header.implicitHeight + 2 * d.margin
                return
            }
            root.width = d.maxWidth
            root.height = d.maxHeight
        }
    }

    Row {
        id: header
        anchors.right: parent.right
        anchors.rightMargin: d.margin
        anchors.top: parent.top
        anchors.topMargin: d.margin
        spacing: d.margin

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            icon.name: d.minimized? "chevron-up" : "chevron-down"
            icon.color: Theme.palette.directColor1
            implicitWidth: d.btnWidth
            implicitHeight: d.btnHeight
            onClicked: {
                d.minimized = !d.minimized
            }
        }

        StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            icon.name: "close"
            icon.color: Theme.palette.directColor1
            implicitWidth: d.btnWidth
            implicitHeight: d.btnHeight
            onClicked: {
                root.close()
            }
        }
    }

    MockedKeycardReaderStateSelector {
        id: readerState
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Style.current.bigPadding
        anchors.leftMargin: Style.current.bigPadding
        visible: !d.minimized
        title: qsTr("Initial reader state")
    }

    StatusTabBar {
        id: tabBar
        anchors.top: readerState.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.current.bigPadding
        visible: !d.minimized

        StatusTabButton {
            width: implicitWidth
            leftPadding: 0
            text: qsTr("Keycard-1")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Keycard-2")
        }
    }

    StackLayout {
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.current.halfPadding
        visible: !d.minimized
        currentIndex: tabBar.currentIndex

        KeycardSettingsTab {
            cardIndex: 1

            onRegisterKeycard: {
                mainModule.registerMockedKeycard(cardIndex, readerState.selectedState, kcState, kc, kcHelper)
            }
        }

        KeycardSettingsTab {
            cardIndex: 2

            onRegisterKeycard: {
                mainModule.registerMockedKeycard(cardIndex, MockedKeycardReaderStateSelector.NoKeycard, kcState, kc, kcHelper)
            }
        }
    }

    component KeycardSettingsTab: StatusScrollView {
        id: keycardSettingsTabRoot

        property int cardIndex

        signal registerKeycard(int kcState, string kc, string kcHelper)

        ColumnLayout {
            spacing: 16

            MockedKeycardStateSelector {
                id: keycardState
                title: qsTr("Keycard %1 - initial keycard state").arg(keycardSettingsTabRoot.cardIndex)
            }

            Column {
                id: customSection
                visible: keycardState.selectedState === MockedKeycardStateSelector.CustomKeycard
                spacing: 16

                StatusInput {
                    id: mockedKeycard
                    label: qsTr("Mocked Keycard")
                    implicitWidth: 400
                    minimumHeight: 200
                    maximumHeight: 200
                    input.multiline: true
                    input.verticalAlignment: TextEdit.AlignTop
                    placeholderText: qsTr("Enter json form of status-go MockedKeycard")
                    errorMessageCmp.text: qsTr("Invalid json format")
                }

                StatusInput {
                    id: mockedKeycardHelper
                    label: qsTr("Specific keycard details")
                    implicitWidth: 400
                    minimumHeight: 200
                    maximumHeight: 200
                    input.multiline: true
                    input.verticalAlignment: TextEdit.AlignTop
                    placeholderText: qsTr("Enter json form of status-go MockedKeycard")
                    errorMessageCmp.text: qsTr("Invalid json format")
                }
            }

            StatusButton {
                text: qsTr("Register Keycard")
                onClicked: {
                    if (customSection.visible) {
                        mockedKeycard.input.valid = true
                        mockedKeycardHelper.input.valid = true

                        if (mockedKeycard.text != "") {
                            try {
                                JSON.parse(mockedKeycard.text)
                            }
                            catch(e) {
                                mockedKeycard.input.valid = false
                            }
                        }
                        if (mockedKeycardHelper.text != "") {
                            try {
                                JSON.parse(mockedKeycardHelper.text)
                            }
                            catch(e) {
                                mockedKeycardHelper.input.valid = false
                            }
                        }

                        if (!mockedKeycard.input.valid || !mockedKeycardHelper.input.valid) {
                            return
                        }
                    }

                    keycardSettingsTabRoot.registerKeycard(keycardState.selectedState,
                                                           mockedKeycard.text,
                                                           mockedKeycardHelper.text)
                }
            }
        }
    }
}
