require 'rails_helper'

RSpec.describe PolyCommentsController, type: :controller do
  controller do
  end


  describe 'creating a comment' do
    let!(:first_post) { PolyPost.create(title: 'First Post', creator: @zeus, updated_at: 1.day.ago) }
    context 'as a User' do
      it 'sets the creator' do
        request.session  = { user_id: @hera.id }
        post :create, params: {poly_comment: { poly_post_id: first_post.id, comment: 'First Post!' }}

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@comment).creator).to eq(@hera)
        expect(controller.instance_variable_get(:@comment).updater).to eq(@hera)
        expect(controller.instance_variable_get(:@comment).comment).to eq('First Post!')
        expect(controller.instance_variable_get(:@comment).poly_post).to eq(first_post)
        expect(first_post.reload.updated_at).to be_within(5.seconds).of(Time.current)
        expect(first_post.updater).to eq(@hera)
      end
    end
  end

  describe 'updating a Comment' do
    let!(:first_post) { PolyPost.create(title: 'First Post', creator: @zeus, updated_at: 1.day.ago) }
    let!(:comment) do
      ActiveRecord::Userstamp::PolyStamper.with_stamper(@delynn) do
        PolyComment.create!(comment: 'a title', poly_post_id: first_post.id)
      end
    end

    it 'sets the correct updater' do
      request.session  = { person_id: @delynn.id }
      post :update, params: {id: comment.id, poly_comment: { comment: 'Different' }}

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@comment).comment).to eq('Different')
      expect(controller.instance_variable_get(:@comment).updater).to eq(@delynn)

      expect(first_post.reload.updated_at).to be_within(5.seconds).of(Time.current)
      expect(first_post.updater).to eq(@delynn)
    end
  end

  context 'when handling multiple requests' do
    let!(:first_post) { PolyPost.create(title: 'First Post', creator: @zeus, updated_at: 1.day.ago) }
    let!(:comment) do
      ActiveRecord::Userstamp::PolyStamper.with_stamper(@delynn) do
        PolyComment.create!(comment: 'a title', poly_post_id: first_post.id)
      end
    end

    def simulate_second_request
      old_request_session = request.session
      request.session = { person_id: @nicole.id }

      post :update, params: {id: comment.id, poly_comment: { comment: 'Different Second'}}
      expect(controller.instance_variable_get(:@comment).updater).to eq(@nicole)
    ensure
      request.session = old_request_session
    end

    it 'sets the correct updater' do
      request.session = { person_id: @delynn.id }
      get :edit, params: {id: comment.id}
      expect(response.status).to eq(200)

      simulate_second_request

      post :update, params: {id: comment.id, poly_comment: { comment: 'Different' }}
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@comment).comment).to eq('Different')
      expect(controller.instance_variable_get(:@comment).updater).to eq(@delynn)

      expect(first_post.reload.updated_at).to be_within(5.seconds).of(Time.current)
      expect(first_post.updater).to eq(@delynn)
    end
  end
end
