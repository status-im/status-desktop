import NimQml, Tables, chronicles, sequtils, json, sugar, stint
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/community_tokens as tokens_backend
import ../network/service as network_service
import ../transaction/service as transaction_service

import ../eth/dto/transaction

import ../../../backend/response_type

import ../../common/json_utils
import ../../common/conversion

import ./dto/deployment_parameters

#include async_tasks

logScope:
  topics = "community-tokens-service"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      networkService: network_service.Service
      transactionService: transaction_service.Service

  proc delete*(self: Service) =
      self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
    transactionService: transaction_service.Service
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.transactionService = transactionService

  proc init*(self: Service) =
    self.events.on(PendingTransactionTypeDto.CollectibleDeployment.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      # TODO signalize module about about contract state
      if receivedData.success:
        echo "!!! Collectible deployed"
      else:
        echo "!!! Collectible not deployed"

  proc mintCollectibles*(self: Service, addressFrom: string, password: string, deploymentParams: DeploymentParameters) =
    try:
      let chainId = self.networkService.getNetworkForCollectibles().chainId
      let txData = TransactionDataDto(source: parseAddress(addressFrom))
      let response = tokens_backend.deployCollectibles(chainId, %deploymentParams, %txData, password)
      if (not response.error.isNil):
        error "Error minting collectibles", message = response.error.message
        return
      let contractAddress = response.result["contractAddress"].getStr()
      let transactionHash = response.result["transactionHash"].getStr()
      echo "!!! Contract address ", contractAddress
      echo "!!! Transaction hash ", transactionHash
      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contractAddress,
        $PendingTransactionTypeDto.CollectibleDeployment,
        "",
        chainId,
      )
    except RpcException:
      error "Error minting collectibles", message = getCurrentExceptionMsg()
