module MultiDaemons
  # To control daemons
  class Controller
    attr_accessor :daemons, :options

    def initialize(daemons, options = {})
      @daemons = daemons
      @options = options
    end

    def start
      daemons.each(&:start)
    end

    def stop
      pids = []
      pid_files = []
      daemons.each do |daemon|
        daemon.multiple = true
        daemon.stop
        pids << daemon.pids
        pid_files << daemon.pid_file
      end
      Pid.force_kill(pids.flatten, force_kill_timeout)
      PidStore.cleanup(pid_files)
    end

    private

    def force_kill_timeout
      options[:force_kill_timeout] || 30
    end
  end
end
