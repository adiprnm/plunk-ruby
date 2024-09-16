# frozen_string_literal: true

require 'plunk/action_mailer'

RSpec.describe Plunk::ActionMailer::DeliveryMethod, :vcr do
  describe '#deliver!' do
    subject(:deliver!) { described_class.new(settings).deliver!(message) }

    let(:settings) { { api_key: 'correct-api-key' } }
    let(:message) do
      Mail::Message.new(params).tap do |message|
        message.text_part = 'Some text'
        message.html_part = '<div>HTML part</div>'
        message.headers('X-Special-Domain-Specific-Header': 'SecretValue')
        message.headers('One-more-custom-header': 'CustomValue')
        message.attachments['file.txt'] = File.read('spec/fixtures/files/attachments/file.txt')
        message.attachments['file.txt'].content_id = '<txt_content_id@test.mail>'
        message.attachments.inline['file.png'] = File.read('spec/fixtures/files/attachments/file.png')
        message.attachments['file.png'].content_id = '<png_content_id@test.mail>'
      end
    end
    let(:params) do
      {
        from: 'Plunk Test <sender@example.com>',
        to: 'To 1 <to_1@example.com>, to_2@example.com',
        cc: 'cc_1@example.com, Cc 2 <cc_2@example.com>',
        bcc: 'bcc_1@example.com, bcc_2@example.com',
        reply_to: 'reply-to@example.com',
        subject: 'You are awesome!',
        category: 'Module Test'
      }
    end
    let(:expected_message_ids) do
      [
        { contact: { id: '858cbc46-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc5c-09d5-11ed-91e0-0a58a9feac02' },
        { contact: { id: '858cbc47-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc5d-09d5-11ed-91e0-0a58a9feac02' },
        { contact: { id: '858cbc48-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc5e-09d5-11ed-91e0-0a58a9feac02' },
        { contact: { id: '858cbc49-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc5f-09d5-11ed-91e0-0a58a9feac02' },
        { contact: { id: '858cbc50-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc60-09d5-11ed-91e0-0a58a9feac02' },
        { contact: { id: '858cbc51-09d5-11ed-91e0-0a58a9feac02', email: 'recipient@example.com' }, email: '858cbc61-09d5-11ed-91e0-0a58a9feac02' },
      ]
    end

    before do
      allow(Mail::ContentTypeField).to receive(:generate_boundary).and_return('--==_mimepart_random_boundary')
      allow(Plunk::Client).to receive(:new).and_call_original
    end

    it 'converts the message and sends via API' do
      expect(deliver!).to eq({ success: true, emails: expected_message_ids })
      expect(Plunk::Client).to have_received(:new).with(api_key: 'correct-api-key')
    end
  end
end
