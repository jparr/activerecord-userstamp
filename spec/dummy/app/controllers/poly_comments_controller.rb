class PolyCommentsController < ApplicationController
  def create
    @comment = PolyComment.create!(comment_params)
    render(inline: "<%= @comment.comment %>")
  end

  def edit
    @comment = PolyComment.find(params[:id])
    render(inline: "<%= @comment.comment %>")
  end

  def update
    @comment = PolyComment.find(params[:id])
    @comment.update_attributes(comment_params)
    render(inline: "<%= @comment.comment %>")
  end

  protected

  def current_user
    session_user = User.find_by(id: session[:user_id])
    session_user = Person.find_by(id: session[:person_id]) if session[:person_id].present?
    session_user = Bot.find_by(id: session[:bot_id]) if session[:bot_id].present?
    session_user
  end

  def set_stamper
    PolyComment.stamper = current_user
  end

  def reset_stamper
    PolyComment.reset_stamper
  end

  private

  def comment_params
    params.require(:poly_comment).permit(:comment, :poly_post_id)
  end
end
