import QtQuick 2.15

QtObject {
    required property string content
    required property int startIndex
    // Non-inclusive
    required property int endIndex
    required property int contentType

    property bool isFrozen: false

    enum ContentType {
        Number,
        Separator,
        Base
    }

    function length() {
        return endIndex - startIndex
    }
    function isHardened() {
        return contentType === Element.ContentType.Separator && (content[0] === "'" || content[0] === "’")
    }
    /// Returns NaN if not a number
    function number() {
        return (contentType === Element.ContentType.Number && /^\d+$/.test(content)) ? parseInt(content, 10) : NaN
    }

    function isNumber() {
        return contentType === Element.ContentType.Number
    }

    function validateNumber() {
        return contentType !== Element.ContentType.Number || !isNaN(number())
    }

    function isSeparator() {
        return contentType === Element.ContentType.Separator
    }

    function isEmptyNumber() {
        return contentType === Element.ContentType.Number && content.length === 0
    }

    function isBase() {
        return contentType === Element.ContentType.Base
    }

    /// Compares for incomplete typed separators
    function isSimilar(other) {
        return contentType === other.contentType
            && (contentType === Element.ContentType.Number
                ? (number() === other.number()) || (isEmptyNumber() && other.isEmptyNumber())
                : (isHardened() === other.isHardened()))
    }

    /// Compares
    function isSame(other) {
        return contentType === other.contentType && content === other.content && startIndex == other.startIndex && endIndex == other.endIndex
    }

}