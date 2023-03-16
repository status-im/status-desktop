import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import QtGraphicalEffects 1.13
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

/*!
    \qmltype StatusToastMessage
    \inherits Control
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Displays a toast message in the UI. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-control.html}{Control}.

    The \c StatusToastMessage displays a toast message in the UI either standalone or as part
    of a stack of toast messages.
    For example:

    \qml
    StatusToastMessage {
        primaryText: qsTr("Collectible is being minted...")
        secondaryText: qsTr("View on Etherscan")
        loading: true
        type: 0
        linkUrl: "http://google.com"
        duration: 5000
    }
    \endqml

    \image status_toast_message.png

    For a list of components available see StatusQ.
 */


Control {
    id: root
    width: 343
    height: !!secondaryText ? 68 : 48
    anchors.right: parent.right

    /*!
        \qmlproperty bool StatusToastMessage::open
        This property represents all steps and their descriptions as provided by the user.
    */
    property bool open: true
    /*!
        \qmlproperty string StatusToastMessage::primaryText
        This property represents the title text of the ToastMessage.
    */
    property string primaryText: ""
    /*!
        \qmlproperty string StatusToastMessage::secondaryText
        This property represents the subtitle text of the ToastMessage.
    */
    property string secondaryText: ""
    /*!
        \qmlproperty bool StatusToastMessage::loading
        This property represents activates/deactivates the loading indicator of the ToastMessage.
    */
    property bool loading: false
    /*!
        \qmlproperty string StatusToastMessage::linkUrl
        This property represents all steps and their descriptions as provided by the user.
    */
    property string linkUrl: ""

    /*!
        \qmlproperty int StatusToastMessage::duration
        This property represents duration in milliseconds, for how long a toast will be visible. If 0 is set for
        duration, that means a toast won't dissapear without user's interaction (click on close).
    */
    property int duration: 0

    /*!
        \qmlproperty StatusAssetSettings StatusToastMessage::icon
        This property holds a set of settings for the icon of the ToastMessage.
    */
    property StatusAssetSettings icon: StatusAssetSettings {
        width: 23
        height: 23
    }

    /*!
        \qmlproperty int StatusToastMessage::type
        This property holds the type of the ToastMessage. Values are:
        \list
            \li Default
            \li Success
        \endlist

    */
    property int type: StatusToastMessage.Type.Default
    enum Type {
        Default,
        Success
    }

    /*!
        \qmlmethod
        This function is used to open the ToastMessage setting all its properties.
        Examples of usage:
        \qml
        StatusToastMessage {
            id: toastMessage
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                toastMessage.open(qsTr("Verification Request Sent"), "", "checkmark-circle", 1, false,"");
            }
        }
    \endqml

    */
    function open(title, subTitle, iconName, type, loading, url) {
        root.primaryText = title;
        root.secondaryText = subTitle;
        root.icon.name = iconName;
        root.type = type;
        root.loading = loading;
        root.linkUrl = url;
        root.open = true;
    }

    /*!
        \qmlsignal
        This signal is emitted when the ToastMessage is clicked.
    */
    signal clicked()
    /*!
        \qmlsignal
        This signal is emitted when the ToastMessage is closed (after animation).
    */
    signal close()
    /*!
        \qmlsignal
        This signal is emitted when the ToastMessage contains a url and this url
        is clicked by the user.
    */
    signal linkActivated(var link)

    QtObject {
        id: d

        readonly property string openedState: "opened"
        readonly property string closedState: "closed"
    }

    Timer {
        interval: root.duration
        running: root.duration > 0
        onTriggered: {
            root.open = false;
        }
    }

    states: [
        State {
            name: d.openedState
            when: root.open
            PropertyChanges {
                target: root
                anchors.rightMargin: 0
                opacity: 1.0
            }
        },
        State {
            name: d.closedState
            when: !root.open
            PropertyChanges {
                target: root
                anchors.rightMargin: -width
                opacity: 0.0
            }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { properties: "anchors.rightMargin,opacity"; duration: 400 }

            onRunningChanged: {
                if(!running && state == d.closedState) {
                    root.close();
                }
            }
        }
    ]

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.palette.statusToastMessage.backgroundColor
        radius: 8
        border.color: Theme.palette.baseColor2
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dropShadow
        }
    }

    contentItem: Item {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 4
        height: parent.height
        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                root.open = (mouseX < (root.width/3));
            }
            onClicked: {
                root.clicked();
            }
        }
        RowLayout {
            anchors.fill: parent
            spacing: 16
            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                Layout.alignment: Qt.AlignVCenter
                radius: (root.width/2)
                color: (root.type === StatusToastMessage.Type.Success) ?
                        Theme.palette.successColor2 : Theme.palette.primaryColor3
                visible: loader.sourceComponent != undefined
                Loader {
                    id: loader
                    anchors.centerIn: parent
                    sourceComponent: root.loading ? loadingInd :
                                                    root.icon.name != ""? statusIcon :
                                                                          undefined

                    Component {
                        id: loadingInd
                        StatusLoadingIndicator {
                            color: (root.type === StatusToastMessage.Type.Success) ?
                                   Theme.palette.successColor1 : Theme.palette.primaryColor1
                        }
                    }
                    Component {
                        id: statusIcon
                        StatusIcon {
                            anchors.centerIn: parent
                            width: root.icon.width
                            height: root.icon.height
                            color: (root.type === StatusToastMessage.Type.Success) ?
                                   Theme.palette.successColor1 : Theme.palette.primaryColor1
                            icon: root.icon.name
                        }
                    }
                }
            }
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                StatusBaseText {
                    width: parent.width
                    font.pixelSize: 13
                    color: Theme.palette.directColor1
                    elide: Text.ElideRight
                    text: root.primaryText
                }
                StatusBaseText {
                    width: parent.width
                    visible: (!root.linkUrl && !!root.secondaryText)
                    height: visible ? contentHeight : 0
                    font.pixelSize: 13
                    color: Theme.palette.baseColor1
                    text: root.secondaryText
                    elide: Text.ElideRight
                }
                StatusSelectableText {
                    visible: (!!root.linkUrl)
                    height: visible ? implicitHeight : 0
                    font.pixelSize: 13
                    hoveredLinkColor: Theme.palette.primaryColor1
                    text: "<p><a style=\"text-decoration:none\" href=\'" + root.linkUrl + " \'>" + root.secondaryText + "</a></p>"
                    onLinkActivated: {
                        root.linkActivated(root.linkUrl);
                    }
                }
            }
            StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "close"
                icon.color: Theme.palette.directColor1
                implicitWidth: 30
                implicitHeight: 30
                onClicked: {
                    root.open = false;
                }
            }
        }
    }
}
