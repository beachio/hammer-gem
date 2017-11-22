require 'http'
require 'uri'
require 'net/http'
module Hammer
  class ChiselContentLoader
    attr_accessor :site_id, :collections, :models, :content_types

    def get_content_for_site(site_id)
      if site_id
      collections = request_combiner('Model?where=','{"site":{"$in": [{"__type":"Pointer","className":"Site","objectId":"'+ site_id +'"}]}}')
      collections
      end
    end

    def ensure_models_content collection
      models = {}
      collection.each do |model|
        field = get_model_content(model['objectId'], model['tableName'])
        models[model['name']] = { 'objectId' => model['objectId'], 'tableName' => model['tableName'], 'data' => field }
      end
      models
    end

    def get_model_content model_id, table_url
      model_content = request_combiner('ModelField?where=','{"model":{"$in": [{"__type":"Pointer","className":"Model", "objectId":"'+ model_id +'"}]}}')

      return ensure_table_fields(model_content, table_url)
    end

    def ensure_table_fields fields, table_url
      fields_name = []

      fields.each do |field|
        fields_name << {'column' => field['nameId'], 'type' => field['type'] }
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
      elsif field['type'] == 'Reference'
        if table_content[field['column']]
          if table_content[field['column']].class == Array
            if !table_content[field['column']].empty?
              if table_content[field['column']][0]["__type"] == 'Pointer'
                table_content[field['column']] = get_pointers_content table_content[field['column']][0]
              end
            else
              table_content[field['column']] = Hammer::ChiselEntry.new({})
            end
          end
        end
      else
        table_content[field['column']]
      end
    end

    def get_pointers_content content
      parse_pointers_content(content)
    end

    def parse_pointers_content content
      coll = request_combiner("#{content['className']}?where=",'{"objectId":"'+ content['objectId'] +'"}')
      ["objectId", "t__status","t__color","t__model","createdAt", "updatedAt"].each {|k| coll[0].delete(k)}
      coll[0].keys.each do |key|
        if coll[0][key].class == Array
          if !coll[0][key].empty?
            if coll[0][key][0]["__type"] == 'Pointer'
              coll[0][key] = parse_pointers_content(coll[0][key][0])
            end
          else
            coll[0][key] = Hammer::ChiselEntry.new({})
          end
        end
      end
      Hammer::ChiselEntry.new(coll[0])
    end

    def get_fields_content table_url
      fields_content = request_combiner(table_url)
      fields_content
    end

    def request_combiner parse_class, query='', results = true
      query = URI.encode(query)
      headers = { 'X-Parse-Application-Id' => application_keys('id'), 'X-Parse-Session-Token' => Settings.session_token }
      res = JSON.parse(HTTP[headers].get("#{application_keys('url')}/classes/#{parse_class}#{query}"))
      if results
        return res['results']
      else
        return res
      end
    end

    def get_media_content objectId
      media = request_combiner("MediaItem/#{objectId}", '', false)
      Hammer::ChiselMedia.new(media['file'], media['type'])
    end

    def get_list_of_media_content objects
      media = []
      complected_media = []
      objects.each do |obj|
        media << request_combiner("MediaItem/#{obj['objectId']}",'', false)
      end
      media.each do |m|
        complected_media << Hammer::ChiselMedia.new(m['file'], m['type'])
      end
      complected_media
    end

    def application_keys key
      if key == 'url'
        Settings.chisel['parse_server_url'] ? Settings.chisel['parse_server_url'] : 'http://localhost:1337/parse'
      elsif key == 'id'
        Settings.chisel['parse_app_id'] ? Settings.chisel['parse_app_id'] : 'd5701a37cf242d5ee398005d997e4229'
      end
    end

    def login (login, password)
      query = 'username='+ login +'&password='+ password +''
      query = URI.encode(query)
      headers = { 'X-Parse-Application-Id' => application_keys('id') }
      res = JSON.parse(HTTP[headers].get("#{application_keys('url')}/login?#{query}"))
      if res["sessionToken"]
        return res["sessionToken"]
      end
      return
    end

    def access(site_id)
      rights = get_content_for_site(site_id)
      if rights.length > 0
        return true
      else
        false
      end
    end

    def logout(sessionTok)
      uri = URI.parse("#{application_keys('url')}/logout")
      http = Net::HTTP.new(uri.host, uri.port)
      headers = { 'X-Parse-Application-Id' => application_keys('id'), 'X-Parse-Session-Token' => sessionTok }
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      response = http.request request
    end
  end
end
