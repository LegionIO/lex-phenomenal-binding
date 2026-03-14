# frozen_string_literal: true

require 'legion/extensions/phenomenal_binding/client'

RSpec.describe Legion::Extensions::PhenomenalBinding::Runners::PhenomenalBinding do
  let(:client) { Legion::Extensions::PhenomenalBinding::Client.new }

  describe '#register_stream' do
    it 'returns a registered status' do
      result = client.register_stream(stream_type: :perception, content: 'red circle')
      expect(result[:status]).to eq(:registered)
    end

    it 'returns a stream hash' do
      result = client.register_stream(stream_type: :thought, content: 'abstract idea')
      expect(result[:stream]).to be_a(Hash)
      expect(result[:stream][:id]).to be_a(String)
    end

    it 'uses the given stream_type' do
      result = client.register_stream(stream_type: :emotion, content: 'joy')
      expect(result[:stream][:stream_type]).to eq(:emotion)
    end

    it 'accepts custom salience' do
      result = client.register_stream(stream_type: :memory, content: 'vivid', salience: 0.9)
      expect(result[:stream][:salience]).to eq(0.9)
    end
  end

  describe '#create_binding' do
    it 'returns a bound status' do
      s = client.register_stream(stream_type: :perception, content: 'a')
      result = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :perceptual)
      expect(result[:status]).to eq(:bound)
    end

    it 'returns a binding hash' do
      s = client.register_stream(stream_type: :thought, content: 'concept')
      result = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :conceptual)
      expect(result[:binding]).to be_a(Hash)
      expect(result[:binding][:binding_type]).to eq(:conceptual)
    end

    it 'coherence reflects stream saliences' do
      s = client.register_stream(stream_type: :perception, content: 'bright', salience: 0.8)
      result = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :perceptual)
      expect(result[:binding][:coherence]).to be_within(0.001).of(0.8)
    end
  end

  describe '#reinforce_binding' do
    it 'returns reinforced status for valid binding' do
      s = client.register_stream(stream_type: :intention, content: 'goal')
      b = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :narrative)
      result = client.reinforce_binding(binding_id: b[:binding][:id])
      expect(result[:status]).to eq(:reinforced)
    end

    it 'returns not_found for unknown binding' do
      result = client.reinforce_binding(binding_id: 'bogus')
      expect(result[:status]).to eq(:not_found)
    end
  end

  describe '#dissolve_binding' do
    it 'returns dissolved status for valid binding' do
      s = client.register_stream(stream_type: :memory, content: 'past')
      b = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :temporal)
      result = client.dissolve_binding(binding_id: b[:binding][:id])
      expect(result[:status]).to eq(:dissolved)
    end

    it 'returns not_found for unknown binding' do
      result = client.dissolve_binding(binding_id: 'ghost')
      expect(result[:status]).to eq(:not_found)
    end
  end

  describe '#unified_experience' do
    it 'returns nil unified_experience when no coherent bindings' do
      result = client.unified_experience
      expect(result[:unified_experience]).to be_nil
    end

    it 'returns a binding hash when coherent binding exists' do
      s = client.register_stream(stream_type: :perception, content: 'vivid', salience: 0.9)
      client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :perceptual)
      result = client.unified_experience
      expect(result[:unified_experience]).to be_a(Hash)
    end
  end

  describe '#fragmentation_index' do
    it 'returns fragmentation_index key' do
      result = client.fragmentation_index
      expect(result).to have_key(:fragmentation_index)
    end

    it 'returns 0.0 when no streams exist' do
      expect(client.fragmentation_index[:fragmentation_index]).to eq(0.0)
    end

    it 'returns 1.0 when all streams are unbound' do
      client.register_stream(stream_type: :thought, content: 'loose')
      expect(client.fragmentation_index[:fragmentation_index]).to eq(1.0)
    end
  end

  describe '#binding_by_type' do
    it 'returns bindings of the requested type' do
      s = client.register_stream(stream_type: :prediction, content: 'forecast')
      client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :temporal)
      result = client.binding_by_type(binding_type: :temporal)
      expect(result[:binding_type]).to eq(:temporal)
      expect(result[:bindings].size).to eq(1)
    end

    it 'returns empty array for absent type' do
      result = client.binding_by_type(binding_type: :narrative)
      expect(result[:bindings]).to be_empty
    end
  end

  describe '#streams_for_binding' do
    it 'returns streams belonging to the binding' do
      s = client.register_stream(stream_type: :emotion, content: 'warmth')
      b = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :emotional)
      result = client.streams_for_binding(binding_id: b[:binding][:id])
      expect(result[:streams].size).to eq(1)
      expect(result[:streams].first[:id]).to eq(s[:stream][:id])
    end
  end

  describe '#unbound_streams' do
    it 'returns all streams when nothing is bound' do
      client.register_stream(stream_type: :intention, content: 'plan')
      result = client.unbound_streams
      expect(result[:unbound_streams].size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'returns decayed status' do
      result = client.decay_all
      expect(result[:status]).to eq(:decayed)
    end
  end

  describe '#prune_incoherent' do
    it 'returns pruned status' do
      result = client.prune_incoherent
      expect(result[:status]).to eq(:pruned)
    end
  end

  describe '#consciousness_report' do
    it 'returns all expected report keys' do
      report = client.consciousness_report
      expect(report.keys).to include(
        :unified_experience, :fragmentation_index,
        :coherence_distribution, :stream_count, :binding_count, :unbound_count
      )
    end
  end

  describe '#engine_stats' do
    it 'returns engine stats hash' do
      stats = client.engine_stats
      expect(stats[:stream_count]).to eq(0)
      expect(stats[:binding_count]).to eq(0)
    end
  end
end
