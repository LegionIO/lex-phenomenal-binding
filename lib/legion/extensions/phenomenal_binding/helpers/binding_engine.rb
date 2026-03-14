# frozen_string_literal: true

module Legion
  module Extensions
    module PhenomenalBinding
      module Helpers
        class BindingEngine
          include Constants

          def initialize
            @streams  = {}
            @bindings = {}
          end

          def register_stream(stream_type:, content:, salience: DEFAULT_SALIENCE, domain: nil)
            prune_streams_if_full
            stream = Stream.new(
              stream_type: stream_type,
              content:     content,
              salience:    salience,
              domain:      domain
            )
            @streams[stream.id] = stream
            stream
          end

          def create_binding(stream_ids:, binding_type:, attention_weight: 0.5)
            prune_bindings_if_full
            valid_ids   = stream_ids.select { |id| @streams.key?(id) }
            coherence   = compute_initial_coherence(valid_ids)
            binding     = BindingUnit.new(
              stream_ids:       valid_ids,
              binding_type:     binding_type,
              coherence:        coherence,
              attention_weight: attention_weight
            )
            @bindings[binding.id] = binding
            binding
          end

          def reinforce_binding(binding_id:)
            binding = @bindings[binding_id]
            return { status: :not_found, binding_id: binding_id } unless binding

            binding.reinforce!
            { status: :reinforced, binding_id: binding_id, coherence: binding.coherence }
          end

          def dissolve_binding(binding_id:)
            return { status: :not_found, binding_id: binding_id } unless @bindings.key?(binding_id)

            @bindings.delete(binding_id)
            { status: :dissolved, binding_id: binding_id }
          end

          def unified_experience
            coherent = @bindings.values.select(&:coherent?)
            return nil if coherent.empty?

            coherent.max_by { |b| b.coherence * b.attention_weight }
          end

          def fragmentation_index
            total = @streams.size
            return 0.0 if total.zero?

            (unbound_streams.size.to_f / total).round(10)
          end

          def binding_by_type(binding_type:)
            @bindings.values.select { |b| b.binding_type == binding_type }
          end

          def streams_for_binding(binding_id:)
            binding = @bindings[binding_id]
            return [] unless binding

            binding.stream_ids.filter_map { |id| @streams[id] }
          end

          def unbound_streams
            bound_ids = @bindings.values.flat_map(&:stream_ids).to_set
            @streams.values.reject { |s| bound_ids.include?(s.id) }
          end

          def decay_all
            @bindings.each_value(&:decay!)
          end

          def prune_incoherent
            @bindings.delete_if { |_, b| !b.coherent? }
          end

          def consciousness_report
            experience = unified_experience
            distribution = coherence_distribution

            {
              unified_experience:     experience&.to_h,
              fragmentation_index:    fragmentation_index,
              coherence_distribution: distribution,
              stream_count:           @streams.size,
              binding_count:          @bindings.size,
              unbound_count:          unbound_streams.size
            }
          end

          def to_h
            {
              stream_count:  @streams.size,
              binding_count: @bindings.size,
              unbound_count: unbound_streams.size,
              fragmentation: fragmentation_index
            }
          end

          private

          def compute_initial_coherence(stream_ids)
            return 0.0 if stream_ids.empty?

            saliences = stream_ids.filter_map { |id| @streams[id]&.salience }
            return 0.0 if saliences.empty?

            (saliences.sum / saliences.size).round(10)
          end

          def coherence_distribution
            Constants::COHERENCE_LABELS.to_h do |_range, label|
              count = @bindings.values.count { |b| b.coherence_label == label }
              [label, count]
            end
          end

          def prune_streams_if_full
            return if @streams.size < MAX_STREAMS

            oldest = @streams.values.min_by(&:created_at)
            @streams.delete(oldest.id) if oldest
          end

          def prune_bindings_if_full
            return if @bindings.size < MAX_BINDINGS

            oldest = @bindings.values.min_by(&:created_at)
            @bindings.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
