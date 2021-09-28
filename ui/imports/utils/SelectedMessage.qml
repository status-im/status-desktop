pragma Singleton

import QtQuick 2.13

QtObject {
  property string messageId: ""
  property string author: ""

  function reset(){
    messageId = "";
    author = "";
  }

  function set(_messageId, _author){
    messageId = _messageId;
    author = _author;
  }
}