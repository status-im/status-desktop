import NimQml, json, chronicles

import ../../../backend/general as status_general
import ../../../app/core/eventemitter
import ../../../app/core/tasks/threadpool

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
      if not response.result.contains("error"):
        return response.result.toUrlDataDto()
      let errMsg = response.result["error"].getStr()
      error "failed to parse shared url: ", url, errDesription = errMsg
    except Exception as e:
      error "failed to parse shared url: ", url, errDesription = e.msg
