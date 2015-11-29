require "spec_helper"

describe Lita::Handlers::Youdao, lita_handler: true do
  it {is_expected.to route_command("youdao this is a book").to(:translate)}

  it 'should get content form yoodao' do
    Lita.config.handlers.youdao.api_key = ENV['YOUDAO_API_KEY']
    Lita.config.handlers.youdao.key_from = ENV['YOUDAO_KEY_FROM']
    send_command('youdao alias')
    puts replies.last
  end
end
