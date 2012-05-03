class NodesController < ApplicationController
  def show
    @node = Node.find_by_identifier(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @node }
    end
  end

  def key
    @node = Node.find_by_identifier(params[:id])
    @key = @node.key(params[:key])

    if @key.empty?
      raise ActiveRecord::RecordNotFound 
    end

    respond_to do |format|
      format.json { render json: @key }
    end
  end

  def sum
    @node = Node.find_by_identifier(params[:id])

    @aggregates = SumPresenter.new(@node, params[:keys])

    respond_to do |format|
      format.json { render json: @aggregates.to_json }
    end
  end

  def count
    @node = Node.find_by_identifier(params[:id])

    @aggregates = CountPresenter.new(@node, params[:keys])

    respond_to do |format|
      format.json { render json: @aggregates.to_json }
    end
  end

  def update
    @node = Node.find_by_identifier(params[:id])

    # Doing this manually cause reverse_merge doesn't trigger assignment
    # for each key, and I'm using assignment to ensure types
    if params[:node] and params[:node][:data]
      params[:node][:data].each_pair do |key,value|
        @node.data[key] = value
      end
    end

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { render json: @node }
      else
        format.html { render action: "edit" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def flow_to
    @source = Node.find_by_identifier(params[:id]).save!
    @target = Node.find_by_identifier(params[:target_id]).save!

    @source.flow_to!(@target)

    respond_to do |format|
      format.json { render json: {}.to_json }
    end
  end

  def destroy
    @node = Node.find_by_identifier(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.json { head :no_content }
    end
  end
end
