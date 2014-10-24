require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Scene
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true

end

DataMapper.finalize()
DataMapper.auto_upgrade!()

get "/" do
  records = Scene.all(order: :created_at.desc)
  erb(:index, locals: { messages: records })
end

get '/reverse' do
  records = Scene.all(reverse_order: :created_at.desc)
  erb(:index, locals: { messages: records })
end

post "/messages" do
  message_body = params["body"]
  message_time = DateTime.now

  message = Scene.create(body: message_body, created_at: message_time)

  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

post "/messages/:id/delete" do |scene_id|
  post = Scene.get(message_id)
  post.destroy
  redirect to('/')
end