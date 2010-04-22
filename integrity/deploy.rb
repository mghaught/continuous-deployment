module Integrity
  class Notifier
    class Deploy < Notifier::Base
      attr_reader :deploy
      
      def self.to_haml
        <<-haml
%p.normal
  %label{ :for => "deploy_notifier_deploy" } Deploy Script
  %input.text#deploy_notifier_deploy{ :name => "notifiers[Deploy][deploy]", :type => "text", :value => config["deploy"] }
        haml
      end

      def initialize(build, config={})
        @deploy = config.delete("deploy")
        log("Initializing... deploy command is '#{deploy}'")
        super
      end

      def deliver!
        if build.successful?
          run_deploy
        else
          skip_deploy
        end
      end

      def run_deploy
        log('Build successful, deploy triggered.')
        cmd = "(cd #{repo.directory} && #{deploy} 2>&1)"
        log(cmd)
        output = IO.popen(cmd, "r") { |io| io.read }
        status = $?.success?
        log("Deploy #{build.commit.identifier} exited with #{status} got:\n#{output}")
      end

      def skip_deploy
        log('Build failed, no deploy triggered.')
      end

      def log(msg)
        Integrity.log('Deploy') {msg}
      end

      # this should exist in build.rb, but doesn't
      def repo
        @repo ||= Repository.new(
                                 build.id,
                                 build.project.uri,
                                 build.project.branch,
                                 build.commit.identifier
                                 )
      end
    end

    register Deploy
  end
end
