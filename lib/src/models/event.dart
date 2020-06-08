import 'dart:convert';

import 'package:cotter/src/api.dart';
import 'package:flutter/material.dart';

class Event {
  int id;
  String userID;
  String clientUserID;
  String issuer;
  String event;
  String ip;
  String location;
  String timestamp;
  String method;
  bool newEvent;
  bool approved;
  String signature;

  Event({
    this.id,
    this.userID,
    this.clientUserID,
    this.issuer,
    this.event,
    this.ip,
    this.location,
    this.timestamp,
    this.method,
    this.newEvent,
    this.approved,
    this.signature,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json["ID"],
      userID: json["user_id"],
      clientUserID: json["client_user_id"],
      issuer: json["issuer"],
      event: json["event"],
      ip: json["ip"],
      location: json["location"],
      timestamp: json["timestamp"],
      method: json["method"],
      newEvent: json["new"],
      approved: json["approved"],
      signature: json["signature"],
    );
  }

  Map<String, dynamic> toJson() => {
        "ID": this.id,
        "user_id": this.userID,
        "client_user_id": this.clientUserID,
        "issuer": this.issuer,
        "event": this.event,
        "ip": this.ip,
        "location": this.location,
        "timestamp": this.timestamp,
        "method": this.method,
        "new": this.newEvent,
        "approved": this.approved,
        "signature": this.signature,
      };

  String toString() => jsonEncode(this.toJson());

  static Event createWithCotterUserID({
    @required String apiKeyID,
    @required String cotterUserID,
    @required String event,
    @required String timestamp,
    @required String method,
  }) {
    Event e = new Event(
        userID: cotterUserID,
        issuer: apiKeyID,
        event: event,
        timestamp: timestamp,
        method: method);
    return e;
  }

  static Event createWithClientUserID({
    @required String apiKeyID,
    @required String clientUserID,
    @required String event,
    @required String timestamp,
    @required String method,
  }) {
    Event e = new Event(
        clientUserID: clientUserID,
        issuer: apiKeyID,
        event: event,
        timestamp: timestamp,
        method: method);
    return e;
  }

  String constructApprovedEventMsg() {
    String id;
    if (this.userID != null && this.userID.length > 5) {
      id = this.userID;
    } else if (this.clientUserID != null && this.clientUserID.length > 5) {
      id = this.clientUserID;
    } else {
      throw "User ID and Client User ID cannot both be empty, please specify one or the other";
    }
    var list = [
      id,
      this.issuer,
      this.event,
      this.timestamp,
      this.method,
      'true'
    ];
    return list.join('');
  }

  String constructRespondEventMsg() {
    String id;
    if (this.userID != null && this.userID.length > 5) {
      id = this.userID;
    } else if (this.clientUserID != null && this.clientUserID.length > 5) {
      id = this.clientUserID;
    } else {
      throw "User ID and Client User ID cannot both be empty, please specify one or the other";
    }
    var list = [
      id,
      this.issuer,
      this.event,
      this.timestamp,
      this.method,
      this.approved.toString(),
    ];
    return list.join('');
  }

  Future<Map<String, dynamic>> constructApprovedEventJSON({
    @required String codeOrSignature,
    @required String publicKey,
    String algorithm,
  }) async {
    API api = new API(apiKeyID: this.issuer);
    IPLocation ipLoc = await api.getIPAddress();
    Map<String, dynamic> req = {
      "issuer": this.issuer,
      "event": this.event,
      "ip": ipLoc.ip,
      "location": ipLoc.location,
      "timestamp": this.timestamp,
      "method": this.method,
      "code": codeOrSignature,
      "approved": true,
      "public_key": publicKey,
    };

    if (this.userID != null && this.userID.length > 5) {
      req["user_id"] = this.userID;
    } else if (this.clientUserID != null && this.clientUserID.length > 5) {
      req["client_user_id"] = this.clientUserID;
    } else {
      throw "User ID and Client User ID cannot both be empty, please specify one or the other";
    }

    if (algorithm != null) {
      req['algorithm'] = algorithm;
    }
    return req;
  }

  Future<Map<String, dynamic>> constructPendingEventJSON() async {
    API api = new API(apiKeyID: this.issuer);
    IPLocation ipLoc = await api.getIPAddress();
    Map<String, dynamic> req = {
      "issuer": this.issuer,
      "event": this.event,
      "ip": ipLoc.ip,
      "location": ipLoc.location,
      "timestamp": this.timestamp,
      "method": this.method,
    };

    if (this.userID != null && this.userID.length > 5) {
      req["user_id"] = this.userID;
    } else if (this.clientUserID != null && this.clientUserID.length > 5) {
      req["client_user_id"] = this.clientUserID;
    } else {
      throw "User ID and Client User ID cannot both be empty, please specify one or the other";
    }

    return req;
  }

  Future<Map<String, dynamic>> constructRespondEventJSON({
    @required String method,
    @required String codeOrSignature,
    @required String publicKey,
    String algorithm,
  }) async {
    Map<String, dynamic> req = {
      "issuer": this.issuer,
      "event": this.event,
      "ip": this.ip,
      "location": this.location,
      "timestamp": this.timestamp,
      "method": method,
      "code": codeOrSignature,
      "approved": this.approved,
      "public_key": publicKey,
      "algorithm": algorithm,
    };

    if (this.userID != null && this.userID.length > 5) {
      req["user_id"] = this.userID;
    } else if (this.clientUserID != null && this.clientUserID.length > 5) {
      req["client_user_id"] = this.clientUserID;
    } else {
      throw "User ID and Client User ID cannot both be empty, please specify one or the other";
    }

    return req;
  }
}
