import QtQuick 2.13
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

/*!
   \qmltype StatusCard
   \inherits Rectangle
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief This component represents a StatusCard as defined in design under https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=3161%3A171040

   There is an advanced mode avialable where a StatusBaseInput is provided for the user to be able to change values.

   Example of how the component looks like:
   \image status_card.png

   Example of how to use it:
   \qml
        StatusCard {
            id: card
            primaryText: "Mainnet"
            secondaryText: "75"
            tertiaryText: "BALANCE: " + 250
            cardIconName: "status"
            advancedMode: false
        }
   \endqml
   For a list of components available see StatusQ.
*/

Rectangle {
    id: root

    /*!
       \qmlproperty string StatusCard::disabledText
       This property is the text to be shown when the card is disabled
    */
    property string disabledText: ""
    /*!
       \qmlproperty bool StatusCard::disabled
        This property holds if the card is disbaled
    */
    property bool disabled: false

    /*!
       \qmlproperty bool StatusCard::clickable
        This property holds if the card is clickable
    */
    property bool clickable: true

    /*!
       \qmlproperty bool StatusCard::advancedMode
       This property holds if advanced mode is on for the StatusCard component
    */
    property bool advancedMode: false
    /*!
       \qmlproperty int StatusCard::lockTimeout
       This property enables user to customise the amount of time given to the user to enter a new value in
       advanced mode before it locked for any new changes
    */
    property int lockTimeout: 1500

    /*!
       \qmlproperty alias StatusCard::primaryText
       Used to set Primary text in the StatusCard
    */
    property alias primaryText: primaryText.text
    /*!
       \qmlproperty string StatusCard::secondaryText
       Used to set Secondary text in the StatusCard
    */
    property string secondaryText: ""
    /*!
       \qmlproperty alias StatusCard::tertiaryText
       Used to set Tertiary text in the StatusCard
    */
    property alias tertiaryText: tertiaryText.text
    /*!
       \qmlproperty alias StatusCard::advancedInputText
       Used to set text in the StatusBaseInput in advancedMode
    */
    property alias advancedInputText: advancedInput.text
    /*!
       \qmlproperty alias StatusCard::errorIconName
       Used to assign an icon to the error icon in StatusCard
    */
    property alias errorIconName: errorIcon.icon
    /*!
       \qmlproperty alias StatusCard::cardIconName
       Used to assign an icon to the card icon in StatusCard
    */
    property alias cardIconName: cardIcon.icon

    /*!
       \qmlproperty alias StatusCard::primaryLabel
       This property allows user to customize the primary label in the StatusCard
    */
    property alias primaryLabel: primaryText
    /*!
       \qmlproperty alias StatusCard::secondaryLabel
       This property allows user to customize the secondary label in the StatusCard
    */
    property alias secondaryLabel: secondaryLabel
    /*!
       \qmlproperty alias StatusCard::tertiaryLabel
       This property allows user to customize the tertiary label in the StatusCard
    */
    property alias tertiaryLabel: tertiaryText
    /*!
       \qmlproperty alias StatusCard::advancedInput
       This property allows user to customize the StatusBaseInput in advanced mode
    */
    property alias advancedInput: advancedInput
    /*!
       \qmlproperty alias StatusCard::errorIcon
       This property allows user to customize the error icon in the StatusCard
    */
    property alias errorIcon: errorIcon
    /*!
       \qmlproperty alias StatusCard::cardIcon
       This property allows user to customize the card icon in the StatusCard
    */
    property alias cardIcon: cardIcon

    /*!
        \qmlsignal StatusCard::clicked
        This signal is emitted when the card is clicked
    */
    signal clicked()

    /*!
       \qmlproperty string StatusCard::state
       This property holds the states of the StatusCard.
       Possible values are:
        \ "default" : Normal state
        \ "unavailable" : Unavailable state
        \ "unpreferred": Not preffered state
        \ "error" : Error state
    */
    state: "default"

    implicitHeight: advancedInput.visible ? 90 : 76
    implicitWidth: 128
    radius: 8

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        enabled: root.clickable && root.state !== "unavailable"
        onClicked: {
            disabled = !disabled
            root.clicked()
        }
    }

    RowLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 8
        ColumnLayout {
            Layout.maximumWidth: root.width - cardIcon.width - 24
            StatusBaseText {
                id: primaryText
                Layout.maximumWidth: parent.width
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            RowLayout {
                id: basicInput
                StatusBaseText {
                    id: secondaryLabel
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                StatusIcon {
                    id: errorIcon
                    width: 14
                    height: 14
                    Layout.alignment: Qt.AlignTop
                    icon: "tiny/warning"
                    color: Theme.palette.pinColor1
                }
            }

            StatusBaseInput {
                id: advancedInput
                property bool locked: false
                implicitWidth: 80
                implicitHeight: 32
                topPadding: 0
                bottomPadding: 0
                leftPadding: 8
                rightPadding: 5
                edit.font.pixelSize: 13
                edit.readOnly: locked || disabled
                rightComponent: Row {
                    width: implicitWidth
                    spacing: 4
                    StatusFlatRoundButton {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12
                        height: 12
                        icon.name: advancedInput.locked ? "lock" : "unlock"
                        icon.width: 12
                        icon.height: 12
                        icon.color: advancedInput.locked ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                        type: StatusFlatRoundButton.Type.Secondary
                        enabled: !disabled
                        onClicked: {
                            advancedInput.locked = !advancedInput.locked
                            waitTimer.restart()
                        }
                    }
                    StatusFlatRoundButton {
                        width: 14
                        height: 14
                        icon.name: "clear"
                        icon.width: 14
                        icon.height: 14
                        icon.color: Theme.palette.baseColor1
                        type: StatusFlatRoundButton.Type.Secondary
                        onClicked: advancedInput.edit.clear()
                    }
                }
                onTextChanged: {
                    locked = false
                    waitTimer.restart()
                }
                Timer {
                    id: waitTimer
                    interval: lockTimeout
                    onTriggered: {
                        if(advancedInput.edit.text)
                            advancedInput.locked = true
                    }
                }
            }
            StatusBaseText {
                id: tertiaryText
                font.pixelSize: 10
            }
        }
        StatusIcon {
            id: cardIcon
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            mipmap: true
        }
    }

    states: [
        State {
            name: "default"
            PropertyChanges {
                target: root
                color: disabled ? Theme.palette.baseColor4 : "transparent"
            }
            PropertyChanges {
                target: root
                border.color: disabled ? "transparent" : Theme.palette.primaryColor2
            }
            PropertyChanges {
                target: primaryText
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: primaryText
                visible: primaryText.text
            }
            PropertyChanges {
                target: secondaryLabel
                color: disabled ? Theme.palette.directColor5: Theme.palette.primaryColor1
            }
            PropertyChanges {
                target: secondaryLabel
                visible: !advancedMode && secondaryLabel.text
            }
            PropertyChanges {
                target: secondaryLabel
                text: disabled ? disabledText : secondaryText
            }
            PropertyChanges {
                target: tertiaryText
                color: Theme.palette.directColor5
            }
            PropertyChanges {
                target: tertiaryText
                visible: tertiaryText.text
            }
            PropertyChanges {
                target: cardIcon
                opacity: disabled ?  0.4 : 1
            }
            PropertyChanges {
                target: errorIcon
                visible: false
            }
            PropertyChanges {
                target: advancedInput
                visible: advancedMode
            }
            PropertyChanges {
                target: advancedInput
                edit.color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: basicInput
                visible: !advancedMode
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: root
                color: disabled ? Theme.palette.baseColor4 : "transparent"
            }
            PropertyChanges {
                target: root
                border.color: disabled ? "transparent" : Theme.palette.primaryColor2
            }
            PropertyChanges {
                target: primaryText
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: primaryText
                visible: primaryText.text
            }
            PropertyChanges {
                target: secondaryLabel
                color: disabled ? Theme.palette.directColor5: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: secondaryLabel
                visible: !advancedMode && secondaryLabel.text
            }
            PropertyChanges {
                target: secondaryLabel
                text: disabled ? disabledText : secondaryText
            }
            PropertyChanges {
                target: tertiaryText
                color: disabled ? Theme.palette.directColor5 : Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: tertiaryText
                visible: tertiaryText.text
            }
            PropertyChanges {
                target: cardIcon
                opacity: disabled ?  0.4 : 1
            }
            PropertyChanges {
                target: errorIcon
                visible: false
            }
            PropertyChanges {
                target: advancedInput
                visible: advancedMode
            }
            PropertyChanges {
                target: advancedInput
                edit.color: disabled ? Theme.palette.directColor5 : Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: basicInput
                visible: !advancedMode
            }
        },
        State {
            name: "unpreferred"
            PropertyChanges {
                target: root
                color: disabled ? Theme.palette.baseColor4 : "transparent"
            }
            PropertyChanges {
                target: root
                border.color: disabled ? "transparent": Theme.palette.pinColor2
            }
            PropertyChanges {
                target: primaryText
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: primaryText
                visible: primaryText.text
            }
            PropertyChanges {
                target: secondaryLabel
                color: disabled ? Theme.palette.directColor5 : Theme.palette.pinColor1
            }
            PropertyChanges {
                target: secondaryLabel
                visible: !advancedMode && secondaryLabel.text
            }
            PropertyChanges {
                target: secondaryLabel
                text: disabled ? disabledText : secondaryText
            }
            PropertyChanges {
                target: tertiaryText
                color: disabled ? Theme.palette.directColor5 : Theme.palette.pinColor1
            }
            PropertyChanges {
                target: tertiaryText
                visible: tertiaryText.text
            }
            PropertyChanges {
                target: cardIcon
                opacity: disabled ? 0.4 : 1
            }
            PropertyChanges {
                target: errorIcon
                visible: !disabled && !advancedMode
            }
            PropertyChanges {
                target: advancedInput
                visible: advancedMode
            }
            PropertyChanges {
                target: advancedInput
                edit.color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: basicInput
                visible: !advancedMode
            }
        },
        State {
            name: "unavailable"
            PropertyChanges {
                target: root
                color: "transparent"
            }
            PropertyChanges {
                target: root
                border.color: "transparent"
            }
            PropertyChanges {
                target: primaryText
                color: Theme.palette.directColor5
            }
            PropertyChanges {
                target: primaryText
                visible: primaryText.text
            }
            PropertyChanges {
                target: secondaryLabel
                color: Theme.palette.directColor5
            }
            PropertyChanges {
                target: secondaryLabel
                visible: secondaryLabel.text
            }
            PropertyChanges {
                target: secondaryLabel
                text: secondaryText
            }
            PropertyChanges {
                target: tertiaryText
                color: Theme.palette.directColor5
            }
            PropertyChanges {
                target: tertiaryText
                visible: tertiaryText.text
            }
            PropertyChanges {
                target: cardIcon
                opacity: 0.4
            }
            PropertyChanges {
                target: errorIcon
                visible: false
            }
            PropertyChanges {
                target: advancedInput
                visible: false
            }
            PropertyChanges {
                target: advancedInput
                edit.color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: basicInput
                visible: true
            }
        }
    ]}
