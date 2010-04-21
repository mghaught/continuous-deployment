module Integrity
  class Notifier
    class Deploy < Notifier::Base
      attr_reader :deploy
      
#       http://matedriven.com.ar/2009/09/21/continuous-notification-with-integrity.html
      def self.to_haml
        <<-haml
%p.normal
  %label{ :for => "deploy_notifier_deploy" } Deploy Script
  %input.text#deploy_notifier_deploy{ :name => "notifiers[Deploy][deploy]", :type => "text", :value => config["deploy"] }
        haml
      end

      def initialize(build, config={})
        @deploy = config.delete("deploy")
        log("Initiatizing... deploy command is '#{@deploy}'")
        super
      end

      def deliver!
        log("Full build message:\n#{full_message}")
        system("echo '#{build.status} - #{build.commit.identifier}' >> /tmp/deploy_notifier")
        log("FAILED") if build.failed?
        log("SUCCESS") if build.successful?
      end

      def log(msg)
        Integrity.log('Deploy') {msg}
      end
    end

    register Deploy
  end
end
