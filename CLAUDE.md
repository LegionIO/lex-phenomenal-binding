# lex-phenomenal-binding

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-phenomenal-binding`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::PhenomenalBinding`

## Purpose

Models the binding problem from cognitive science: how disparate streams of processing (perception, thought, emotion, memory, intention, prediction) are integrated into a unified moment of experience. Maintains a registry of `Stream` objects and `BindingUnit` objects. Bindings group streams together with a coherence score that decays over time and can be reinforced. Provides fragmentation index, consciousness report, and unified experience selection.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-phenomenal-binding
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/phenomenal_binding/
  version.rb
  client.rb
  helpers/
    constants.rb       # BINDING_TYPES, STREAM_TYPES, COHERENCE_LABELS, limits
    stream.rb          # Stream class — typed content node with salience
    binding_unit.rb    # BindingUnit class — coherence-tracked group of stream IDs
    binding_engine.rb  # BindingEngine — manages streams and bindings
  runners/
    phenomenal_binding.rb  # Runner module
spec/
  helpers/constants_spec.rb
  helpers/stream_spec.rb
  helpers/binding_unit_spec.rb
  helpers/binding_engine_spec.rb
  runners/phenomenal_binding_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `MAX_STREAMS = 100`, `MAX_BINDINGS = 200`
- `COHERENCE_THRESHOLD = 0.6`, `BINDING_DECAY = 0.03`, `BINDING_BOOST = 0.08`
- `DEFAULT_SALIENCE = 0.5`
- `BINDING_TYPES = %i[perceptual conceptual temporal narrative emotional]`
- `STREAM_TYPES = %i[perception thought emotion memory intention prediction]`
- `COHERENCE_LABELS`: `:unified` (0.8+), `:coherent`, `:fragmented`, `:dissociated`, `:unbound`

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `register_stream` | `stream_type:`, `content:`, `salience:`, `domain:` | `{ status: :registered, stream: }` |
| `create_binding` | `stream_ids:`, `binding_type:`, `attention_weight:` | `{ status: :bound, binding: }` |
| `reinforce_binding` | `binding_id:` | `{ status: :reinforced, binding_id:, coherence: }` |
| `dissolve_binding` | `binding_id:` | `{ status: :dissolved, binding_id: }` |
| `unified_experience` | — | `{ unified_experience: }` (highest coherence * attention_weight binding) |
| `fragmentation_index` | — | `{ fragmentation_index: }` (unbound_streams / total_streams) |
| `binding_by_type` | `binding_type:` | `{ binding_type:, bindings: }` |
| `streams_for_binding` | `binding_id:` | `{ binding_id:, streams: }` |
| `unbound_streams` | — | `{ unbound_streams: }` |
| `decay_all` | — | `{ status: :decayed }` |
| `prune_incoherent` | — | `{ status: :pruned }` |
| `consciousness_report` | — | unified experience + fragmentation + coherence distribution |
| `engine_stats` | — | stream/binding/unbound counts, fragmentation |

## Helpers

### `Helpers::Stream`
Individual processing stream: `id` (UUID), `stream_type`, `content`, `salience` (clamped 0–1), `domain`, `timestamp`, `created_at`. `salient?` = salience >= 0.5. `fresh?(window:)` = created within window seconds.

### `Helpers::BindingUnit`
Coherence-tracked group of stream IDs: `id`, `stream_ids`, `binding_type`, `coherence`, `attention_weight`, `created_at`. `reinforce!` adds `BINDING_BOOST`. `decay!` subtracts `BINDING_DECAY`. `coherent?` = coherence >= `COHERENCE_THRESHOLD`. `coherence_label` maps to `COHERENCE_LABELS`.

### `Helpers::BindingEngine`
Manages `@streams` and `@bindings` hashes. `register_stream` prunes oldest when at capacity. `create_binding` computes initial coherence as mean salience of valid stream IDs. `unified_experience` returns the coherent binding with highest `coherence * attention_weight`. `fragmentation_index` = unbound streams / total streams. `consciousness_report` combines all summary metrics. `coherence_distribution` counts bindings per coherence label.

## Integration Points

- `register_stream` with type `:emotion` can accept output from `lex-emotion`'s valence model
- `register_stream` with type `:prediction` integrates `lex-prediction` forward-model outputs
- `register_stream` with type `:memory` connects with `lex-memory` trace retrievals
- `unified_experience` output can feed `lex-narrator` as the highest-integrated conscious moment
- `fragmentation_index` can feed `lex-reflection` as a coherence health metric
- `consciousness_report` can feed `lex-tick`'s `post_tick_reflection` phase

## Development Notes

- Initial coherence on `create_binding` = mean salience of the provided stream IDs
- Streams beyond `MAX_STREAMS` evict the oldest by `created_at`
- `coherent?` threshold is 0.6; below this a binding is "fragmented" and prunable
- `prune_incoherent` removes all bindings with coherence < `COHERENCE_THRESHOLD`
- `unified_experience` returns nil if no coherent bindings exist
- All state is in-memory; reset on process restart
