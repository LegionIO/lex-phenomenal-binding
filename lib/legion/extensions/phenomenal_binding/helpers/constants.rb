# frozen_string_literal: true

module Legion
  module Extensions
    module PhenomenalBinding
      module Helpers
        module Constants
          MAX_STREAMS   = 100
          MAX_BINDINGS  = 200

          COHERENCE_THRESHOLD = 0.6
          BINDING_DECAY       = 0.03
          BINDING_BOOST       = 0.08
          DEFAULT_SALIENCE    = 0.5

          BINDING_TYPES = %i[perceptual conceptual temporal narrative emotional].freeze

          COHERENCE_LABELS = {
            (0.8..)     => :unified,
            (0.6...0.8) => :coherent,
            (0.4...0.6) => :fragmented,
            (0.2...0.4) => :dissociated,
            (..0.2)     => :unbound
          }.freeze

          STREAM_TYPES = %i[perception thought emotion memory intention prediction].freeze
        end
      end
    end
  end
end
