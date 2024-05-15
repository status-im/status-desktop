import QtQuick 2.13
import QtMultimedia 5.15

/*!
    \qmltype StatusVideo
    \inherits Item
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Displays a video. Bundles \l{https://doc.qt.io/qt-5/qml-qtmultimedia-mediaplayer.html}{MediaPlayer} and 
    \l{https://doc.qt.io/qt-5/qml-qtmultimedia-video.html}{Video}.

    This is a plain wrapper for the MediaPlayer and Video QML types, providing an interface similar to the Image QML type. It 
    sets some default property values and adds some properties common to other media type wrappers.

    Example of how to use it:

    \qml
        StatusVideo {
            anchors.fill: parent

            width: 100
            height: 100
            player.source: "qrc:/demoapp/data/test-video.avi"
        }
    \endqml

*/
Item {
    id: root

    readonly property bool isLoading: player.playbackState !== MediaPlayer.PlayingState
    readonly property bool isError: player.status === MediaPlayer.InvalidMedia

    property alias source: player.source
    property alias player: player
    property alias output: output
    property alias fillMode: output.fillMode

    MediaPlayer {
        id: player
        autoPlay: true
        muted: true
        loops: MediaPlayer.Infinite
    }

    VideoOutput {
        id: output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        source: player
    }
}
