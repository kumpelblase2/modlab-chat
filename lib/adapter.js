// Generated by CoffeeScript 1.8.0
(function() {
  var Adapter, EventEmitter,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  EventEmitter = require('events').EventEmitter;

  Adapter = (function(_super) {
    __extends(Adapter, _super);

    function Adapter(chat) {
      this.chat = chat;
    }

    Adapter.prototype.send = function() {
      var envelope, strings;
      envelope = arguments[0], strings = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    };

    Adapter.prototype.emote = function() {
      var envelope, strings;
      envelope = arguments[0], strings = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.send.apply(this, [envelope].concat(__slice.call(strings)));
    };

    Adapter.prototype.reply = function() {
      var envelope, strings;
      envelope = arguments[0], strings = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    };

    Adapter.prototype.run = function() {};

    Adapter.prototype.close = function() {};

    Adapter.prototype.receive = function(message) {
      return this.chat.receive(message);
    };

    return Adapter;

  })(EventEmitter);

  module.exports = Adapter;

}).call(this);