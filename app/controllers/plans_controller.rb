include Response
include SlackToken

class PlansController < ApplicationController

  before_action :set_plan, only: [:show, :update, :destroy]

  # GET /plans
  def index
    @plans = Plan.all
    json_response(@plans)
  end

  # POST /plans
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    @plan = Plan.create!(plan_params)
    json_response(@plan, :created)
  end

  # GET /plans/:id
  def show
    puts request
    json_response(@plan)
  end

  # PUT /plans/:id
  def update
    puts request
    @plan.update(plan_params)
    head :no_content
  end

  # DELETE /plans/:id
  def destroy
    puts request
    @plan.destroy
    head :no_content
  end

  private

  def plan_params
    # whitelist params
    params.permit(:title, :created_by_slack_user)
  end

  def set_plan
    @plan = Plan.find(params[:id])
  end

end
