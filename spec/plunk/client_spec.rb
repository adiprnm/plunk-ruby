# frozen_string_literal: true

RSpec.describe Plunk::Client do
  subject(:client) { described_class.new(api_key: api_key) }

  let(:api_key) { 'correct-api-key' }

  describe '#send', :vcr do
    subject(:send) { client.send(mail) }

    context 'when mail' do
      let(:mail) do
        Plunk::Mail::Base.new(
          from: { email: 'sender@example.com', name: 'Plunk Test' },
          to: [
            { email: 'recipient@example.com' }
          ],
          subject: 'You are awesome!',
          text: 'Congrats for sending test email with Plunk!',
          category: 'Integration Test',
          attachments: [
            { content: StringIO.new('hello world'), filename: 'attachment.txt' }
          ]
        )
      end

      context 'when all params are set' do
        it 'sending is successful' do
          expect(send).to eq(
            {
              emails: [
                {
                  contact: { id: '80d74d13-16eb-48c5-bc2b-aae6fd5865cc', email: 'recipient@exmaple.com' },
                  email: 'ebd44b76-9e1d-4826-96a1-9a240c42a939'
                }
              ],
              success: true
            }
          )
        end
      end

      context 'when no subject and no text set' do
        before do
          mail.subject = nil
          mail.text = nil
        end

        it 'raises sending error with array of errors' do
          expect { send }.to raise_error do |error|
            expect(error).to be_a(Plunk::Error)
            expect(error.message).to eq("'subject' is required, must specify either text or html body")
            expect(error.messages).to eq(["'subject' is required", 'must specify either text or html body'])
          end
        end
      end

      context 'when api key is incorrect' do
        let(:api_key) { 'incorrect-api-key' }

        it 'raises authorization error with array of errors' do
          expect { send }.to raise_error do |error|
            expect(error).to be_a(Plunk::AuthorizationError)
            expect(error.message).to eq('Unauthorized')
            expect(error.messages).to eq(['Unauthorized'])
          end
        end
      end

      context 'when mail object is not a Plunk::Mail::Base' do
        let(:mail) { 'it-a-string' }

        it { expect { send }.to raise_error(ArgumentError, 'should be Plunk::Mail::Base object') }
      end
    end
  end

  describe 'errors' do
    subject(:send_mail) { client.send(mail) }

    let(:mail) do
      Plunk::Mail::Base.new(
        from: { email: 'from@example.com' },
        to: [{ email: 'to@example.com' }],
        subject: 'Test',
        text: 'Test'
      )
    end

    def stub_api_send(status, body = nil)
      stub = stub_request(:post, %r{/v1/send}).to_return(status: status, body: body)
      yield
      expect(stub).to have_been_requested
    end

    it 'handles 400' do
      stub_api_send 400, '{"errors":["error"]}' do
        expect { send_mail }.to raise_error(Plunk::Error)
      end
    end

    it 'handles 401' do
      stub_api_send 401, '{"errors":["Unauthorized"]}' do
        expect { send_mail }.to raise_error(Plunk::AuthorizationError)
      end
    end

    it 'handles 403' do
      stub_api_send 403, '{"errors":["Account is banned"]}' do
        expect { send_mail }.to raise_error(Plunk::RejectionError)
      end
    end

    it 'handles 413' do
      stub_api_send 413 do
        expect { send_mail }.to raise_error(Plunk::MailSizeError)
      end
    end

    it 'handles 429' do
      stub_api_send 429 do
        expect { send_mail }.to raise_error(Plunk::RateLimitError)
      end
    end

    it 'handles generic client errors' do
      stub_api_send 418, '🫖' do
        expect { send_mail }.to raise_error(Plunk::Error, 'client error')
      end
    end

    it 'handles server errors' do
      stub_api_send 504, '🫖' do
        expect { send_mail }.to raise_error(Plunk::Error, 'server error')
      end
    end

    it 'handles unexpected response status code' do
      stub_api_send 307 do
        expect { send_mail }.to raise_error(Plunk::Error, 'unexpected status code=307')
      end
    end
  end
end
