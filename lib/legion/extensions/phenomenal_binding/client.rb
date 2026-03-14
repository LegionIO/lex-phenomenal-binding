# frozen_string_literal: true

require 'legion/extensions/phenomenal_binding/runners/phenomenal_binding'

module Legion
  module Extensions
    module PhenomenalBinding
      class Client
        include Runners::PhenomenalBinding

        def initialize(**)
          @engine = Helpers::BindingEngine.new
        end

        private

        attr_reader :engine
      end
    end
  end
end
