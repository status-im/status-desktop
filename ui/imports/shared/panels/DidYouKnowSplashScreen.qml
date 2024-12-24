import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import mainui 1.0
import shared.panels.private 1.0

Pane {
    id: root

    property alias progress: splashScreen.progress
    property alias splashScreenText: splashScreen.text
    property alias splashScreenSecondaryText: splashScreen.secondaryText
    property bool messagesEnabled

    contentItem: Item {
        SplashScreen {
            id: splashScreen
            objectName: "didYouKnowSplashScreen"
            anchors.centerIn: parent
        }
        ColumnLayout {
            id: content
            anchors.bottom: parent.bottom
            width: parent.width
            visible: root.progress !== 0 && root.messagesEnabled
            Behavior on visible {
                SequentialAnimation {
                    PropertyAction { target: content; property: "opacity"; value: visible ? 0 : didYouKnowText.opacity }                        //set opacity to 0 if the visible property changed to true
                    PropertyAction { }                                                                                                          //set visible property
                    NumberAnimation { target: content; property: "opacity"; duration: 1000; to: visible ? 1 : didYouKnowText.opacity }          //fade in
                }
            }
            StatusBaseText {
                id: didYouKnow
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 12
                color: Theme.palette.primaryColor1
                font.weight: Font.DemiBold
                font.pixelSize: Theme.asideTextFontSize
                text: qsTr("DID YOU KNOW?")

            }
            StatusBaseText {
                id: didYouKnowText
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 60
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
                font.pixelSize: Theme.additionalTextSize
                text: didYouKnowMessages.iterator.next()
                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation { target: didYouKnowText; properties: "opacity"; duration: 150; to: 0 } //fade out
                        PropertyAction { }                                                                      //change text
                        NumberAnimation { target: didYouKnowText; properties: "opacity"; duration: 150; to: 1; }//fade in
                    }
                }
                DidYouKnowMessages {
                    id: didYouKnowMessages
                }
                Timer {
                    id: didYouKnowTimer
                    interval: 7000
                    repeat: true
                    running: didYouKnowText.visible
                    onTriggered: didYouKnowText.text = didYouKnowMessages.iterator.next()
                }
            }
        }
    }
    background: Rectangle {
        color: Theme.palette.background
    }
}
