module Lita
  module Handlers
    class Youdao < Handler
      config :api_key, required: true
      config :key_from, required: true

      route(/youdao\s+(.+)/, :translate, command: true, help: {
        "youdao" => "translation using youdao api"
      })

      def translate response
        word = URI.encode response.matches[0][0]
        translation = redis.get word
        translation = access_api(word) unless translation
        response.reply translation
      end

      def access_api word
        url = 'http://fanyi.youdao.com/openapi.do'
        res = http.get(url,
                      keyfrom: config.key_from,
                      key: config.api_key,
                      type: 'data',
                      doctype: 'json',
                      version: '1.1',
                      q: word)
        hash_res = MultiJson.load(res.body)
        if hash_res['errorCode'] == 0
          format_display hash_res
        else
          error_code[hash_res['errorCode']]
        end
      end

      def format_display hash_res
        ["*翻译*: #{format_translation hash_res}",
          "*音标*: #{format_phonetic hash_res}", 
          "*基本词典*\n#{ format_explain hash_res}", 
          "*网络释义*\n#{format_web_explain(hash_res)}"
        ].join("\n")
      end

      def format_translation hash_res
        if hash_res.fetch('translation')
          hash_res['translation'].map {|trans| URI.decode trans.gsub(' ', '')}.join(", ") rescue nil
        end
      end

      def format_phonetic hash_res
        if hash_res.fetch('basic', nil)
          hash_res['basic']['phonetic'] rescue ''
        end
      end

      def format_explain hash_res
        if hash_res.fetch('basic', nil)
          hash_res['basic']['explains'].map {|line| "\t#{line}"}.join("\n") rescue ''
        end
      end

      def format_web_explain(hash_res)
        if hash_res.fetch('web', nil)
          content = []
          hash_res['web'].each do |explain|
            content << explain['value'].map {|line| "\t#{line}"}.join(', ') rescue nil
          end
          content.join("\n")
        end
      end

      def error_code
        { 20 => '要翻译的文本过长',
          30 => "无法进行有效的翻译",
          40 => "不支持的语言类型",
          50 => "无效的key", 
          60 => "无词典结果，仅在获取词典结果生效"
        }
      end

      Lita.register_handler(self)
    end
  end
end
