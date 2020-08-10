import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../../../../shared"

Item {
    id: searchENS

    property var onClick: function(){}

    property string validationMessage: ""
    property bool valid: false
    property bool isStatus: true
    property bool loading: false
    property string ensStatus: ""

    property var validateENS: Backpressure.debounce(searchENS, 500, function (ensName, isStatus){
        profileModel.ens.validate(ensName, isStatus)
    });

    function validate(ensUsername) {
        validationMessage = "";
        valid = false;
        ensStatus = "";
        if (ensUsername.length < 4) {
            validationMessage = qsTr("At least 4 characters. Latin letters, numbers, and lowercase only.");
        } else if(isStatus && !ensUsername.match(/^[a-z0-9]+$/)){
            validationMessage = qsTr("Letters and numbers only.");
        } else if(!isStatus && !ensUsername.endsWith(".eth")){
            validationMessage = qsTr("Type the entire username including the custom domain like username.domain.eth")
        }
        return validationMessage === "";
    }

    function onKeyReleased(ensUsername){
        if (!validate(ensUsername)) {
            return;
        }
        loading = true;
        Qt.callLater(validateENS, ensUsername, isStatus)
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

        SVGImage {
            id: imgIcon
            visible: ensStatus === "taken"
            fillMode: Image.PreserveAspectFit
            source: "../../../../img/block-icon-white.svg"
            width: 20
            height: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            visible: ensStatus !== "taken"
            text: {
                if((ensStatus === "available" || ensStatus === "connected" || ensStatus === "connected-different-key")){
                    return "✓"
                } else {
                    return "@"
                }
            }
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
            onKeyReleased(ensUsername.text);
        }

        Connections {
            target: profileModel.ens
            onEnsWasResolved: {
                if(!validate(ensUsername.text)) return;
                valid = false;
                loading = false;
                ensStatus = ensResult;
                switch(ensResult){
                    case "available": 
                        valid = true;
                        validationMessage = qsTr("✓ Username available!");
                        break;
                    case "owned":
                        console.log("TODO: - Continuing will connect this username with your chat key.");
                    case "taken":
                        validationMessage = !isStatus ? 
                                            qsTr("Username doesn’t belong to you :(")
                                            :
                                            qsTr("Username already taken :(");
                        break;
                    case "already-connected":
                        validationMessage = qsTr("Username is already connected with your chat key and can be used inside Status.");
                        break;
                    case "connected":
                        valid = true;
                        validationMessage = qsTr("This user name is owned by you and connected with your chat key. Continue to set `Show my ENS username in chats`.");
                        break;
                    case "connected-different-key":
                        valid = true;
                        validationMessage = qsTr("Continuing will require a transaction to connect the username with your current chat key.");
                        break;
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

                if(ensStatus === "connected"){
                    profileModel.ens.connect(ensUsername.text, isStatus);
                    onClick(ensStatus, ensUsername.text);
                    return;
                }

                if(ensStatus === "available"){
                    onClick(ensStatus, ensUsername.text);
                    return;
                }
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
                    let ensUser = ensUsername.text;
                    if(validate(ensUser))
                        validateENS(ensUser, isStatus)
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