require 'plunk'

# create mail object
mail = Plunk::Mail::FromTemplate.new(
  from: { email: 'plunk@example.com', name: 'Plunk Test' },
  to: [
    { email: 'your@email.com' }
  ],
  template_uuid: '2f45b0aa-bbed-432f-95e4-e145e1965ba2',
  template_variables: {
    'user_name' => 'John Doe'
  }
)

# create client and send
client = Plunk::Client.new(api_key: 'your-api-key')
client.send(mail)
