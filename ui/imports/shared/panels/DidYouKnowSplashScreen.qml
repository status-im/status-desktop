import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import mainui 1.0
import shared.panels.private 1.0

Pane {
    id: root
    property alias progress: progressBar.value
    property alias splashScreenText: splashScreen.text

    contentItem: Item {
            SplashScreen {
                id: splashScreen
                objectName: "didYouKnowSplashScreen"
                anchors.centerIn: parent
                width: 128
                height: 128
            }
            ColumnLayout {
                id: content
                anchors.top: splashScreen.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                visible: root.progress !== 0
                Behavior on visible {
                    SequentialAnimation {
                        PropertyAction { target: content; property: "opacity"; value: visible ? 0 : didYouKnowText.opacity }                        //set opacity to 0 if the visible property changed to true
                        PropertyAction { }                                                                                                          //set visible property
                        NumberAnimation { target: content; property: "opacity"; duration: 1000; to: visible ? 1 : didYouKnowText.opacity }          //fade in
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
                StatusBaseText {
                    id: didYouKnow
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 12
                    color: Theme.palette.primaryColor1
                    font.weight: Font.DemiBold
                    font.pixelSize: Style.current.asideTextFontSize
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
                    font.pixelSize: Style.current.additionalTextSize
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

                StatusProgressBar {
                    id: progressBar
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 4
                    Layout.bottomMargin: 100
                    fillColor: Theme.palette.primaryColor1
                }
        }
    }
    background: Rectangle {
        color: Style.current.background
    }
}
