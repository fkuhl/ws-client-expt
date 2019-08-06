//
//  File.swift
//  
//
//  Created by Frederick Kuhl on 7/17/19.
//

import Foundation
import HTTP
import WebSocket

enum MemberStatus: Decodable {
    case NONCOMMUNING
    case COMMUNING
}

struct Member: Decodable {
    let givenName: String
    let familyName: String
    let memberStatus: MemberStatus
}

enum DataClass: Decodable {
    case Member
    case Household
}

enum MemberOp: Decodable {
    case create
    case read
    case update
    case delete
}

struct MessageResponse: Decodable {
    let clientMessageID: Int
    let dataClass: DataClass
    let op: MemberOp
    let response: String
}

NSLog("and we came up!")
// Create a new WebSocket connected to echo.websocket.org
let ws = try HTTPClient.webSocket(
    hostname: "localhost",
    port: 4000,
    on: MultiThreadedEventLoopGroup(numberOfThreads: 2)).wait()
NSLog("socket opened")

// Set a new callback for receiving text formatted data.
ws.onText { ws, text in
    NSLog("Server response: \(text)")
    do {
        let serverResponse = try JSONDecoder().decode(MessageResponse.self, from: text)
        switch(serverResponse.clientMessageID) {
        case 1:
            console.log("msg 1: \(serverResponse.response)")
            ws.send(goodCommandBadData)
        case 2:
            console.log("msg 2: \(serverResponse.response)")
            ws.send(goodCommandGoodData)
        case 3:
            console.log("msg 3:\(serverResponse.response)")
        }
    } catch {
        console.log("decode failed: \(error.localizedDescription)")
    }
}

let badCommandGoodData =
"""
{"messageID":"1", dataClass":"ThisIsUndefined", "op":"create", "operand":{ "givenName": "Horatio", "familyName": "Hornswoggle", "memberStatus": "NONCOMMUNING" }}
"""
ws.send(badCommandGoodData)

let goodCommandBadData =
"""
{"messageID":"2", "dataClass":"Member", "op":"create", "operand":{ "flunk": "Horatio", "familyName": "Hornswoggle", "memberStatus": "NONCOMMUNING" }}
"""

//ws.send(goodCommandBadData)

let goodCommandGoodData =
"""
{"messageID":"3", "dataClass":"Member", "op":"create", "operand":{ "givenName": "Horatio", "familyName": "Hornswoggle", "memberStatus": "NONCOMMUNING" }}
"""
// Send a message.
//ws.send(goodCommandGoodData)


// Wait for the Websocket to close.
try ws.onClose.wait()
NSLog("socket closed")
