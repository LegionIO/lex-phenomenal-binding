# frozen_string_literal: true

module Legion
  module Extensions
    module PhenomenalBinding
      module Runners
        module PhenomenalBinding
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_stream(stream_type:, content:, salience: Helpers::Constants::DEFAULT_SALIENCE,
                              domain: nil, **)
            stream = engine.register_stream(
              stream_type: stream_type,
              content:     content,
              salience:    salience,
              domain:      domain
            )
            Legion::Logging.debug "[phenomenal_binding] register_stream: type=#{stream_type} " \
                                  "salience=#{stream.salience.round(2)} domain=#{domain}"
            { status: :registered, stream: stream.to_h }
          end

          def create_binding(stream_ids:, binding_type:, attention_weight: 0.5, **)
            result = engine.create_binding(
              stream_ids:       stream_ids,
              binding_type:     binding_type,
              attention_weight: attention_weight
            )
            Legion::Logging.debug "[phenomenal_binding] create_binding: type=#{binding_type} " \
                                  "streams=#{result.stream_count} coherence=#{result.coherence.round(2)}"
            { status: :bound, binding: result.to_h }
          end

          def reinforce_binding(binding_id:, **)
            result = engine.reinforce_binding(binding_id: binding_id)
            Legion::Logging.debug "[phenomenal_binding] reinforce_binding: id=#{binding_id} " \
                                  "coherence=#{result[:coherence]&.round(2)}"
            result
          end

          def dissolve_binding(binding_id:, **)
            result = engine.dissolve_binding(binding_id: binding_id)
            Legion::Logging.debug "[phenomenal_binding] dissolve_binding: id=#{binding_id} status=#{result[:status]}"
            result
          end

          def unified_experience(**)
            experience = engine.unified_experience
            Legion::Logging.debug '[phenomenal_binding] unified_experience: ' \
                                  "coherence=#{experience&.coherence&.round(2) || 'none'}"
            { unified_experience: experience&.to_h }
          end

          def fragmentation_index(**)
            index = engine.fragmentation_index
            Legion::Logging.debug "[phenomenal_binding] fragmentation_index=#{index.round(3)}"
            { fragmentation_index: index }
          end

          def binding_by_type(binding_type:, **)
            bindings = engine.binding_by_type(binding_type: binding_type)
            Legion::Logging.debug "[phenomenal_binding] binding_by_type: type=#{binding_type} count=#{bindings.size}"
            { binding_type: binding_type, bindings: bindings.map(&:to_h) }
          end

          def streams_for_binding(binding_id:, **)
            streams = engine.streams_for_binding(binding_id: binding_id)
            Legion::Logging.debug "[phenomenal_binding] streams_for_binding: id=#{binding_id} count=#{streams.size}"
            { binding_id: binding_id, streams: streams.map(&:to_h) }
          end

          def unbound_streams(**)
            streams = engine.unbound_streams
            Legion::Logging.debug "[phenomenal_binding] unbound_streams: count=#{streams.size}"
            { unbound_streams: streams.map(&:to_h) }
          end

          def decay_all(**)
            engine.decay_all
            Legion::Logging.debug '[phenomenal_binding] decay_all: all bindings decayed'
            { status: :decayed }
          end

          def prune_incoherent(**)
            engine.prune_incoherent
            Legion::Logging.debug '[phenomenal_binding] prune_incoherent: incoherent bindings removed'
            { status: :pruned }
          end

          def consciousness_report(**)
            report = engine.consciousness_report
            Legion::Logging.debug '[phenomenal_binding] consciousness_report: ' \
                                  "fragmentation=#{report[:fragmentation_index].round(3)} " \
                                  "bindings=#{report[:binding_count]}"
            report
          end

          def engine_stats(**)
            engine.to_h
          end
        end
      end
    end
  end
end
