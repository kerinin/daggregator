class CreateFlows < ActiveRecord::Migration
  def change
    create_table :flows do |t|
      t.string :operations
      t.belongs_to :source_id
      t.belongs_to :target_id

      t.timestamps
    end
  end
end
