require "spec_helper"

describe Lita::Handlers::Youdao, lita_handler: true do
  it {is_expected.to route_command("youdao this is a book").to(:translate)}

  it 'should get content form yoodao' do
    Lita.config.handlers.youdao.api_key = '214266499'
    Lita.config.handlers.youdao.key_from = 'slack-lira-bot'
    send_command('youdao alias')
    puts replies.last
    #expect(replies.last).to include('v2ex.com')
  end
end
