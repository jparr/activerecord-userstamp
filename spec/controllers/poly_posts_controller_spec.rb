require 'rails_helper'

RSpec.describe PolyPostsController, type: :controller do
  controller do
  end

  describe 'creating a post' do
    context 'as a User' do
      it 'sets the creator' do
        request.session  = { user_id: @hera.id }
        post :create, params: {poly_post: { title: 'First Post!' }}

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@post).creator).to eq(@hera)
        expect(controller.instance_variable_get(:@post).updater).to eq(@hera)
        expect(controller.instance_variable_get(:@post).title).to eq('First Post!')
      end
    end

    context 'as a Person' do
      it 'sets the creator' do
        request.session  = { person_id: @delynn.id }
        post :create, params: {poly_post: { title: 'First Post!' }}

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@post).creator).to eq(@delynn)
        expect(controller.instance_variable_get(:@post).updater).to eq(@delynn)
        expect(controller.instance_variable_get(:@post).title).to eq('First Post!')
      end
    end
  end

  context 'when updating a Post' do
    let!(:first_post) do
      PolyPost.with_stamper(@delynn) do
        PolyPost.create!(title: 'a title')
      end
    end

    it 'sets the correct updater' do
      request.session  = { person_id: @delynn.id }
      post :update, params: {id: first_post.id, poly_post: { title: 'Different' }}

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@post).title).to eq('Different')
      expect(controller.instance_variable_get(:@post).updater).to eq(@delynn)
    end
  end

  context 'when handling multiple requests' do
    let!(:first_post) do
      PolyPost.with_stamper(@delynn) do
        PolyPost.create!(title: 'a title')
      end
    end

    def simulate_second_request
      old_request_session = request.session
      request.session = { person_id: @nicole.id }

      post :update, params: {id: first_post.id, poly_post: { title: 'Different Second'}}
      expect(controller.instance_variable_get(:@post).updater).to eq(@nicole)
    ensure
      request.session = old_request_session
    end

    it 'sets the correct updater' do
      request.session = { person_id: @delynn.id }
      get :edit, params: {id: first_post.id}
      expect(response.status).to eq(200)

      simulate_second_request

      post :update, params: {id: first_post.id, poly_post: { title: 'Different' }}
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@post).title).to eq('Different')
      expect(controller.instance_variable_get(:@post).updater).to eq(@delynn)
    end
  end
end
