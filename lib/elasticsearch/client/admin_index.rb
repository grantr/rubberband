module ElasticSearch
  module Api
    module Admin
      module Index
        PSEUDO_INDICES = [:all]

        def index_status(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:index_status, indices, options)
        end

        def index_mapping(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:index_mapping, indices, options)
        end

        # options: number_of_shards, number_of_replicas
        def create_index(index, create_options={}, options={})
          unless create_options[:index]
            create_options = { :index => create_options }
          end
          execute(:create_index, index, create_options, options)
        end

        def delete_index(index, options={})
          execute(:delete_index, index, options)
        end

        # :add => { "index" => "alias" }
        # :add => [{"index" => "alias"}, {"index2" => "alias2"}]
        # :add => { "index" => "alias", "index2" => "alias2" }
        # :remove => { "index" => "alias" }
        # :remove => [{"index" => "alias", {"index2" => "alias2"}]
        # :remove => { "index" => "alias", "index2" => "alias2" }
        # :actions => [{:add => {:index => "index", :alias => "alias"}}]
        def alias_index(operations, options={})
          if operations[:actions]
            alias_ops = operations
          else
            alias_ops = { :actions => [] }
            [:add, :remove].each do |op|
              next unless operations.has_key?(op)
              op_actions = operations[op].is_a?(Array) ? operations[op] : [operations[op]]
              op_actions.each do |action_hash|
                action_hash.each do |index, index_alias|
                  alias_ops[:actions] << { op => { :index => index, :alias => index_alias }}
                end
              end
            end
          end
          execute(:alias_index, alias_ops, options)
        end

        # options: ignore_conflicts
        def update_mapping(mapping, options={})
          index, type, options = extract_required_scope(options)

          options = options.dup
          indices = Array(index)
          unless mapping[type]
            mapping = { type => mapping }
          end

          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:update_mapping, indices, type, mapping, options)
        end

        # list of indices, or :all
        # options: refresh
        # default: default_index if defined, otherwise :all
        def flush(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:flush, indices, options)
        end

        # list of indices, or :all
        # no options
        # default: default_index if defined, otherwise all
        def refresh(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:refresh, indices, options)
        end
        
        # list of indices, or :all
        # no options
        # default: default_index if defined, otherwise all
        def snapshot(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:snapshot, indices, options)
        end

        # list of indices, or :all
        # options: max_num_segments, only_expunge_deletes, refresh, flush
        # default: default_index if defined, otherwise all
        def optimize(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          execute(:optimize, indices, options)
        end
      end
    end
  end
end
