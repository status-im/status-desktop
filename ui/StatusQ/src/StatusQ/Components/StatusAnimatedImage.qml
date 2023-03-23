import QtQuick 2.13

AnimatedImage {
    id: root

    readonly property bool isLoading: status === AnimatedImage.Loading
    readonly property bool isError: status === AnimatedImage.Error

    fillMode: AnimatedImage.PreserveAspectFit
}
