require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy action" do
    it "should prevent users who did not create gram from destroying gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, params: { id: gram.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "should prevent unauthenticated users from destroying gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully destroy grams" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end

    it "should return 404 error if gram is not found with given id" do
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, params: { id: 'SPACEDUCK' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "should prevent users who did not create gram from updating gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, params: { id: gram.id, gram: { message: 'Changed' } }
      expect(response).to have_http_status(:forbidden)
    end

    it "should prevent unauthenticated users from updating gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, params: { id: gram.id, gram: { message: 'Hello' } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully update grams" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user

      patch :update, params: { id: gram.id, gram: { message: 'Changed' } }
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq 'Changed'
    end

    it "should return 404 error if gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, params: { id: 'YOLOSWAG', gram: { message: 'Changed' } }
      expect(response).to have_http_status(:not_found)
    end

    it "should render edit form with http status of unprocessable_entity" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user

      patch :update, params: { id: gram.id, gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq 'Initial Value'
    end
  end

  describe "grams#edit action" do
    it "should prevent user who did not create gram from editing gram" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "should prevent unauthenticated users from editing gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show edit form if gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user

      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return 404 error if gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, params: { id: 'SWAG' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#show action" do
    it "should successfully show page if gram is found" do
      gram = FactoryGirl.create(:gram)
      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return 404 error if gram is not found" do
      get :show, params: { id: 'TACOCAT' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be signed in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be signed in" do
      post :create, params: { gram: { message: "Hello!" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create new gram in database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: {
        gram: {
          message: 'Hello!',
          picture: fixture_file_upload("/picture.png", 'image/png')
          }
        }
        
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly address validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: { gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end
end
