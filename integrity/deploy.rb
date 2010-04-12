module Integrity
  class Notifier
    class Deploy < Notifier::Base
      attr_reader :deploy
      
#       http://matedriven.com.ar/2009/09/21/continuous-notification-with-integrity.html
      def self.to_haml
        <<-haml
%p.normal
  %label{ :for => "deploy_notifier_deploy" } Continuous Deployment Command
  %input.text#deploy_notifier_deploy{ :name => "notifiers[Deploy][deploy]", :type => "text", :value => config["deploy"] }
        haml
      end

      def to_s
        "Deploy"
      end

      def initialize(build, config={})
        @deploy = config.delete("deploy")
        Integrity.log("Initiatizing Deploy notifier for build: #{build.commit.identifier}, current status is #{build.status}, command is #{@deploy}")
        super
      end

      def deliver!
        Integrity.log("\n\n#{full_message}\n\n")
        message = "Build status: #{build.status} at #{Time.now}"
        Integrity.log("Deploy notifier - DELIVER message: #{message}")
        system("echo '#{message}' >> /tmp/worked")
        Integrity.log("Build FAILED") if build.failed?
        Integrity.log("Build SUCCESS") if build.successful?
      end
    end

    register Deploy
  end
end
