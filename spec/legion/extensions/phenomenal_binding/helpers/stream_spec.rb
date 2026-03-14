# frozen_string_literal: true

RSpec.describe Legion::Extensions::PhenomenalBinding::Helpers::Stream do
  let(:stream) { described_class.new(stream_type: :perception, content: 'a red circle') }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(stream.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'assigns stream_type' do
      expect(stream.stream_type).to eq(:perception)
    end

    it 'assigns content' do
      expect(stream.content).to eq('a red circle')
    end

    it 'defaults salience to 0.5' do
      expect(stream.salience).to eq(0.5)
    end

    it 'accepts custom salience' do
      s = described_class.new(stream_type: :thought, content: 'deep', salience: 0.9)
      expect(s.salience).to eq(0.9)
    end

    it 'clamps salience above 1.0' do
      s = described_class.new(stream_type: :emotion, content: 'joy', salience: 1.5)
      expect(s.salience).to eq(1.0)
    end

    it 'clamps salience below 0.0' do
      s = described_class.new(stream_type: :memory, content: 'old', salience: -0.3)
      expect(s.salience).to eq(0.0)
    end

    it 'assigns domain' do
      s = described_class.new(stream_type: :intention, content: 'plan', domain: 'work')
      expect(s.domain).to eq('work')
    end

    it 'defaults domain to nil' do
      expect(stream.domain).to be_nil
    end

    it 'sets created_at to a Time' do
      expect(stream.created_at).to be_a(Time)
    end

    it 'sets timestamp' do
      expect(stream.timestamp).to be_a(Time)
    end

    it 'accepts explicit timestamp' do
      t = Time.now.utc - 60
      s = described_class.new(stream_type: :prediction, content: 'rain', timestamp: t)
      expect(s.timestamp).to eq(t)
    end
  end

  describe '#salient?' do
    it 'returns true when salience >= 0.5' do
      s = described_class.new(stream_type: :perception, content: 'x', salience: 0.7)
      expect(s.salient?).to be true
    end

    it 'returns true when salience exactly 0.5' do
      expect(stream.salient?).to be true
    end

    it 'returns false when salience < 0.5' do
      s = described_class.new(stream_type: :thought, content: 'dim', salience: 0.3)
      expect(s.salient?).to be false
    end
  end

  describe '#fresh?' do
    it 'returns true for a just-created stream' do
      expect(stream.fresh?).to be true
    end

    it 'returns false for an old stream' do
      allow(stream).to receive(:created_at).and_return(Time.now.utc - 60)
      expect(stream.fresh?(window: 30)).to be false
    end

    it 'uses default window of 30 seconds' do
      expect(stream.fresh?).to be true
    end

    it 'accepts a custom window' do
      expect(stream.fresh?(window: 3600)).to be true
    end
  end

  describe '#to_h' do
    subject(:hash) { stream.to_h }

    it 'includes id' do
      expect(hash[:id]).to be_a(String)
    end

    it 'includes stream_type' do
      expect(hash[:stream_type]).to eq(:perception)
    end

    it 'includes content' do
      expect(hash[:content]).to eq('a red circle')
    end

    it 'includes salience as a rounded float' do
      expect(hash[:salience]).to be_a(Float)
    end

    it 'includes domain' do
      expect(hash).to have_key(:domain)
    end

    it 'includes timestamp' do
      expect(hash[:timestamp]).to be_a(Time)
    end

    it 'includes created_at' do
      expect(hash[:created_at]).to be_a(Time)
    end
  end
end
