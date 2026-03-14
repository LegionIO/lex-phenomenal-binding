# lex-phenomenal-binding

Phenomenal binding model for the LegionIO cognitive architecture. Integrates disparate cognitive streams into unified moments of experience.

## What It Does

Models the binding problem from cognitive science: how separate streams of processing (perception, thought, emotion, memory, intention, prediction) are grouped into coherent, unified experiences. Maintains a registry of named streams and binding units. Each binding tracks coherence (decays over time, reinforced by attention) and provides a fragmentation index indicating how much of the cognitive state is unintegrated.

## Usage

```ruby
client = Legion::Extensions::PhenomenalBinding::Client.new

# Register cognitive streams
r1 = client.register_stream(stream_type: :emotion, content: 'mild_anticipation', salience: 0.7)
r2 = client.register_stream(stream_type: :prediction, content: 'success_likely', salience: 0.8)
r3 = client.register_stream(stream_type: :memory, content: 'prior_success_trace', salience: 0.6)

s1_id = r1[:stream][:id]
s2_id = r2[:stream][:id]
s3_id = r3[:stream][:id]

# Create a binding grouping the streams
b = client.create_binding(
  stream_ids: [s1_id, s2_id, s3_id],
  binding_type: :emotional,
  attention_weight: 0.8
)
binding_id = b[:binding][:id]

# Reinforce the binding with attention
client.reinforce_binding(binding_id: binding_id)
# => { status: :reinforced, binding_id: ..., coherence: 0.78 }

# Check unified experience
client.unified_experience
# => { unified_experience: { binding_type: :emotional, coherence: 0.78, stream_count: 3, ... } }

# Check fragmentation
client.fragmentation_index
# => { fragmentation_index: 0.0 }

# Full consciousness report
client.consciousness_report
# => { unified_experience: {...}, fragmentation_index: 0.0,
#      coherence_distribution: { unified: 1, coherent: 0, ... },
#      stream_count: 3, binding_count: 1, unbound_count: 0 }

# Decay and prune on each tick
client.decay_all
client.prune_incoherent
```

## Binding Types

`:perceptual`, `:conceptual`, `:temporal`, `:narrative`, `:emotional`

## Stream Types

`:perception`, `:thought`, `:emotion`, `:memory`, `:intention`, `:prediction`

## Coherence Labels

| Label | Coherence |
|-------|-----------|
| `:unified` | >= 0.8 |
| `:coherent` | 0.6 – 0.8 |
| `:fragmented` | 0.4 – 0.6 |
| `:dissociated` | 0.2 – 0.4 |
| `:unbound` | < 0.2 |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
