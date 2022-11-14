import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.stores 1.0
import AppLayouts.Onboarding.shared 1.0

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    states: [
        State {
            name: Constants.startupState.profileFetching
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetching
            PropertyChanges {
                target: description;
                text: Constants.onboarding.profileFetching.descriptionForFetchingStarted
                nextText: Constants.onboarding.profileFetching.descriptionForFetchingInProgress
            }
        },
        State {
            name: Constants.startupState.profileFetchingCompleted
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetchingCompleted
            PropertyChanges { target: title; text: Constants.onboarding.profileFetching.titleForSuccess }
        },
        State {
            name: Constants.startupState.profileFetchingError
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetchingError
            PropertyChanges { target: title; text: Constants.onboarding.profileFetching.titleForError }
            PropertyChanges { target: description; text: Constants.onboarding.profileFetching.descriptionForError }
            PropertyChanges { target: button; visible: true}
            PropertyChanges { target: link; visible: true }
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.keycard.general.onboardingHeight
        spacing: Style.current.bigPadding

        ProfileFetchingAnimation {
            id: loadingAnimation
            Layout.alignment: Qt.AlignHCenter
            state: root.state
        }

        StatusBaseText {
            id: title
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: Constants.onboarding.profileFetching.titleFontSize
        }

        StatusBaseText {
            id: description
            property string nextText: ""
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            visible: text.length > 0
            wrapMode: Text.WordWrap
            color: Style.current.secondaryText
            font.pixelSize: Constants.onboarding.profileFetching.descriptionFontSize
            Timer {
                id: nextTextTimer
                interval: 2500
                running: description.nextText !== ""
                onTriggered: { description.text = description.nextText }
            }
        }

        StatusButton {
            id: button
            visible: false
            Layout.alignment: Qt.AlignHCenter
            focus: true
            text: Constants.onboarding.profileFetching.tryAgainText
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }

        StatusBaseText {
            id: link
            visible: false
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Constants.keycard.general.buttonFontSize
            text: Constants.onboarding.profileFetching.createNewProfileText
            color: Theme.palette.primaryColor1
            font.underline: linkMouseArea.containsMouse
            MouseArea {
                id: linkMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    root.startupStore.doSecondaryAction()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
