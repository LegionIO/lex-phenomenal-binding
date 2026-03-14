# frozen_string_literal: true

require 'legion/extensions/phenomenal_binding/client'

RSpec.describe Legion::Extensions::PhenomenalBinding::Client do
  let(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:register_stream)
    expect(client).to respond_to(:create_binding)
    expect(client).to respond_to(:reinforce_binding)
    expect(client).to respond_to(:dissolve_binding)
    expect(client).to respond_to(:unified_experience)
    expect(client).to respond_to(:fragmentation_index)
    expect(client).to respond_to(:binding_by_type)
    expect(client).to respond_to(:streams_for_binding)
    expect(client).to respond_to(:unbound_streams)
    expect(client).to respond_to(:decay_all)
    expect(client).to respond_to(:prune_incoherent)
    expect(client).to respond_to(:consciousness_report)
    expect(client).to respond_to(:engine_stats)
  end

  it 'maintains independent engine state per instance' do
    c1 = described_class.new
    c2 = described_class.new
    c1.register_stream(stream_type: :perception, content: 'only in c1')
    expect(c1.engine_stats[:stream_count]).to eq(1)
    expect(c2.engine_stats[:stream_count]).to eq(0)
  end

  it 'runs a full bind/reinforce/dissolve cycle' do
    s = client.register_stream(stream_type: :thought, content: 'philosophy', salience: 0.75)
    b = client.create_binding(stream_ids: [s[:stream][:id]], binding_type: :conceptual)
    client.reinforce_binding(binding_id: b[:binding][:id])
    expect(client.unified_experience[:unified_experience]).to be_a(Hash)
    client.dissolve_binding(binding_id: b[:binding][:id])
    expect(client.unified_experience[:unified_experience]).to be_nil
  end

  it 'builds a consciousness report across multiple streams and bindings' do
    s1 = client.register_stream(stream_type: :perception, content: 'light', salience: 0.8)
    s2 = client.register_stream(stream_type: :emotion, content: 'warmth', salience: 0.7)
    s3 = client.register_stream(stream_type: :memory, content: 'familiar', salience: 0.9)
    client.create_binding(stream_ids: [s1[:stream][:id], s2[:stream][:id]], binding_type: :emotional)
    report = client.consciousness_report
    expect(report[:stream_count]).to eq(3)
    expect(report[:binding_count]).to eq(1)
    expect(report[:unbound_count]).to eq(1) # s3 is unbound
    _ = s3
  end
end
