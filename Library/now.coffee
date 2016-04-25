module.exports = switch
  when window?.performance?.now instanceof Function
    -> performance.timing.navigationStart + performance.now()
  when global?.process?.hrtime instanceof Function
    programStartTime = Date.now() # there might be a more accurate source for this, open to suggestions...
    elapsedSinceProgramStart = ->
      time = global.process.hrtime()
      time[0] * 1e3 + time[1] / 1e6
    -> programStartTime + elapsedSinceProgramStart()
  else
    throw """
      Facts couldn’t locate a high-resolution time source in this environment.

      A high-resolution time source is required to ensure transactions don’t fall
      out of the pocket and ruin that fine-fine monotonic grooviness. Facts checked
      for window.performance.now and global.process.hrtime but neither of these
      functions was available.
    """
