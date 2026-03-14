# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module PhenomenalBinding
      module Helpers
        class Stream
          include Constants

          attr_reader :id, :stream_type, :content, :salience, :timestamp, :domain, :created_at

          def initialize(stream_type:, content:, salience: DEFAULT_SALIENCE, domain: nil, timestamp: nil)
            @id          = ::SecureRandom.uuid
            @stream_type = stream_type
            @content     = content
            @salience    = salience.clamp(0.0, 1.0)
            @domain      = domain
            @timestamp   = timestamp || Time.now.utc
            @created_at  = Time.now.utc
          end

          def salient?
            @salience >= DEFAULT_SALIENCE
          end

          def fresh?(window: 30)
            (Time.now.utc - created_at) <= window
          end

          def to_h
            {
              id:          @id,
              stream_type: @stream_type,
              content:     @content,
              salience:    @salience.round(10),
              domain:      @domain,
              timestamp:   @timestamp,
              created_at:  @created_at
            }
          end
        end
      end
    end
  end
end
