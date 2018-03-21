json.extract! response, :id, :user_id, :offer_plan_id, :value, :created_at, :updated_at
json.url response_url(response, format: :json)
