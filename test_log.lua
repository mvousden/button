#!/usr/bin/lua5.3
log = require("button/logger")
log.getLogger():debug("A debug message")
log.getLogger():info("An info message")
log.getLogger():warning("A warning message")
