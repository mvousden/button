#!~/.luarocks/bin/busted

function test_logger()

   -- Import the logger.
   log = require("button/logger")

   -- Remove the logfile if it exists.
   os.remove(log.logPath)

   -- Write a series of messages.
   log.getLogger():debug("A debug message")
   log.getLogger():info("An info message")
   log.getLogger():warning("A warning message")
   log.getLogger():error("An error message")

   -- Check that the logfile has been written to.
   logFile = io.open(log.logPath, "r")
   content = logFile:read()
   logFile:close()
   print(content)
   assert.is(content)

end

describe("Logger tests", function() it("Logger tests (it)", test_logger) end)
