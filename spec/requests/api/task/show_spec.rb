require "rails_helper"

RSpec.describe "GET /api/tasks/:id", type: :request do
  it "returns a single task" do
    task = create(:task, title: "Write tests")

    get "/api/tasks/#{task.id}"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to include("id" => task.id, "title" => "Write tests")
  end

  it "returns 404 when the task does not exist" do
    get "/api/tasks/999"

    expect(response).to have_http_status(:not_found)
  end
end
