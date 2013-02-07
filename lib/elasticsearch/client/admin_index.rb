module ElasticSearch
  module Api
    module Admin
      module Index
        PSEUDO_INDICES = [:all]

        def index_exists?(index)
          !!index_status(index)
        rescue RequestError => e
          if e.status == 404
            false
          else
            raise e
          end
        end

        def index_status(*args)
          indices, options = extract_indices_and_options(args)
          execute(:index_status, indices, options)
        end

        def index_mapping(*args)
          indices, options = extract_indices_and_options(args)
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

        def get_aliases(index=nil, options={})
          scope_index, type, options = extract_scope(options)
          execute(:get_aliases, index || scope_index, options)
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

        def delete_mapping(options={})
          index, type, options = extract_required_scope(options)
          execute(:delete_mapping, index, type, options)
        end

        def update_settings(settings, options={})
          index, type, options = extract_scope(options)
          execute(:update_settings, index, settings, options)
        end

        def get_settings(index=default_index, options={})
          execute(:get_settings, index, options)
        end

        # list of indices, or :all
        # options: refresh
        # default: default_index if defined, otherwise :all
        def flush(*args)
          indices, options = extract_indices_and_options(args)
          execute(:flush, indices, options)
        end

        # list of indices, or :all
        # no options
        # default: default_index if defined, otherwise all
        def refresh(*args)
          indices, options = extract_indices_and_options(args)
          execute(:refresh, indices, options)
        end

        # list of indices, or :all
        # no options
        # default: default_index if defined, otherwise all
        def snapshot(*args)
          indices, options = extract_indices_and_options(args)
          execute(:snapshot, indices, options)
        end

        # list of indices, or :all
        # options: max_num_segments, only_expunge_deletes, refresh, flush
        # default: default_index if defined, otherwise all
        def optimize(*args)
          indices, options = extract_indices_and_options(args)
          execute(:optimize, indices, options)
        end

        def create_river(type, create_options, options={})
          execute(:create_river, type, create_options, options)
        end

        def get_river(type, options={})
          execute(:get_river, type, options)
        end

        def river_status(type, options={})
          execute(:river_status, type, options)
        end

        def delete_river(type=nil, options={})
          execute(:delete_river, type, options)
        end

        private
        def extract_indices_and_options(args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          indices = args.empty? ? [(default_index || :all)] : args.flatten
          indices.collect! { |i| PSEUDO_INDICES.include?(i) ? "_#{i}" : i }
          [indices, options]
        end
      end
    end
  end
end
