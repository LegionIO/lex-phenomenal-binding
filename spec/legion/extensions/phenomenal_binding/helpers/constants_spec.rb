# frozen_string_literal: true

RSpec.describe Legion::Extensions::PhenomenalBinding::Helpers::Constants do
  describe 'capacity constants' do
    it 'defines MAX_STREAMS' do
      expect(described_class::MAX_STREAMS).to eq(100)
    end

    it 'defines MAX_BINDINGS' do
      expect(described_class::MAX_BINDINGS).to eq(200)
    end
  end

  describe 'coherence constants' do
    it 'defines COHERENCE_THRESHOLD' do
      expect(described_class::COHERENCE_THRESHOLD).to eq(0.6)
    end

    it 'defines BINDING_DECAY' do
      expect(described_class::BINDING_DECAY).to eq(0.03)
    end

    it 'defines BINDING_BOOST' do
      expect(described_class::BINDING_BOOST).to eq(0.08)
    end

    it 'defines DEFAULT_SALIENCE' do
      expect(described_class::DEFAULT_SALIENCE).to eq(0.5)
    end
  end

  describe 'BINDING_TYPES' do
    it 'includes all five types' do
      expect(described_class::BINDING_TYPES).to contain_exactly(
        :perceptual, :conceptual, :temporal, :narrative, :emotional
      )
    end

    it 'is frozen' do
      expect(described_class::BINDING_TYPES).to be_frozen
    end
  end

  describe 'STREAM_TYPES' do
    it 'includes all six types' do
      expect(described_class::STREAM_TYPES).to contain_exactly(
        :perception, :thought, :emotion, :memory, :intention, :prediction
      )
    end

    it 'is frozen' do
      expect(described_class::STREAM_TYPES).to be_frozen
    end
  end

  describe 'COHERENCE_LABELS' do
    it 'maps 0.9 to :unified' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.9) }&.last
      expect(label).to eq(:unified)
    end

    it 'maps 0.7 to :coherent' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.7) }&.last
      expect(label).to eq(:coherent)
    end

    it 'maps 0.5 to :fragmented' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.5) }&.last
      expect(label).to eq(:fragmented)
    end

    it 'maps 0.3 to :dissociated' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.3) }&.last
      expect(label).to eq(:dissociated)
    end

    it 'maps 0.1 to :unbound' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.1) }&.last
      expect(label).to eq(:unbound)
    end

    it 'maps exactly 0.8 to :unified' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.8) }&.last
      expect(label).to eq(:unified)
    end

    it 'maps exactly 0.6 to :coherent' do
      label = described_class::COHERENCE_LABELS.find { |range, _| range.cover?(0.6) }&.last
      expect(label).to eq(:coherent)
    end
  end
end
