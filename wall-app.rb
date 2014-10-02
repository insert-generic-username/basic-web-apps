require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Message
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true
  property :votes,      Integer,  required: true, default: 0
  property :downvotes,  Integer,  required: true, default: 0
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

get("/") do
  records = Message.all(order: :created_at.desc)
  erb(:index, locals: { messages: records })
end

get '/reverse' do
  records = Message.all(reverse_order: :created_at.desc)
  erb(:index, locals: { messages: records })
end

post("/messages") do
  if Message.empty?
    puts "DON'T GIVE ME AN EMPTY POST, SCUMBAG!!!"
    redirect to('/')
  else
    message_body = params["body"]
    message_time = DateTime.now

    message = Message.create(body: message_body, created_at: message_time)

    if message.saved?
      redirect("/")
    else
      erb(:error)
    end
  end
end

post "/messages/:id/upvote" do
  post = Message.where(:id => params[:id])
  post.votes += 1
  post.save
  redirect to('/')
end

post "/messages/:id/downvote" do
  post = Message.where(:id => params[:id])
  post.downvotes += 1
  post.save
  redirect to('/')
end

post "/messages/:id/delete" do
  post = Message.where(:id => params[:id])
  post.delete
  redirect to('/')
end