import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"

Item {
    id: searchENS
    property string validationMessage: ""
    property bool valid: false
    property bool isStatus: true

    property var validateENS: Backpressure.debounce(searchENS, 500, function (ensName, isStatus){
        profileModel.ens.validate(ensName, isStatus)
    });

    function validate() {
        validationMessage = "";
        valid = false;
        if (ensUsername.text.length < 4) {
            validationMessage = qsTr("At least 4 characters. Latin letters, numbers, and lowercase only.");
        } else if(isStatus && !ensUsername.text.match(/^[a-z0-9]+$/)){
            validationMessage = qsTr("Letters and numbers only.");
        } else if(!isStatus && !ensUsername.text.endsWith(".eth")){
            validationMessage = qsTr("Type the entire username including the custom domain like username.domain.eth")
        }
        return validationMessage === "";
    }

    function onKeyReleased(){
        if (!validate()) {
            return;
        }
        Qt.callLater(validateENS, ensUsername.text, isStatus)
    }

    StyledText {
        id: sectionTitle
        text: qsTr("Your username")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    Rectangle {
        id: circleAt
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        width: 60
        height: 60
        radius: 120
        color: Style.current.blue

        StyledText {
            text: "@"
            opacity: 0.7
            font.weight: Font.Bold
            font.pixelSize: 18
            color: Style.current.white
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Input {
        id: ensUsername
        placeholderText: !isStatus ? "vitalik94.domain.eth" : "vitalik94"
        anchors.top: circleAt.bottom
        anchors.topMargin: 24
        anchors.right: btnContinue.left
        anchors.rightMargin: 24
        Keys.onReleased: {
            onKeyReleased();
        }

        Connections {
            target: profileModel.ens
            onEnsWasResolved: {
                valid = false
                switch(ensResult){
                    case "available": 
                        valid = true;
                        validationMessage = qsTr("✓ Username available!");
                        break;
                    case "owned":
                        console.log("TODO: -");
                    case "taken":
                        validationMessage = !isStatus ? 
                                            qsTr("Username doesn’t belong to you :(")
                                            :
                                            qsTr("Username already taken :(");
                        break;
                    case "connected":
                        validationMessage = qsTr("This user name is owned by you and connected with your chat key.");
                        break;
                    case "connected-different-key":
                        validationMessage = qsTr("Username doesn’t belong to you :(");
                }
            }
        }
    }

    Button {
        id: btnContinue
        width: 44
        height: 44
        anchors.top: circleAt.bottom
        anchors.topMargin: 24
        anchors.right: parent.right
        SVGImage {
            source: !valid ? "../../../../img/arrow-button-inactive.svg" : "../../../../img/arrow-btn-active.svg"
            width: 50
            height: 50
        }
        background: Rectangle {
            color: "transparent"
        }
        MouseArea {
            id: btnMAnewChat
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked : {
                if(!valid) return;
                console.log("TODO: show ens T&C")
            }
        }
    }


    Rectangle {
        id: ensTypeRect
        anchors.top: ensUsername.bottom
        anchors.topMargin: 24
        border.width: 1
        border.color: Style.current.border
        radius: 50
        height: 20
        width: 350

        StyledText {
            text: !isStatus ? 
                qsTr("Custom domain")
                :
                ".stateofus.eth"
            font.weight: Font.Bold
            font.pixelSize: 12
            anchors.leftMargin: Style.current.padding
        }

        StyledText {
            text: !isStatus ? 
                qsTr("I want a stateofus.eth domain")
                :
                qsTr("I own a name on another domain")
            font.pixelSize: 12
            color: Style.current.blue
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    isStatus = !isStatus;
                    if(validate())
                        validateENS(ensUsername.text, isStatus)
                }
            }
        }
    }

    StyledText {
        id: validationResult
        text: validationMessage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: ensTypeRect.bottom
        anchors.topMargin: 24
    }
}