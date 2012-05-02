class NodesController < ApplicationController
  # GET /nodes/1
  # GET /nodes/1.json
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

  # PUT /nodes/1
  # PUT /nodes/1.json
  def update
    @node = Node.find_by_identifier(params[:id])

    respond_to do |format|
      if @node.update_attributes(params[:node])
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node = Node.find_by_identifier(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to nodes_url }
      format.json { head :no_content }
    end
  end
end
