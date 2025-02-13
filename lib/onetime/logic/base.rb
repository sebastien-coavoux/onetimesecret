# typed: false

module Onetime
  module Logic
    class Base

      attr_reader :sess, :cust, :params, :locale, :processed_params, :plan

      def initialize(sess, cust, params = nil, locale = nil)
        @sess = sess
        @cust = cust
        @params = params
        @locale = locale
        @processed_params ||= {} # TODO: Remove
        process_params if respond_to?(:process_params) && @params
      end

      def valid_email?(guess)
        OT.ld "[valid_email?] Guess: #{guess}"
        Truemail.validate(guess, with: :regex).result.valid?
      end

      protected

      def process_params
        raise NotImplementedError, 'process_params not implemented'
      end

      def form_fields
        OT.ld "No form_fields method for #{self.class}"
        {}
      end

      def raise_form_error(msg)
        ex = OT::FormError.new
        ex.message = msg
        ex.form_fields = form_fields
        raise ex
      end

      def plan
        @plan = Onetime::Plan.plan(cust.planid) unless cust.nil?
        @plan ||= Onetime::Plan.plan('anonymous')
      end

      def limit_action(event)
        return if plan.paid?

        sess.event_incr! event
      end
    end

    class << self
      attr_writer :stathat_apikey, :stathat_enabled

      def stathat_apikey
        @stathat_apikey ||= Onetime.conf[:stathat][:apikey]
      end

      def stathat_enabled
        return unless Onetime.conf.has_key?(:stathat)

        @stathat_enabled = Onetime.conf[:stathat][:enabled] if @stathat_enabled.nil?
        @stathat_enabled
      end

      def stathat_count(name, count, wait = 0.500)
        return false unless stathat_enabled

        begin
          Timeout.timeout(wait) do
            StatHat::API.ez_post_count(name, stathat_apikey, count)
          end
        rescue SocketError => e
          OT.info "Cannot connect to StatHat: #{e.message}"
        rescue Timeout::Error
          OT.info 'timeout calling stathat'
        end
      end

      def stathat_value(name, value, wait = 0.500)
        return false unless stathat_enabled

        begin
          Timeout.timeout(wait) do
            StatHat::API.ez_post_value(name, stathat_apikey, value)
          end
        rescue SocketError => e
          OT.info "Cannot connect to StatHat: #{e.message}"
        rescue Timeout::Error
          OT.info 'timeout calling stathat'
        end
      end
    end
  end
end
