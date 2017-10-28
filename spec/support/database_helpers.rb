def define_first_post
  @first_post = Person.with_stamper(@delynn) do
    Post.create!(title: 'a title')
  end
end

RSpec.configure do |config|
  config.before(:each) do
    User.delete_all
    Person.delete_all
    Post.delete_all
    Comment.delete_all

    PolyPost.delete_all
    PolyComment.delete_all

    User.reset_stamper
    Person.reset_stamper
    ActiveRecord::Userstamp::PolyStamper.reset_stamper

    @zeus = User.create!(name: 'Zeus')
    @hera = User.create!(name: 'Hera')
    # User.stamper = @zeus.id

    User.with_stamper(@zeus) do
      @delynn = Person.create!(name: 'Delynn')
      @nicole = Person.create!(name: 'Nicole')
    end
    # Person.stamper = @delynn.id

  end
end
