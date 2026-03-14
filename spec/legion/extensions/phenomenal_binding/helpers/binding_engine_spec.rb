# frozen_string_literal: true

RSpec.describe Legion::Extensions::PhenomenalBinding::Helpers::BindingEngine do
  subject(:engine) { described_class.new }

  let(:stream_mod) { Legion::Extensions::PhenomenalBinding::Helpers::Stream }

  def register_n_streams(count, salience: 0.7)
    count.times.map do |i|
      engine.register_stream(stream_type: :perception, content: "content #{i}", salience: salience)
    end
  end

  describe '#register_stream' do
    it 'returns a Stream' do
      stream = engine.register_stream(stream_type: :thought, content: 'hello')
      expect(stream).to be_a(stream_mod)
    end

    it 'uses the given stream_type' do
      stream = engine.register_stream(stream_type: :emotion, content: 'joy')
      expect(stream.stream_type).to eq(:emotion)
    end

    it 'uses the given salience' do
      stream = engine.register_stream(stream_type: :memory, content: 'old', salience: 0.9)
      expect(stream.salience).to eq(0.9)
    end

    it 'stores stream internally' do
      stream = engine.register_stream(stream_type: :prediction, content: 'rain')
      stats = engine.to_h
      expect(stats[:stream_count]).to eq(1)
      expect(engine.unbound_streams.map(&:id)).to include(stream.id)
    end

    it 'prunes oldest stream when MAX_STREAMS exceeded' do
      101.times { |i| engine.register_stream(stream_type: :perception, content: "s#{i}") }
      expect(engine.to_h[:stream_count]).to eq(100)
    end
  end

  describe '#create_binding' do
    it 'returns a BindingUnit' do
      s = engine.register_stream(stream_type: :perception, content: 'x')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      expect(binding).to be_a(Legion::Extensions::PhenomenalBinding::Helpers::BindingUnit)
    end

    it 'computes initial coherence from stream saliences' do
      s1 = engine.register_stream(stream_type: :perception, content: 'a', salience: 0.8)
      s2 = engine.register_stream(stream_type: :thought, content: 'b', salience: 0.6)
      binding = engine.create_binding(stream_ids: [s1.id, s2.id], binding_type: :conceptual)
      expect(binding.coherence).to be_within(0.001).of(0.7)
    end

    it 'ignores stream_ids that are not registered' do
      s = engine.register_stream(stream_type: :perception, content: 'real')
      binding = engine.create_binding(stream_ids: [s.id, 'ghost-id'], binding_type: :temporal)
      expect(binding.stream_ids).to eq([s.id])
    end

    it 'stores binding internally' do
      s = engine.register_stream(stream_type: :memory, content: 'y')
      engine.create_binding(stream_ids: [s.id], binding_type: :narrative)
      expect(engine.to_h[:binding_count]).to eq(1)
    end

    it 'sets attention_weight' do
      s = engine.register_stream(stream_type: :intention, content: 'z')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :emotional, attention_weight: 0.9)
      expect(binding.attention_weight).to eq(0.9)
    end

    it 'prunes oldest binding when MAX_BINDINGS exceeded' do
      s = engine.register_stream(stream_type: :perception, content: 'base')
      201.times { engine.create_binding(stream_ids: [s.id], binding_type: :perceptual) }
      expect(engine.to_h[:binding_count]).to eq(200)
    end
  end

  describe '#reinforce_binding' do
    it 'increases coherence' do
      s = engine.register_stream(stream_type: :thought, content: 'q')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :conceptual, attention_weight: 0.5)
      initial_coherence = binding.coherence
      engine.reinforce_binding(binding_id: binding.id)
      expect(binding.coherence).to be > initial_coherence
    end

    it 'returns reinforced status with coherence' do
      s = engine.register_stream(stream_type: :perception, content: 'r')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      result = engine.reinforce_binding(binding_id: binding.id)
      expect(result[:status]).to eq(:reinforced)
      expect(result[:coherence]).to be_a(Float)
    end

    it 'returns not_found for unknown binding_id' do
      result = engine.reinforce_binding(binding_id: 'no-such-id')
      expect(result[:status]).to eq(:not_found)
    end
  end

  describe '#dissolve_binding' do
    it 'removes the binding' do
      s = engine.register_stream(stream_type: :emotion, content: 'fear')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :emotional)
      engine.dissolve_binding(binding_id: binding.id)
      expect(engine.to_h[:binding_count]).to eq(0)
    end

    it 'returns dissolved status' do
      s = engine.register_stream(stream_type: :memory, content: 'past')
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :narrative)
      result = engine.dissolve_binding(binding_id: binding.id)
      expect(result[:status]).to eq(:dissolved)
    end

    it 'returns not_found for unknown binding_id' do
      result = engine.dissolve_binding(binding_id: 'ghost')
      expect(result[:status]).to eq(:not_found)
    end
  end

  describe '#unified_experience' do
    it 'returns nil when no bindings exist' do
      expect(engine.unified_experience).to be_nil
    end

    it 'returns nil when no coherent bindings exist' do
      s = engine.register_stream(stream_type: :perception, content: 'dim', salience: 0.1)
      engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      expect(engine.unified_experience).to be_nil
    end

    it 'returns the strongest coherent binding' do
      s1 = engine.register_stream(stream_type: :perception, content: 'a', salience: 0.8)
      s2 = engine.register_stream(stream_type: :thought, content: 'b', salience: 0.9)
      engine.create_binding(stream_ids: [s1.id], binding_type: :perceptual, attention_weight: 0.5)
      b2 = engine.create_binding(stream_ids: [s2.id], binding_type: :conceptual, attention_weight: 0.9)
      experience = engine.unified_experience
      # b2 has higher coherence * attention_weight
      expect(experience.id).to eq(b2.id)
    end
  end

  describe '#fragmentation_index' do
    it 'returns 0.0 when no streams registered' do
      expect(engine.fragmentation_index).to eq(0.0)
    end

    it 'returns 1.0 when all streams are unbound' do
      register_n_streams(3)
      expect(engine.fragmentation_index).to eq(1.0)
    end

    it 'returns 0.0 when all streams are bound' do
      streams = register_n_streams(2)
      engine.create_binding(stream_ids: streams.map(&:id), binding_type: :perceptual)
      expect(engine.fragmentation_index).to eq(0.0)
    end

    it 'returns partial fraction for partially bound streams' do
      streams = register_n_streams(4)
      engine.create_binding(stream_ids: [streams[0].id, streams[1].id], binding_type: :temporal)
      expect(engine.fragmentation_index).to be_within(0.001).of(0.5)
    end
  end

  describe '#binding_by_type' do
    it 'returns bindings of the given type' do
      s = engine.register_stream(stream_type: :prediction, content: 'p')
      engine.create_binding(stream_ids: [s.id], binding_type: :temporal)
      engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      result = engine.binding_by_type(binding_type: :temporal)
      expect(result.size).to eq(1)
      expect(result.first.binding_type).to eq(:temporal)
    end

    it 'returns empty array when no bindings of that type' do
      expect(engine.binding_by_type(binding_type: :narrative)).to be_empty
    end
  end

  describe '#streams_for_binding' do
    it 'returns the streams belonging to a binding' do
      s1 = engine.register_stream(stream_type: :emotion, content: 'warm')
      s2 = engine.register_stream(stream_type: :memory, content: 'sunny')
      binding = engine.create_binding(stream_ids: [s1.id, s2.id], binding_type: :emotional)
      streams = engine.streams_for_binding(binding_id: binding.id)
      expect(streams.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    it 'returns empty array for unknown binding_id' do
      expect(engine.streams_for_binding(binding_id: 'ghost')).to be_empty
    end
  end

  describe '#unbound_streams' do
    it 'returns all streams when none are bound' do
      register_n_streams(3)
      expect(engine.unbound_streams.size).to eq(3)
    end

    it 'excludes streams that are in a binding' do
      s1 = engine.register_stream(stream_type: :perception, content: 'bound')
      engine.register_stream(stream_type: :thought, content: 'free')
      engine.create_binding(stream_ids: [s1.id], binding_type: :perceptual)
      unbound = engine.unbound_streams
      expect(unbound.map(&:id)).not_to include(s1.id)
      expect(unbound.size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'decreases coherence of all bindings' do
      s = engine.register_stream(stream_type: :memory, content: 'm', salience: 0.9)
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :narrative)
      initial = binding.coherence
      engine.decay_all
      expect(binding.coherence).to be < initial
    end

    it 'does not raise when no bindings exist' do
      expect { engine.decay_all }.not_to raise_error
    end
  end

  describe '#prune_incoherent' do
    it 'removes bindings below COHERENCE_THRESHOLD' do
      s = engine.register_stream(stream_type: :perception, content: 'faint', salience: 0.1)
      engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      engine.prune_incoherent
      expect(engine.to_h[:binding_count]).to eq(0)
    end

    it 'retains coherent bindings' do
      s = engine.register_stream(stream_type: :intention, content: 'strong', salience: 0.9)
      binding = engine.create_binding(stream_ids: [s.id], binding_type: :conceptual)
      engine.prune_incoherent
      expect(engine.to_h[:binding_count]).to eq(1)
      expect(engine.streams_for_binding(binding_id: binding.id)).not_to be_empty
    end
  end

  describe '#consciousness_report' do
    it 'returns a hash with expected keys' do
      report = engine.consciousness_report
      expect(report.keys).to include(
        :unified_experience, :fragmentation_index,
        :coherence_distribution, :stream_count, :binding_count, :unbound_count
      )
    end

    it 'includes nil unified_experience when no coherent bindings' do
      report = engine.consciousness_report
      expect(report[:unified_experience]).to be_nil
    end

    it 'includes a coherence_distribution hash with all labels' do
      report = engine.consciousness_report
      labels = report[:coherence_distribution].keys
      expect(labels).to include(:unified, :coherent, :fragmented, :dissociated, :unbound)
    end

    it 'reports correct stream_count' do
      register_n_streams(4)
      report = engine.consciousness_report
      expect(report[:stream_count]).to eq(4)
    end

    it 'includes unified_experience hash when a coherent binding exists' do
      s = engine.register_stream(stream_type: :perception, content: 'vivid', salience: 0.9)
      engine.create_binding(stream_ids: [s.id], binding_type: :perceptual)
      report = engine.consciousness_report
      expect(report[:unified_experience]).to be_a(Hash)
    end
  end

  describe '#to_h' do
    it 'returns engine stats' do
      register_n_streams(2)
      stats = engine.to_h
      expect(stats[:stream_count]).to eq(2)
      expect(stats[:binding_count]).to eq(0)
      expect(stats[:unbound_count]).to eq(2)
    end
  end
end
