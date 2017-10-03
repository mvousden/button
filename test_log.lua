#!~/.luarocks/bin/busted

function test_logger()

   -- Suppress standard output.
   stub(log._logger, "print_directly_to_stdout")

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

function require_logger()
   log = require("button/logger")
end

function clear_log()
   os.remove(log.logPath)
   log.getLogger()
end

function destroy_logger()
   log._logger = nil
end

describe("Logger tests",
         function()
            local log
            setup(require_logger)
            before_each(clear_log)
            after_each(destroy_logger)
            it("Logger tests (it)", test_logger)
         end)
