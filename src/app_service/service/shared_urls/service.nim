import NimQml, json, chronicles, strutils

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
      if response.result.contains("error"):
        let errMsg = response.result["error"].getStr()
        raise newException(Exception, errMsg)
      # not a status shared url
      return response.result.toUrlDataDto()
    except Exception as e:
      if not e.msg.contains("not a status shared url"):
        error "failed to parse shared url: ", url, errDesription = e.msg
      result.notASupportedStatusLink = true
