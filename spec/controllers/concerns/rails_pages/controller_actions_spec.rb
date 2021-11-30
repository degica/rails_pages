require 'rails_helper'

describe PagesController, type: :controller do
  describe 'GET #page' do
    it "assigns @data to the result of the Page's data block" do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { true }

        data do
          { test_data: 'right here' }
        end
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      get 'page', params: { page_id: 'mypage' }

      expect(assigns(:data)).to eq(test_data: 'right here')
    end

    it "runs all of the page's before blocks in definition order" do
      count = 0
      first = nil
      second = nil

      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { true }
        data { }

        before { first = (count += 1) }
        before { second = (count += 1) }
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      expect { get 'page', params: { page_id: 'mypage' } }
        .to change { first }
        .from(nil).to(1)
        .and change { second }
        .from(nil).to(2)
    end

    it "raises Unauthorized when one of the Page's authorize block returns false" do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { true }
        authorize { false }
        data { }
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      expect { get 'page', params: { page_id: 'mypage' } }
        .to raise_error RailsPages::Errors::Unauthorized
    end

    it 'raises an error when the page has no authorize blocks' do
      page = RailsPages::Page.new('mypage', '/test', proc do
        data { }
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      expect { get 'page', params: { page_id: 'mypage' } }
        .to raise_error 'Page missing authorization: mypage'
    end
  end

  describe 'GET #page_get' do
    it 'lets me render in the get block' do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { true }

        get 'test' do
          render json: { it: 'worked!' }
        end
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      get 'page_get', params: { page_id: 'mypage', action_name: 'test' }

      expect(response.status).to eq 200
      expect(response.body).to eq '{"it":"worked!"}'
    end

    it 'checks the authorize block' do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { false }

        get 'test' do
          render json: { it: 'worked!' }
        end
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      expect { get 'page_get', params: { page_id: 'mypage', action_name: 'test' } }
        .to raise_error RailsPages::Errors::Unauthorized
    end
  end

  describe 'POST #page_post' do
    it 'lets me render in the post block' do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { true }

        post 'test' do
          render json: { it: 'worked!' }
        end
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      post 'page_post', params: { page_id: 'mypage', action_name: 'test' }

      expect(response.status).to eq 200
      expect(response.body).to eq '{"it":"worked!"}'
    end

    it 'checks the authorize block' do
      page = RailsPages::Page.new('mypage', '/test', proc do
        authorize { false }

        post 'test' do
          render json: { it: 'worked!' }
        end
      end)
      allow(RailsPages::Page).to receive(:find).with('mypage').and_return page

      expect { post 'page_post', params: { page_id: 'mypage', action_name: 'test' } }
        .to raise_error RailsPages::Errors::Unauthorized
    end
  end
end

