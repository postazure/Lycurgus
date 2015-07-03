require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe "#get_repo_content" do
    let(:params) {{
        owner: 'postazure',
        repo: 'Lycurgus',
        sha: '6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'
    }}

    before do
      stub_request(:get, 'https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b')
    end

    it 'it reads the sha' do
      get :repo_content, params

      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b').once
    end
  end

end
