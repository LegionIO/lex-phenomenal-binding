# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module PhenomenalBinding
      module Helpers
        class BindingUnit
          include Constants

          attr_reader :id, :stream_ids, :binding_type, :coherence, :attention_weight, :created_at

          def initialize(stream_ids:, binding_type:, coherence:, attention_weight: 0.5)
            @id              = ::SecureRandom.uuid
            @stream_ids      = stream_ids.dup
            @binding_type    = binding_type
            @coherence       = coherence.clamp(0.0, 1.0)
            @attention_weight = attention_weight.clamp(0.0, 1.0)
            @created_at = Time.now.utc
          end

          def add_stream(stream_id:)
            @stream_ids << stream_id unless @stream_ids.include?(stream_id)
          end

          def remove_stream(stream_id:)
            @stream_ids.delete(stream_id)
          end

          def reinforce!
            @coherence = (@coherence + BINDING_BOOST).clamp(0.0, 1.0)
          end

          def decay!
            @coherence = (@coherence - BINDING_DECAY).clamp(0.0, 1.0)
          end

          def coherent?
            @coherence >= COHERENCE_THRESHOLD
          end

          def coherence_label
            COHERENCE_LABELS.find { |range, _| range.cover?(@coherence) }&.last || :unbound
          end

          def stream_count
            @stream_ids.size
          end

          def to_h
            {
              id:               @id,
              stream_ids:       @stream_ids.dup,
              binding_type:     @binding_type,
              coherence:        @coherence.round(10),
              attention_weight: @attention_weight.round(10),
              coherent:         coherent?,
              coherence_label:  coherence_label,
              stream_count:     stream_count,
              created_at:       @created_at
            }
          end
        end
      end
    end
  end
end
