class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :data_json
      t.string :aggregates_json

      t.timestamps
    end
  end
end
