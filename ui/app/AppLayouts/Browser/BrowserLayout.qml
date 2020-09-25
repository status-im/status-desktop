import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import QtWebChannel 1.13
import "../../../shared"
import "../../../imports"

Item {
    id: browserView
    Layout.fillHeight: true
    Layout.fillWidth: true

    property var request: {"hostname": "", "permission": ""}

    // TODO: example qml webbrowser available here:
    // https://doc.qt.io/qt-5/qtwebengine-webengine-quicknanobrowser-example.html

    WebEngineProfile {
        id: webProfile
        offTheRecord: true // Private Mode on
        persistentCookiesPolicy:  WebEngineProfile.NoPersistentCookies
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            }
        ]
    }

    function postMessage(isAllowed){
        request.isAllowed = isAllowed;
        provider.web3Response(web3Provider.postMessage(JSON.stringify(request)));
    }

    ModalPopup {
        id: accessDialog

        // TODO: design required

        StyledText {
            id: siteName
            text: request.hostname
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: permission
            text: qsTr("Permission requested: %1").arg(request.permission)
            anchors.top: siteName.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: description
            anchors.top: permission.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
            text: {
                switch(request.permission){
                    case "web3": return qsTr("Allowing authorizes this DApp to retrieve your wallet address and enable Web3");
                    case "contact-code": return qsTr("Granting access authorizes this DApp to retrieve your chat key");
                    default: return qsTr("Unknown permission");
                }
            }
        }

        StyledButton {	
            anchors.bottom: parent.bottom	
            anchors.bottomMargin: Style.current.padding	
            anchors.left: parent.left	
            anchors.leftMargin: Style.current.padding	
            label: qsTr("Allow")	
            onClicked: {
                postMessage(true);
                accessDialog.close();	
            }
        }

        StyledButton {	
            anchors.bottom: parent.bottom	
            anchors.bottomMargin: Style.current.padding	
            anchors.right: parent.right	
            anchors.rightMargin: Style.current.padding	
            label: qsTr("Deny")	
            onClicked: {
                postMessage(false);
                accessDialog.close();	
            }	
        }
    }


    QtObject {
        id: provider
        WebChannel.id: "backend"

        signal web3Response(string data);

        function postMessage(data){
            request = JSON.parse(data)
            if(request.type === "api-request"){
                // TODO: check if permission has been granted before, 
                // to not show the dialog
                accessDialog.open()
            } else {
                web3Response(web3Provider.postMessage(data));
            }
        }

        property int networkId: web3Provider.networkId
    }

    WebChannel {
        id: channel
        registeredObjects: [provider]
    }

    WebEngineView {
        id: browserContainer
        anchors.fill: parent
        profile: webProfile
        url: "https://app.uniswap.org/#/"
        webChannel: channel
        onNewViewRequested: function(request) {
            // TODO: rramos: tabs can be handled here. see: https://doc.qt.io/qt-5/qml-qtwebengine-webengineview.html#newViewRequested-signal
            // In the meantime, I'm opening the content in the same webengineview
            request.openIn(browserContainer)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
