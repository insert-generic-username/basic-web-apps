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
  
  has n,   :comments
end

class Comment
  include DataMapper::Resource
 
  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true
 
  belongs_to :message
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
  message_body = params["body"]
  message_time = DateTime.now

  message = Message.create(body: message_body, created_at: message_time)

  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

post("/messages/*/comments") do |message_id|
  message = Message.get(message_id)
 
  comment = Comment.new
  comment.body = params[:comment_body]
  comment.created_at = DateTime.now
 
  message.comments.push(comment)
  message.save
 
  redirect("/")
end

post "/messages/:id/upvote" do |message_id|
  post = Message.get(message_id)
  post.votes += 1
  post.save
  redirect to('/')
end

post "/messages/:id/downvote" do |message_id|
  post = Message.get(message_id)
  post.downvotes += 1
  post.save
  redirect to('/')
end

post "/messages/:id/delete" do |message_id|
  post = Message.get(message_id)
  post.destroy
  redirect to('/')
end