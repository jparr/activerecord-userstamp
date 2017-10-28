class PolyPostsController < ApplicationController
  def create
    @post = PolyPost.create!(post_params)
    render(inline: "<%= @post.title %>")
  end

  def edit
    @post = PolyPost.find(params[:id])
    render(inline: "<%= @post.title %>")
  end

  def update
    @post = PolyPost.find(params[:id])
    @post.update_attributes(post_params)
    render(inline: "<%= @post.title %>")
  end

  protected

  def current_user
    session_user = User.find_by(id: session[:user_id])
    session_user = Person.find_by(id: session[:person_id]) if session[:person_id].present?
    session_user
  end

  def set_stamper
    ActiveRecord::Userstamp::PolyStamper.stamper = current_user
  end

  def reset_stamper
    ActiveRecord::Userstamp::PolyStamper.reset_stamper
  end

  private

  def post_params
    params.require(:poly_post).permit(:title)
  end
end
