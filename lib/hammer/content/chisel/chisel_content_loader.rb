module Hammer
  class ChiselContentLoader
    attr_accessor :site_id, :collections, :models, :content_types

    def get_content_for_site
      collections = request_combiner('Model?where={"site":{"$in": [{"__type":"Pointer","className":"Site","objectId":"'+ @site_id +'"}]}}')
      collections
    end

    def ensure_models_content
      models = {}
      @collections.each do |model|
        field = get_model_content(model['objectId'], model['tableName'])
        models[model['name']] = { 'objectId' => model['objectId'], 'tableName' => model['tableName'], 'data' => field }
      end
      models
    end

    def get_model_content model_id, table_url
      model_content = request_combiner('ModelField?where={"model":{"$in": [{"__type":"Pointer","className":"Model", "objectId":"'+ model_id +'"}]}}')

      return ensure_table_fields(model_content, table_url)
    end

    def ensure_table_fields fields, table_url
      fields_name = []

      fields.each do |field|
        fields_name << {'column' => field['name'], 'type' => field['type'] }
      end

      content = ensure_fields_content(table_url, fields_name, fields)
      content
    end

    def ensure_fields_content table_url, fields_name, fields
      hash_content = {}
      complected_content = []
      content = get_fields_content(table_url)

      content.each do |c|
        fields_name.each do |field|
          hash_content[field['column']] = filling_table_data(c, field)
        end
        complected_content << Hammer::ChiselEntry.new(hash_content)
        hash_content = {}
      end
      complected_content
    end

    def filling_table_data table_content, field
      if field['type'] == 'Media'
        if table_content[field['column']]
          if table_content[field['column']].class == Array
            get_list_of_media_content(table_content[field['column']])
          else
            get_media_content(table_content[field['column']]['objectId'])
          end
        else
          Hammer::ChiselMedia.new({}, '')
        end
      else
        table_content[field['column']]
      end
    end

    def get_fields_content table_url
      fields_content = request_combiner(table_url)
      fields_content
    end

    def request_combiner url, results = true
      uri = URI("http://localhost:1337/parse/classes/#{url}")
      req = Net::HTTP::Get.new(uri)
      req['X-Parse-Application-Id'] = "d5701a37cf242d5ee398005d997e4229"

      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
      if results
        return JSON.parse(res.body)['results']
      else
        return JSON.parse(res.body)
      end
    end

    def get_media_content objectId
      media = request_combiner("MediaItem/#{objectId}", false)
      Hammer::ChiselMedia.new(media['file'], media['type'])
    end

    def get_list_of_media_content objects
      media = []
      complected_media = []
      objects.each do |obj|
        media << request_combiner("MediaItem/#{obj['objectId']}", false)
      end
      media.each do |m|
        complected_media << Hammer::ChiselMedia.new(m['file'], m['type'])
      end
      complected_media
    end

  end
end
