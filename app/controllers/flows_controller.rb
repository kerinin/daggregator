class FlowsController < ApplicationController
  # GET /flows
  # GET /flows.json
  def index
    @flows = Flow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @flows }
    end
  end

  # GET /flows/1
  # GET /flows/1.json
  def show
    @flow = Flow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @flow }
    end
  end

  # GET /flows/new
  # GET /flows/new.json
  def new
    @flow = Flow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @flow }
    end
  end

  # GET /flows/1/edit
  def edit
    @flow = Flow.find(params[:id])
  end

  # POST /flows
  # POST /flows.json
  def create
    @flow = Flow.new(params[:flow])

    respond_to do |format|
      if @flow.save
        format.html { redirect_to @flow, notice: 'Flow was successfully created.' }
        format.json { render json: @flow, status: :created, location: @flow }
      else
        format.html { render action: "new" }
        format.json { render json: @flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /flows/1
  # PUT /flows/1.json
  def update
    @flow = Flow.find(params[:id])

    respond_to do |format|
      if @flow.update_attributes(params[:flow])
        format.html { redirect_to @flow, notice: 'Flow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flows/1
  # DELETE /flows/1.json
  def destroy
    @flow = Flow.find(params[:id])
    @flow.destroy

    respond_to do |format|
      format.html { redirect_to flows_url }
      format.json { head :no_content }
    end
  end
end
