RSpec.describe TelegramWebhooksController, :telegram_bot do
  def reply
    bot.requests[:sendMessage].last
  end

  describe '#start!' do
    subject { -> { dispatch_command :start } }
    it { should respond_with_message 'Please send location!' }
  end

  describe '#message' do
    subject { -> { dispatch_message text } }
    let(:text) { 'some plain text' }
    it { should respond_with_message 'Send location!' }
  end
end
