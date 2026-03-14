# frozen_string_literal: true

RSpec.describe Legion::Extensions::PhenomenalBinding::Helpers::BindingUnit do
  let(:stream_ids) { %w[stream-1 stream-2 stream-3] }
  let(:binding) do
    described_class.new(stream_ids: stream_ids, binding_type: :perceptual, coherence: 0.7)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(binding.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'assigns stream_ids' do
      expect(binding.stream_ids).to eq(stream_ids)
    end

    it 'assigns binding_type' do
      expect(binding.binding_type).to eq(:perceptual)
    end

    it 'assigns coherence' do
      expect(binding.coherence).to eq(0.7)
    end

    it 'defaults attention_weight to 0.5' do
      expect(binding.attention_weight).to eq(0.5)
    end

    it 'accepts custom attention_weight' do
      b = described_class.new(stream_ids: [], binding_type: :temporal, coherence: 0.5, attention_weight: 0.9)
      expect(b.attention_weight).to eq(0.9)
    end

    it 'clamps coherence above 1.0' do
      b = described_class.new(stream_ids: [], binding_type: :conceptual, coherence: 1.5)
      expect(b.coherence).to eq(1.0)
    end

    it 'clamps coherence below 0.0' do
      b = described_class.new(stream_ids: [], binding_type: :narrative, coherence: -0.2)
      expect(b.coherence).to eq(0.0)
    end

    it 'does not share the input array reference' do
      original = %w[a b]
      b = described_class.new(stream_ids: original, binding_type: :emotional, coherence: 0.5)
      original << 'c'
      expect(b.stream_ids.size).to eq(2)
    end
  end

  describe '#add_stream' do
    it 'adds a new stream_id' do
      binding.add_stream(stream_id: 'stream-4')
      expect(binding.stream_ids).to include('stream-4')
    end

    it 'does not duplicate an existing stream_id' do
      binding.add_stream(stream_id: 'stream-1')
      expect(binding.stream_ids.count('stream-1')).to eq(1)
    end
  end

  describe '#remove_stream' do
    it 'removes an existing stream_id' do
      binding.remove_stream(stream_id: 'stream-2')
      expect(binding.stream_ids).not_to include('stream-2')
    end

    it 'does not raise when removing a non-existent id' do
      expect { binding.remove_stream(stream_id: 'ghost') }.not_to raise_error
    end
  end

  describe '#reinforce!' do
    it 'increases coherence by BINDING_BOOST' do
      initial = binding.coherence
      binding.reinforce!
      expect(binding.coherence).to be_within(0.001).of(initial + 0.08)
    end

    it 'clamps coherence at 1.0' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.97)
      b.reinforce!
      expect(b.coherence).to eq(1.0)
    end
  end

  describe '#decay!' do
    it 'decreases coherence by BINDING_DECAY' do
      initial = binding.coherence
      binding.decay!
      expect(binding.coherence).to be_within(0.001).of(initial - 0.03)
    end

    it 'clamps coherence at 0.0' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.01)
      b.decay!
      expect(b.coherence).to eq(0.0)
    end
  end

  describe '#coherent?' do
    it 'returns true when coherence >= COHERENCE_THRESHOLD' do
      b = described_class.new(stream_ids: [], binding_type: :temporal, coherence: 0.7)
      expect(b.coherent?).to be true
    end

    it 'returns true at the exact threshold' do
      b = described_class.new(stream_ids: [], binding_type: :temporal, coherence: 0.6)
      expect(b.coherent?).to be true
    end

    it 'returns false below the threshold' do
      b = described_class.new(stream_ids: [], binding_type: :temporal, coherence: 0.5)
      expect(b.coherent?).to be false
    end
  end

  describe '#coherence_label' do
    it 'returns :unified at 0.9' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.9)
      expect(b.coherence_label).to eq(:unified)
    end

    it 'returns :coherent at 0.7' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.7)
      expect(b.coherence_label).to eq(:coherent)
    end

    it 'returns :fragmented at 0.5' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.5)
      expect(b.coherence_label).to eq(:fragmented)
    end

    it 'returns :dissociated at 0.3' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.3)
      expect(b.coherence_label).to eq(:dissociated)
    end

    it 'returns :unbound at 0.1' do
      b = described_class.new(stream_ids: [], binding_type: :perceptual, coherence: 0.1)
      expect(b.coherence_label).to eq(:unbound)
    end
  end

  describe '#stream_count' do
    it 'returns the number of stream ids' do
      expect(binding.stream_count).to eq(3)
    end

    it 'updates after adding a stream' do
      binding.add_stream(stream_id: 'new')
      expect(binding.stream_count).to eq(4)
    end
  end

  describe '#to_h' do
    subject(:hash) { binding.to_h }

    it 'includes id' do
      expect(hash[:id]).to be_a(String)
    end

    it 'includes stream_ids' do
      expect(hash[:stream_ids]).to eq(stream_ids)
    end

    it 'includes binding_type' do
      expect(hash[:binding_type]).to eq(:perceptual)
    end

    it 'includes coherence as a float' do
      expect(hash[:coherence]).to be_a(Float)
    end

    it 'includes coherent boolean' do
      expect(hash[:coherent]).to be true
    end

    it 'includes coherence_label' do
      expect(hash[:coherence_label]).to eq(:coherent)
    end

    it 'includes stream_count' do
      expect(hash[:stream_count]).to eq(3)
    end

    it 'does not share stream_ids array reference' do
      hash[:stream_ids] << 'extra'
      expect(binding.stream_ids.size).to eq(3)
    end
  end
end
