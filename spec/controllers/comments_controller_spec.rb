require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "comments#create action" do
    it "should allow users to create comments on grams" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: { gram_id: gram.id, comment: { message: "Awesome gram!" } }

      expect(response).to redirect_to root_path
      expect(gram.comments.length).to eq 1
      expect(gram.comments.first.message).to eq "Awesome gram!"
    end

    it "should require users to be signed in" do
      gram = FactoryGirl.create(:gram)

      post :create, params: { gram_id: gram.id, comment: { message: "Awesome gram!" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should return http status 404 error if gram not found " do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: { gram_id: 'Nothing', comment: { message: 'Awesome gram!' } }
      expect(response).to have_http_status(:not_found)
    end
  end

end
