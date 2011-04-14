require 'escape_utils'

module ElasticSearch
  module Protocol
    module Helpers
      private

      def standard_request(*args)
        response = request(*args)
        handle_error(response) unless response.status == 200
        encoder.decode(response.body)
      end

      def handle_error(response)
        raise RequestError, "(#{response.status}) #{response.body}"
      end

      # :index - one or many index names
      # :type - one or many types
      # :id - one id
      # :op - optional operation
      def generate_uri(options)
        path = ""
        path << "/#{Array(options[:index]).collect { |i| escape(i.downcase) }.join(",")}" if options[:index] && !options[:index].empty?
        path << "/" if options[:index] && options[:index].empty?
        path << "/#{Array(options[:type]).collect { |t| escape(t) }.join(",")}" if options[:type] && !options[:type].empty?
        path << "/#{Array(options[:id]).collect { |id| escape(id) }.join(",")}" if options[:id] && !options[:id].to_s.empty?
        path << "/#{options[:op]}" if options[:op]
        path
      end

      #doesn't handle arrays or hashes or what have you
      def generate_query_string(params)
        params.collect { |k,v| "#{escape(k.to_s)}=#{escape(v.to_s)}" }.join("&")
      end

      def unescape_id!(hit)
        hit["_id"] = unescape(hit["_id"])
        nil
      end

      def set_encoding!(hit)
        encode_utf8(hit["_source"]) if hit["_source"].is_a?(String)
        nil
      end

      def escape(string)
        EscapeUtils.escape_url(string)
      end

      def unescape(string)
        EscapeUtils.unescape_url(string)
      end

      if ''.respond_to?(:force_encoding) && ''.respond_to?(:encoding)
        # encodes the string as utf-8 in Ruby 1.9
        def encode_utf8(string)
          # ElasticSearch only ever returns json in UTF-8 (per the JSON spec) so we can use force_encoding here (#TODO what about ids? can we assume those are always ascii?)
          string.force_encoding(::Encoding::UTF_8)
        end
      else
        # returns the unaltered string in Ruby 1.8
        def encode_utf8(string)
          string
        end
      end

      # Return the bytesize of String; uses String#size under Ruby 1.8 and
      # String#bytesize under 1.9.
      if ''.respond_to?(:bytesize)
        def bytesize(string)
          string.bytesize
        end
      else
        def bytesize(string)
          string.size
        end
      end
    end
  end
end
