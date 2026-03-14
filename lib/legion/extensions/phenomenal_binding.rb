# frozen_string_literal: true

require 'legion/extensions/phenomenal_binding/version'
require 'legion/extensions/phenomenal_binding/helpers/constants'
require 'legion/extensions/phenomenal_binding/helpers/stream'
require 'legion/extensions/phenomenal_binding/helpers/binding_unit'
require 'legion/extensions/phenomenal_binding/helpers/binding_engine'
require 'legion/extensions/phenomenal_binding/runners/phenomenal_binding'
require 'legion/extensions/phenomenal_binding/client'

module Legion
  module Extensions
    module PhenomenalBinding
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
