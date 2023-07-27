import NimQml, os, json, chronicles

import ../../../backend/general as status_general
import ../../../constants as app_constants
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ./dto/url_data as url_data_dto

export url_data_dto

logScope:
  topics = "shared-urls-app-service"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
  
  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    result = Service()
    result.QObject.setup
    result.events = events

  proc parseSharedUrl*(self: Service, url: string): UrlDataDto =
    try:
      let response = status_general.parseSharedUrl(url)
      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr()
        error "error while pasring shared url: ", errDesription = errMsg
        return
      return response.result.toUrlDataDto()
    except Exception as e:
      error "error while parsing shared url: ", msg = e.msg